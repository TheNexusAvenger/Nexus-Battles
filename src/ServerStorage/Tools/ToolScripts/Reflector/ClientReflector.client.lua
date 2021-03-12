--[[
TheNexusAvenger

Runs the client-side reflector.
--]]

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputHandler = require(Tool:WaitForChild("InputHandler"))
local AnimationPlayer = require(Tool:WaitForChild("AnimationPlayer"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local ActivateReflectorEvent = RemoteEventCreator:GetRemoteEvent("ActivateReflector")

local CurrentAnimation
local CurrentMouse
local Equipped = false



--[[
Updates the mouse icon.
--]]
local function UpdateIcon()
    if CurrentMouse and Equipped then
        CurrentMouse.Icon = Tool.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
    end
end



--Set up the activated event.
InputHandler.WeaponActivated:Connect(function(TargetPos)
    if Equipped and Tool.Enabled then
        ActivateReflectorEvent:FireServer()
        Tool.Enabled = false

        --Run the weapon an animation.
        CurrentAnimation = AnimationPlayer:PlayAnimation("ReflectorActivate")
    end
end)

--Set up the equipped and unequipped animations.
Tool.Equipped:Connect(function(NewMouse)
    if not Equipped then
        Equipped = true
        CurrentMouse = NewMouse
        UpdateIcon()

        --Enable the tool of equip if possible.
        if Tool.Enabled then
            CurrentAnimation = AnimationPlayer:PlayAnimation("ReflectorActivate")
        end
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Stop the current animation.
        if CurrentAnimation then CurrentAnimation:Stop() end
    end
end)

Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)