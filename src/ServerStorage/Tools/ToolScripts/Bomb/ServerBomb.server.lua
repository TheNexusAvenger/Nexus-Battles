--[[
TheNexusAvenger

Runs the server-side part of the bomb.
--]]

local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local BombMesh = Handle:WaitForChild("Mesh")
local BombLight = Handle:WaitForChild("Light")
local BombBeepSound = Handle:WaitForChild("BeepSound")

local BombCreator = require(Tool:WaitForChild("BombCreator"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))
local ExplosionCreator = require(Tool:WaitForChild("ExplosionCreator"))
local PlayerDamager = require(Tool:WaitForChild("PlayerDamager"))

local BOMB_RELOAD_TIME = Configuration.BOMB_RELOAD_TIME

local BombBuffer = BufferCreator:CreateServerBuffer("BombBuffer")
local ArmBombEvent = RemoteEventCreator:CreateRemoteEvent("ArmBomb")
local BombReleasedEvent = RemoteEventCreator:CreateRemoteEvent("BombReleased")

local CurrentPlayer,CurrentCharacter,CurrentHumanoid
local CurrentBomb,CurrentBombInterrupt
local Equipped,Holding = false,false
local ToolEnabled = true



--[[
Adds a bomb to the buffer.
--]]
local function AddBufferBomb()
    local NewBomb = BombCreator:CreateBomb()
    CurrentBomb = NewBomb
    BombBuffer:AddItem(NewBomb)
end
AddBufferBomb()

--[[
Runs the bomb animation. Returns a function to terminate it.
--]]
local function RunBombAnimation()
    local TickTime = 0.4
    local IsRed = true
    Tool.Grip = CFrame.new(0.623935461,-0.378438532,0,0.848048091,0,0.529919267,0.529919267,0,-0.848048091,0,1,0)

    --Run the tick.
    spawn(function()
        BombBeepSound:Play()
        repeat
            BombMesh.TextureId = IsRed and "http://www.roblox.com/asset/?id=94691735"  or "http://www.roblox.com/asset/?id=94691681"
            BombLight.Enabled = IsRed
            BombBeepSound:Play()
            wait(TickTime)

            IsRed = not IsRed
            TickTime = TickTime * 0.9
        until TickTime < 0.1

        --Reset the bomb.
        BombMesh.TextureId = "http://www.roblox.com/asset/?id=94691681"
        BombLight.Enabled = false
        BombBeepSound:Stop()
        Handle.Transparency = 1

        --Automatically kill the humanoid if it was still running.
        Tool.Grip = CFrame.new(0.0614605024,0,0.920917511,0.974370062,0,-0.224951088,0,1,0,0.224951088,0,0.974370062)
        if CurrentHumanoid and TickTime ~= 0 and Holding and CurrentHumanoid and CurrentPlayer then
            ExplosionCreator:CreateExplosion(Handle.Position,CurrentPlayer,nil,"Bomb","rbxasset://sounds/Rocket shot.wav")
            PlayerDamager:DamageHumanoid(CurrentPlayer,CurrentHumanoid,CurrentHumanoid.Health,"Bomb")
        end
    end)

    --Return the interrupt function.
    return function()
        TickTime = 0
    end
end



--Set up connections for arming and launching the bomb.
ArmBombEvent.OnServerEvent:Connect(function(Player)
    if Player == CurrentPlayer and ToolEnabled then
        --Disable the tool
        ToolEnabled = false
        Tool.Enabled = false
        CurrentBomb = BombBuffer:PopItem() or CurrentBomb
        CurrentBombInterrupt = RunBombAnimation()

        --Created ObjectValue with who fired the bomb. This arms the bomb.
        local FiredBy = Instance.new("ObjectValue")
        FiredBy.Name = "FiredBy"
        FiredBy.Value = Player
        FiredBy.Parent = CurrentBomb

        --Wait to reload, then add a new buffer bomb.
        Holding = true
        while Holding do wait() end
        wait(BOMB_RELOAD_TIME)
        Handle.Transparency = 0
        AddBufferBomb()
        ToolEnabled = true
        Tool.Enabled = true
    end
end)

BombReleasedEvent.OnServerEvent:Connect(function(Player)
    if Player == CurrentPlayer then
        Holding = false

        if CurrentBombInterrupt then
            CurrentBombInterrupt()
            CurrentBombInterrupt = nil
        end
    end
end)

--Set up tool equipping and unequipping.
Tool.Equipped:Connect(function()
    if not Equipped then
        Equipped = true

        --Set the current player and set buffer network ownership.
        CurrentCharacter = Tool.Parent
        CurrentPlayer = Players:GetPlayerFromCharacter(CurrentCharacter)
        CurrentHumanoid = CurrentCharacter:WaitForChild("Humanoid")
        BombBuffer:SetCurrentPlayer(CurrentPlayer)
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Clear the current player and reset the network ownership.
        CurrentCharacter = nil
        CurrentPlayer = nil
        CurrentHumanoid = nil
        Holding = false
        BombBuffer:SetCurrentPlayer()

        if CurrentBombInterrupt then
            CurrentBombInterrupt()
            CurrentBombInterrupt = nil
        end
    end
end)