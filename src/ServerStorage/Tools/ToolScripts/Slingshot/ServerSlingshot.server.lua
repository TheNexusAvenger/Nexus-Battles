--[[
TheNexusAvenger

Runs the server-side slingshot.
--]]

local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local EquipSound = Handle:WaitForChild("EquipSound")
local SlingshotSound1 = Handle:WaitForChild("SlingshotSound1")
local SlingshotSound2 = Handle:WaitForChild("SlingshotSound2")
local SlingshotSound3 = Handle:WaitForChild("SlingshotSound3")

local FireSounds = {
    SlingshotSound1,
    SlingshotSound2,
    SlingshotSound3,
}

local SlingshotBallCreator = require(Tool:WaitForChild("SlingshotBallCreator"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local SLINGSHOT_RELOAD_TIME = Configuration.SLINGSHOT_RELOAD_TIME

local SlingshotBuffer = BufferCreator:CreateServerBuffer("SlingshotBuffer")
local FireSlingshotEvent = RemoteEventCreator:CreateRemoteEvent("FireSlingshot")

local CurrentPlayer,CurrentCharacter
local CurrentSlingshotBall,CurrentSlingshotEquipBall
local Equipped = false
local ToolEnabled = true



--[[
Adds a slingshot ball to the buffer.
--]]
local function AddBufferSlingshotBall()
    local NewSlingshotBall = SlingshotBallCreator:CreateSlingshotBall(true)
    CurrentSlingshotBall = NewSlingshotBall
    SlingshotBuffer:AddItem(NewSlingshotBall)
end
AddBufferSlingshotBall()



--Set up activated event.
FireSlingshotEvent.OnServerEvent:Connect(function(Player)
    if Player == CurrentPlayer and ToolEnabled then
        Tool.Enabled = false
        ToolEnabled = false
        CurrentSlingshotBall = SlingshotBuffer:PopItem() or CurrentSlingshotBall
        if CurrentSlingshotEquipBall then CurrentSlingshotEquipBall.Transparency = 1 end

        --Play a random fire sound.
        FireSounds[math.random(1,#FireSounds)]:Play()

        --Set up the person who fired it.
        local FiredBy = Instance.new("ObjectValue")
        FiredBy.Name = "FiredBy"
        FiredBy.Value = Player
        FiredBy.Parent = CurrentSlingshotBall

        --Cooldown and add to the buffer.
        wait(SLINGSHOT_RELOAD_TIME)
        if CurrentSlingshotEquipBall then CurrentSlingshotEquipBall.Transparency = 0 end
        AddBufferSlingshotBall()
        ToolEnabled = true
        Tool.Enabled = true
    end
end)

--Set up equipped and unequipped events.
Tool.Equipped:Connect(function()
    if not Equipped then
        Equipped = true

        --Set up the currnt player and play the equip sound.
        CurrentCharacter = Tool.Parent
        CurrentPlayer = Players:GetPlayerFromCharacter(CurrentCharacter)
        EquipSound:Play()

        --Create the fake ammo for the left hand.
        local LeftGripAttachment = CurrentCharacter:FindFirstChild("LeftGripAttachment",true)
        if LeftGripAttachment then
            CurrentSlingshotEquipBall = SlingshotBallCreator:CreateSlingshotBall(false)
            CurrentSlingshotEquipBall.Name = "HandSlingshotBall"
            CurrentSlingshotEquipBall.Parent = Tool

            local Weld = Instance.new("Weld")
            Weld.Part0 = LeftGripAttachment.Parent
            Weld.Part1 = CurrentSlingshotEquipBall
            Weld.C0 = LeftGripAttachment.CFrame
            Weld.C1 = CFrame.new(-0.3,0.3,0)
            Weld.Parent = CurrentSlingshotEquipBall
        end

        SlingshotBuffer:SetCurrentPlayer(CurrentPlayer)
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Stop the sounds and reset the current player.
        CurrentCharacter = nil
        CurrentPlayer = nil
        EquipSound:Stop()
        SlingshotSound1:Stop()
        SlingshotSound2:Stop()
        SlingshotSound3:Stop()
        SlingshotBuffer:SetCurrentPlayer()
        if CurrentSlingshotEquipBall then CurrentSlingshotEquipBall:Destroy() end
    end
end)