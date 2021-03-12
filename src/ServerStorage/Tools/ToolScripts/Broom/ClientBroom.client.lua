--[[
TheNexusAvenger

Handles the client-side broom.
--]]

local TweenService = game:GetService("TweenService")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local SwingSound = Handle:WaitForChild("SwingSound")

local InputHandler = require(Tool:WaitForChild("InputHandler"))
local AnimationPlayer = require(Tool:WaitForChild("AnimationPlayer"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local BROOM_WHACK_SPEED = Configuration.BROOM_WHACK_SPEED

local SwingBroomEvent = RemoteEventCreator:GetRemoteEvent("SwingBroom")

local LocalSwingSound
local CurrentAnimation,CurrentIdleAnimation
local CurrentMouse
local Equipped = false
local SwingVolume = SwingSound.Volume



--[[
Updates the mouse icon.
--]]
local function UpdateIcon()
    if CurrentMouse and Equipped then
        CurrentMouse.Icon = Tool.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
    end
end



--Set up activating the weapon.
InputHandler.WeaponActivated:Connect(function(TargetPos)
    if Equipped and Tool.Enabled then
        SwingBroomEvent:FireServer()
        Tool.Enabled = false

        --Stop the current swing animation.
        if CurrentAnimation then CurrentAnimation:Stop() end

        --Play the swing sound locally.
        LocalSwingSound.Pitch = 1.2 + (math.random() * 0.2)
        LocalSwingSound:Play()
        CurrentAnimation = AnimationPlayer:PlayAnimation("BroomWhack")

        --Extend and retract the broom.
        TweenService:Create(Tool,TweenInfo.new(1/BROOM_WHACK_SPEED),{
            GripPos = Vector3.new(0,2,0)
        }):Play()
        wait(0.5/BROOM_WHACK_SPEED)
        TweenService:Create(Tool,TweenInfo.new(1/BROOM_WHACK_SPEED),{
            GripPos = Vector3.new(0,0,0)
        }):Play()
    end
end)

--Set up equipped and unequipped.
Tool.Equipped:Connect(function(NewMouse)
    if not Equipped then
        Equipped = true
        CurrentMouse = NewMouse
        UpdateIcon()

        --Create local swing sound.
        LocalSwingSound = SwingSound:Clone()
        LocalSwingSound.Parent = Handle
        SwingSound.Volume = 0
        SwingSound:Stop()

        --Play idle animation.
        CurrentIdleAnimation = AnimationPlayer:PlayAnimation("BroomIdle")
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Stop animations.
        if CurrentAnimation then CurrentAnimation:Stop() end
        if CurrentIdleAnimation then CurrentIdleAnimation:Stop() end

        --Destroy local sound.
        if LocalSwingSound then
            LocalSwingSound:Stop()
            LocalSwingSound:Destroy()
            SwingSound.Volume = SwingVolume
        end
    end
end)

Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)