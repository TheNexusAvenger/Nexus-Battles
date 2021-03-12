--[[
TheNexusAvenger

Runs the client-side part of the bomb.
--]]

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local BeepSound = Handle:WaitForChild("BeepSound")

local InputHandler = require(Tool:WaitForChild("InputHandler"))
local AnimationPlayer = require(Tool:WaitForChild("AnimationPlayer"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local BOMB_LAUNCH_SPEED = Configuration.BOMB_LAUNCH_SPEED

local BombBuffer = BufferCreator:CreateClientBuffer("BombBuffer")
local ArmBombEvent = RemoteEventCreator:GetRemoteEvent("ArmBomb")
local BombReleasedEvent = RemoteEventCreator:GetRemoteEvent("BombReleased")

local CurrentAnimation
local CurrentMouse
local CurrentBombWeld,CurrentBomb
local Equipped = false



--[[
Updates the mouse icon if the tool is equipped.
--]]
local function UpdateIcon()
    if CurrentMouse and Equipped then
        CurrentMouse.Icon = Tool.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
    end
end

--[[
Launch a bomb with at the target.
--]]
local function LaunchBomb(Bomb,TargetPos)
    if CurrentBombWeld then CurrentBombWeld:Destroy() end

    local Direction = (TargetPos - Handle.Position).unit
    Bomb.Velocity = Handle.Velocity + ((Direction + Vector3.new(0, 1, 0)).unit * BOMB_LAUNCH_SPEED)
    Bomb.CanCollide = true
end



--Set up the activated and deactivated events for arming and launching the bomb.
InputHandler.WeaponActivateBegan:Connect(function()
    if Equipped and Tool.Enabled and not CurrentBomb then
        local NextBomb = BombBuffer:PopItem()
        if NextBomb then
            --Stop the current animation.
            if CurrentAnimation then CurrentAnimation:Stop() end

            --Arm the bomb.
            ArmBombEvent:FireServer()
            CurrentBomb = NextBomb
            CurrentBomb.CanCollide = false
            Tool.Enabled = false
            CurrentAnimation = AnimationPlayer:PlayAnimation("BombHold")

            --Weld the bomb to the character.
            CurrentBombWeld = Instance.new("Weld")
            CurrentBombWeld.Name = "BodyWeld"
            CurrentBombWeld.Part0 = Handle
            CurrentBombWeld.Part1 = CurrentBomb
            CurrentBombWeld.Parent = CurrentBomb
            Tool.Grip = CFrame.new(0.623935461,-0.378438532,0,0.848048091,0,0.529919267,0.529919267,0,-0.848048091,0,1,0)
            Handle.Transparency = 1
        end
    end
end)

InputHandler.WeaponActivateEnded:Connect(function(TargetPos)
    if Equipped and CurrentBomb then
        --Stop the current animation.
        if CurrentAnimation then CurrentAnimation:Stop() end

        --Launch the bomb.
        LaunchBomb(CurrentBomb,TargetPos)
        CurrentBomb = nil
        BombReleasedEvent:FireServer()
        CurrentAnimation = AnimationPlayer:PlayAnimation("BombThrow")
        Tool.Grip = CFrame.new(0.0614605024,0,0.920917511,0.974370062,0,-0.224951088,0,1,0,0.224951088,0,0.974370062)
    end
end)

--Set up events for equipping and unequipping.
Tool.Equipped:Connect(function(NewMouse)
    if not Equipped then
        --Update the mouse.
        Equipped = true
        CurrentMouse = NewMouse
        UpdateIcon()
        BeepSound.Volume = 0
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        --Reset the tool and drop the bomb if being held.
        Equipped = false
        if CurrentBomb then CurrentBomb.CanCollide = true end
        CurrentBomb = nil
        if CurrentAnimation then CurrentAnimation:Stop() end
        if CurrentBombWeld then CurrentBombWeld:Destroy() end
        Tool.Grip = CFrame.new(0.0614605024,0,0.920917511,0.974370062,0,-0.224951088,0,1,0,0.224951088,0,0.974370062)
        BeepSound.Volume = 1
    end
end)

--Set up event for tool enabled being changed.
Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)