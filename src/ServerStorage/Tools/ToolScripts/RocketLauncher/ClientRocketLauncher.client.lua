--[[
TheNexusAvenger

Runs the client-side rocket launcher.
--]]

local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local EquipSound = Handle:WaitForChild("EquipSound")
local ReloadSound = Handle:WaitForChild("ReloadSound")

local InputHandler = require(Tool:WaitForChild("InputHandler"))
local AnimationPlayer = require(Tool:WaitForChild("AnimationPlayer"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local IGNORE_LIST = Configuration.IGNORE_LIST
local ROCKET_RELOAD_WAIT_TO_SHOW_TIME = Configuration.ROCKET_RELOAD_WAIT_TO_SHOW_TIME
local ROCKET_RELOAD_VISIBLE_TIME = Configuration.ROCKET_RELOAD_VISIBLE_TIME
local ROCKET_LAUNCH_SPEED = Configuration.ROCKET_LAUNCH_SPEED

local RocketBuffer = BufferCreator:CreateClientBuffer("RocketBuffer")
local FireRocketEvent = RemoteEventCreator:GetRemoteEvent("FireRocket")

local LocalEquipSound,LocalReloadSound
local CurrentAnimation,CurrentHandRocket
local CurrentMouse
local Equipped = false
local EquipVolume,ReloadVolume = EquipSound.Volume,ReloadSound.Volume
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
Launches a rocket.
--]]
local function LaunchRocket(Rocket,TargetPos)
    local Character = Players.LocalPlayer.Character
    local SpawnPosition = Handle.Position + (Handle.CFrame.lookVector * (Handle.Size.Z/2))
    local BodyVelocity = Rocket:FindFirstChild("BodyVelocity")
    local BodyGyro = Rocket:FindFirstChild("BodyGyro")
    local ExplodeEvent = Rocket:FindFirstChild("Explode")
    Rocket.Velocity = Vector3.new(0,0,0)
    Rocket.CFrame = CFrame.new(SpawnPosition,TargetPos)

    --Set the velocity and direction.
    if BodyVelocity and BodyGyro then
        local Direction = (TargetPos - SpawnPosition).unit
        BodyVelocity.Velocity = Direction * ROCKET_LAUNCH_SPEED
        BodyVelocity.MaxForce = Vector3.new(10^99,10^99,10^99)
        BodyGyro.CFrame = CFrame.new(Vector3.new(0,0,0),Direction)
        BodyGyro.MaxTorque = Vector3.new(10^99,10^99,10^99)
    end

    --Fire the event when touched.
    if ExplodeEvent then
        Rocket.Touched:Connect(function(TouchPart)
            if not IGNORE_LIST[string.lower(TouchPart.Name)] and not TouchPart:IsDescendantOf(Character) then
                ExplodeEvent:FireServer(Rocket.Position)
            end
        end)
    end
end



--Set up activated event.
InputHandler.WeaponActivated:Connect(function(TargetPos)
    if Equipped and Tool.Enabled then
        local NextRocket = RocketBuffer:PopItem()
        if NextRocket then
            local CurrentTime = tick()
            LastReloadTime = CurrentTime
            if CurrentAnimation then CurrentAnimation:Stop() end

            --Laucn the rocket.
            FireRocketEvent:FireServer()
            Tool.Enabled = false
            CurrentAnimation = AnimationPlayer:PlayAnimation("RocketLauncherFireAndReload")
            LaunchRocket(NextRocket,TargetPos)

            --Run the reload animation.
            CurrentHandRocket = Tool:FindFirstChild("HandRocket",true)
            if LocalReloadSound then
                LocalReloadSound:Play()
            end

            wait(ROCKET_RELOAD_WAIT_TO_SHOW_TIME)
            if LastReloadTime ~= CurrentTime then return end
            if CurrentHandRocket then
                CurrentHandRocket.Transparency = 0
                CurrentHandRocket.LocalTransparencyModifier = 0
            end
            wait(ROCKET_RELOAD_VISIBLE_TIME)
            if LastReloadTime ~= CurrentTime then return end
            if CurrentHandRocket then
                CurrentHandRocket.Transparency = 1
                CurrentHandRocket.LocalTransparencyModifier = 1
            end
        end
    end
end)

--Set up equipped and unequipped event.
Tool.Equipped:Connect(function(NewMouse)
    if not Equipped then
        Equipped = true
        CurrentMouse = NewMouse
        UpdateIcon()

        --Create the local equip sound.
        LocalEquipSound = EquipSound:Clone()
        LocalEquipSound.Parent = Handle
        LocalEquipSound:Play()
        EquipSound.Volume = 0
        EquipSound:Stop()

        --Create the local reload sound.
        LocalReloadSound = ReloadSound:Clone()
        LocalReloadSound.Parent = Handle
        ReloadSound.Volume = 0
        ReloadSound:Stop()
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false
        CurrentHandRocket = nil
        if CurrentAnimation then CurrentAnimation:Stop() end

        --Remove the local sounds.
        if LocalEquipSound then
            LocalEquipSound:Stop()
            LocalEquipSound:Destroy()
            EquipSound.Volume = EquipVolume
        end

        if LocalReloadSound then
            LocalReloadSound:Stop()
            LocalReloadSound:Destroy()
            ReloadSound.Volume = ReloadVolume
        end
    end
end)

Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)