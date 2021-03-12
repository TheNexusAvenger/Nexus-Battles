--[[
TheNexusAvenger

Runs the client-side slingshot.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local EquipSound = Handle:WaitForChild("EquipSound")
local SlingshotSound1 = Handle:WaitForChild("SlingshotSound1")
local SlingshotSound2 = Handle:WaitForChild("SlingshotSound2")
local SlingshotSound3 = Handle:WaitForChild("SlingshotSound3")

local InputHandler = require(Tool:WaitForChild("InputHandler"))
local AnimationPlayer = require(Tool:WaitForChild("AnimationPlayer"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local SLINGSHOT_LAUNCH_VELOCITY = Configuration.SLINGSHOT_LAUNCH_VELOCITY

local SlingshotBuffer = BufferCreator:CreateClientBuffer("SlingshotBuffer")
local FireSlingshotEvent = RemoteEventCreator:GetRemoteEvent("FireSlingshot")

local LocalEquipSound,LocalSlingshotSound1
local LocalSlingshotSound2,LocalSlingshotSound3
local FireSounds
local CurrentAnimation,CurrentEquipAnimation
local CurrentSlingshotEquipBall
local CurrentMouse
local Equipped = false
local EquipVolume,SlingshotSoundVolume = EquipSound.Volume,SlingshotSound1.Volume
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
Calculates the trajectory
--]]
local function ComputeLaunchAngle(DeltaX,DeltaY,Gravity)
    Gravity = math.abs(Gravity)
    local VelocitySquared = SLINGSHOT_LAUNCH_VELOCITY ^ 2
    local VelocityFourth = SLINGSHOT_LAUNCH_VELOCITY ^ 4

    local InRoot = (VelocityFourth) - (Gravity * ((Gravity * DeltaX * DeltaX) + (2 * DeltaY * VelocitySquared)))
    if InRoot <= 0 then
        return 0.25 * math.pi
    end

    local Root = math.sqrt(InRoot)
    local InATan1 = ((VelocitySquared) + Root) / (Gravity * DeltaX)
    local InATan2 = ((VelocitySquared) - Root) / (Gravity * DeltaX)
    return math.min(math.atan(InATan1),math.atan(InATan2))
end

--[[
Fires a slingshot projectile.
--]]
local function LaunchSlingshotBall(SlingshotBall,TargetPos)
    local Character = Players.LocalPlayer.Character
    if not Character then return end

    local StartPosition = (Tool.Handle.CFrame * CFrame.new(0,1,0)).p
    local Direction = (TargetPos - StartPosition).unit
    local LanchPosition = StartPosition + (3 * Direction)
    local DeltaPosition = TargetPos - LanchPosition
    local DeltaY = DeltaPosition.Y

    local DeltaXZ = Vector3.new(DeltaPosition.X,0,DeltaPosition.Z)
    DeltaPosition = DeltaXZ
    local DeltaX = DeltaPosition.Magnitude
    local UnitDetla = DeltaPosition.Unit
    local Gravity = -Workspace.Gravity

    local Theta = ComputeLaunchAngle(DeltaX,DeltaY,Gravity)
    local VelocityY = math.sin(Theta)
    local AngleXZ = math.cos(Theta)
    local VelocityX = UnitDetla.X * AngleXZ
    local VelocityZ = UnitDetla.Z * AngleXZ


    SlingshotBall.CFrame = CFrame.new(LanchPosition,LanchPosition + Vector3.new(VelocityX,VelocityY,VelocityZ))
    SlingshotBall.Velocity = Vector3.new(VelocityX,VelocityY,VelocityZ) * SLINGSHOT_LAUNCH_VELOCITY
end



--Set up activated event.
InputHandler.WeaponActivated:Connect(function(TargetPos)
    if Equipped and Tool.Enabled then
        local NextSlingshotBall = SlingshotBuffer:PopItem()
        if NextSlingshotBall then
            local CurrentTime = tick()
            LastReloadTime = CurrentTime
            if CurrentAnimation then CurrentAnimation:Stop() end

            --Play the fire animation and play a random sound.
            FireSlingshotEvent:FireServer()
            Tool.Enabled = false
            CurrentAnimation = AnimationPlayer:PlayAnimation("SlingshotShoot")
            if FireSounds then FireSounds[math.random(1,#FireSounds)]:Play() end

            --Fire the slingshot and hide the hand version.
            LaunchSlingshotBall(NextSlingshotBall,TargetPos)
            if CurrentSlingshotEquipBall then
                CurrentSlingshotEquipBall.Transparency = 1
            end
        end
    end
end)

--Set up equipped and unequipped animations.
Tool.Equipped:Connect(function(NewMouse)
    if not Equipped then
        Equipped = true
        CurrentMouse = NewMouse
        UpdateIcon()

        --Make local sounds.
        LocalEquipSound = EquipSound:Clone()
        LocalEquipSound.Parent = Handle
        LocalEquipSound:Play()
        EquipSound.Volume = 0
        EquipSound:Stop()

        LocalSlingshotSound1 = SlingshotSound1:Clone()
        LocalSlingshotSound1.Parent = Handle
        SlingshotSound1.Volume = 0
        SlingshotSound1:Stop()

        LocalSlingshotSound2 = SlingshotSound2:Clone()
        LocalSlingshotSound2.Parent = Handle
        SlingshotSound2.Volume = 0
        SlingshotSound2:Stop()

        LocalSlingshotSound3 = SlingshotSound3:Clone()
        LocalSlingshotSound3.Parent = Handle
        SlingshotSound3.Volume = 0
        SlingshotSound3:Stop()

        FireSounds = {
            LocalSlingshotSound1,
            LocalSlingshotSound2,
            LocalSlingshotSound3,
        }

        --Play the equip animation.
        CurrentSlingshotEquipBall = Tool:FindFirstChild("HandSlingshotBall")
        CurrentEquipAnimation = AnimationPlayer:PlayAnimation("SlingshotEquip")
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false
        CurrentSlingshotEquipBall = nil

        --Stop the animations.
        if CurrentAnimation then CurrentAnimation:Stop() end
        if CurrentEquipAnimation then CurrentEquipAnimation:Stop() end

        --Remove the local sounds.
        if LocalEquipSound then
            LocalEquipSound:Stop()
            LocalEquipSound:Destroy()
            EquipSound.Volume = EquipVolume
        end

        FireSounds=  nil
        if LocalSlingshotSound1 then
            LocalSlingshotSound1:Stop()
            LocalSlingshotSound1:Destroy()
            SlingshotSound1.Volume = SlingshotSoundVolume
        end

        if LocalSlingshotSound2 then
            LocalSlingshotSound2:Stop()
            LocalSlingshotSound2:Destroy()
            SlingshotSound2.Volume = SlingshotSoundVolume
        end

        if LocalSlingshotSound3 then
            LocalSlingshotSound3:Stop()
            LocalSlingshotSound3:Destroy()
            SlingshotSound3.Volume = SlingshotSoundVolume
        end
    end
end)

Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)