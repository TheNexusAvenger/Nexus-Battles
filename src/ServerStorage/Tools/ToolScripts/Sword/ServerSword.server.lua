--[[
TheNexusAvenger

Runs the server-side sword.
--]]

local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local UnsheathSound = Handle:WaitForChild("UnsheathSound")
local SlashSound = Handle:WaitForChild("SlashSound")
local LungeSound = Handle:WaitForChild("LungeSound")
local OverheadSound = Handle:WaitForChild("OverheadSound")
local HitSound = Handle:WaitForChild("HitSound")

local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local PlayerDamager = require(Tool:WaitForChild("PlayerDamager"))
local Modifiers = require(Tool:WaitForChild("Modifiers"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local WALK_SPEED_BUFF = Configuration.WALK_SPEED_BUFF
local SLASH_DAMAGE = Configuration.SLASH_DAMAGE
local LUNGE_DAMAGE = Configuration.LUNGE_DAMAGE
local OVERHEAD_SLASH_DAMAGE = Configuration.OVERHEAD_SLASH_DAMAGE
local CAN_CUT_TREES = Configuration.CAN_CUT_TREES
local TREE_NAMES = Configuration.TREE_NAMES

local SwingSwordEvent = RemoteEventCreator:CreateRemoteEvent("SwingSword")

local CurrentPlayer,CurrentCharacter,CurrentHumanoid
local HitCharacters
local CurrentDamage = 0
local Equipped = false
local ToolEnabled = true
local TreeNameMap = {}

for _,Name in pairs(TREE_NAMES) do
    TreeNameMap[Name] = true
end



--[[
Sets the sword in an up position.
--]]
local function SwordUp()
    Tool.GripForward = Vector3.new(1,0,0)
    Tool.GripRight = Vector3.new(0,0,1)
    Tool.GripUp = Vector3.new(0,1,0)
end

--[[
Sets the sword in an out position.
--]]
local function SwordOut()
    Tool.GripForward = Vector3.new(0,-1,0)
    Tool.GripRight = Vector3.new(0,0,1)
    Tool.GripUp = Vector3.new(-1,0,0)
end

--[[
Returns whether the instance is in a tree model.
--]]
local function CheckInTreeModel(Ins)
    while Ins and Ins ~= game do
        if Ins:FindFirstChild("Humanoid") then return false end
        if TreeNameMap[Ins.Name] then return true end
        Ins = Ins.Parent
    end
    return false
end

--[[
Handles a part hitting the sword.
--]]
function SwordHit(TouchPart)
    if not TouchPart.Parent then return end
    if not CurrentPlayer then return end
    if not CurrentHumanoid then return end

    local Character = TouchPart.Parent
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid ~= CurrentHumanoid and HitCharacters and not HitCharacters[Character] and CurrentHumanoid.Health > 0 and  CurrentDamage > 0 then
        --If it is a character, damage the character.
        HitCharacters[Character] = true
        PlayerDamager:DamageHumanoid(CurrentPlayer,Humanoid,CurrentDamage,"Sword")
    elseif CAN_CUT_TREES and not Tool.Enabled and CheckInTreeModel(TouchPart) then
        --If it is a tree, break the tree.
        TouchPart:BreakJoints()
    end
end



--Set up the swing event.
SwingSwordEvent.OnServerEvent:Connect(function(Player,SwordMode)
    if Player == CurrentPlayer and ToolEnabled and SwordMode then
        ToolEnabled = false
        Tool.Enabled = false

        --Enable hits.
        HitCharacters = {[Player.Character] = true}

        --Play the sound and set the damage.
        if SwordMode == 1 then
            CurrentDamage = SLASH_DAMAGE
            SlashSound:Play()
            wait(0.6)
        elseif SwordMode == 2 then
            CurrentDamage = LUNGE_DAMAGE
            LungeSound:Play()
            wait(0.45)
            SwordOut()
            wait(0.2)
            SwordUp()
        elseif SwordMode == 3 then
            CurrentDamage = OVERHEAD_SLASH_DAMAGE
            OverheadSound:Play()
            wait(0.6)
        end

        --After cooling down, reset the damage and prevent hits.
        CurrentDamage = 0
        HitCharacters = nil
        ToolEnabled = true
        Tool.Enabled = true
    end
end)

--Set up the equip and unequip events.
Tool.Equipped:Connect(function()
    if not Equipped then
        Equipped = true

        --Set the current player.
        CurrentCharacter = Tool.Parent
        CurrentHumanoid = CurrentCharacter:FindFirstChildOfClass("Humanoid")
        CurrentPlayer = Players:GetPlayerFromCharacter(CurrentCharacter)

        --Add a walkspeed modifier and play the equip sound.
        Modifiers:Add("SwordSpeed","Speed",WALK_SPEED_BUFF)
        delay(0.55, function()
            if not Equipped then return end
            UnsheathSound:Play()
        end)
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Remove the walkspeed modifier.
        Modifiers:Remove("SwordSpeed")

        --Reset the current character.
        CurrentCharacter = nil
        CurrentHumanoid = nil
        CurrentPlayer = nil

        --Stop all sounds.
        UnsheathSound:Stop()
        SlashSound:Stop()
        LungeSound:Stop()
        OverheadSound:Stop()
        HitSound:Stop()
    end
end)

Handle.Touched:connect(SwordHit)