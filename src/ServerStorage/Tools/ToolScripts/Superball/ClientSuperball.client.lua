--[[
TheNexusAvenger

Runs the client-side superball.
--]]

local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local HandleMesh = Handle:WaitForChild("Mesh")
local EquipSound = Handle:WaitForChild("EquipSound")
local ThrowSound = Handle:WaitForChild("ThrowSound")

local InputHandler = require(Tool:WaitForChild("InputHandler"))
local AnimationPlayer = require(Tool:WaitForChild("AnimationPlayer"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local SUPERBALL_LAUCNH_DELAY = Configuration.SUPERBALL_LAUCNH_DELAY
local SUPERBALL_LAUCNH_VELOCITY = Configuration.SUPERBALL_LAUCNH_VELOCITY

local SuperballBuffer = BufferCreator:CreateClientBuffer("SuperballBuffer")
local FireSuperballEvent = RemoteEventCreator:GetRemoteEvent("FireSuperball")

local LocalEquipSound,LocalThrowSound
local CurrentAnimation,CurrentIdleAnimation
local CurrentEquipAnimation
local CurrentMouse
local Equipped = false
local EquipVolume,ThrowVolume = EquipSound.Volume,ThrowSound.Volume
local LastReloadTime = 0



--[[
Updates the mouse icon.
--]]
local function UpdateIcon()
    if CurrentMouse and Equipped then
        CurrentMouse.Icon = Tool.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
    end
end

--[[
Launches a superball.
--]]
local function LaunchSuperball(Superball,TargetPos)
    local Character = Players.LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    local SpawnCF = Handle.CFrame + Handle.CFrame:vectorToWorldSpace(Vector3.new(0,0,-2.1))
    local LaunchCF = CFrame.new(SpawnCF.p,TargetPos)
    Superball.CFrame = LaunchCF
    Superball.Velocity = LaunchCF.LookVector * SUPERBALL_LAUCNH_VELOCITY
end



--Set up the activated event.
InputHandler.WeaponActivated:Connect(function(TargetPos)
    if Equipped and Tool.Enabled then
        local NextSuperball = SuperballBuffer:PopItem()
        if NextSuperball then
            local CurrentTime = tick()
            LastReloadTime = CurrentTime
            if CurrentAnimation then CurrentAnimation:Stop() end
            NextSuperball:WaitForChild("SuperballMesh").VertexColor = HandleMesh.VertexColor

            --Launch the superball.
            FireSuperballEvent:FireServer()
            Tool.Enabled = false
            CurrentAnimation = AnimationPlayer:PlayAnimation("SuperballThrow")
            delay(SUPERBALL_LAUCNH_DELAY,function()
                --Actually launch the superball after a delay in the animation.
                LaunchSuperball(NextSuperball,TargetPos)
                if LastReloadTime == CurrentTime then
                    Handle.Transparency = 1
                end
            end)
        end
    end
end)

--Set up equipped and unequipped animations.
Tool.Equipped:Connect(function(NewMouse)
    if not Equipped then
        Equipped = true
        CurrentMouse = NewMouse
        UpdateIcon()

        --Create local sounds.
        LocalEquipSound = EquipSound:Clone()
        LocalEquipSound.Parent = Handle
        LocalEquipSound:Play()
        EquipSound.Volume = 0
        EquipSound:Stop()

        LocalThrowSound = ThrowSound:Clone()
        LocalThrowSound.Parent = Handle
        ThrowSound.Volume = 0
        ThrowSound:Stop()

        --Play the equip and idle animations.
        CurrentEquipAnimation = AnimationPlayer:PlayAnimation("SuperballEquip")
        delay(0.75,function()
            if Equipped then
                CurrentIdleAnimation = AnimationPlayer:PlayAnimation("SuperballIdle")
            end
        end)
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Stop animations.
        if CurrentAnimation then CurrentAnimation:Stop() end
        if CurrentIdleAnimation then CurrentIdleAnimation:Stop() end
        if CurrentEquipAnimation then CurrentEquipAnimation:Stop() end

        --Destroy local sounds.
        if LocalEquipSound then
            LocalEquipSound:Stop()
            LocalEquipSound:Destroy()
            EquipSound.Volume = EquipVolume
        end

        if LocalThrowSound then
            LocalThrowSound:Stop()
            LocalThrowSound:Destroy()
            ThrowSound.Volume = ThrowVolume
        end
    end
end)

Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)