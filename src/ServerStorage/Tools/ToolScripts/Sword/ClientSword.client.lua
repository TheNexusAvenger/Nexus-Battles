--[[
TheNexusAvenger

Runs the client-side sword.
--]]

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local UnsheathSound = Handle:WaitForChild("UnsheathSound")
local SlashSound = Handle:WaitForChild("SlashSound")
local LungeSound = Handle:WaitForChild("LungeSound")
local OverheadSound = Handle:WaitForChild("OverheadSound")

local InputHandler = require(Tool:WaitForChild("InputHandler"))
local AnimationPlayer = require(Tool:WaitForChild("AnimationPlayer"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))

local SwingSwordEvent = RemoteEventCreator:GetRemoteEvent("SwingSword")
local Debris = game:GetService("Debris")

local LocalUnsheathSound,LocalSlashSound
local LocalLungeSound,LocalOverheadSound
local CurrentAnimation,CurrentEquipAnimation,CurrentIdleAnimation
local CurrentUnequipAnimation
local CurrentMouse
local Equipped = false
local UnsheathVolume,SlashVolume = UnsheathSound.Volume,SlashSound.Volume
local LungeVolume,OverheadVolume = LungeSound.Volume,OverheadSound.Volume
local CurrentSwordState = 1
local LastAnimationTime = 0



--[[
Updates the mouse icon.
--]]
local function UpdateIcon()
    if CurrentMouse and Equipped then
        CurrentMouse.Icon = Tool.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
    end
end

--[[
Sets the sword to an up position.
--]]
local function SwordUp()
    Tool.GripForward = Vector3.new(1,0,0)
    Tool.GripRight = Vector3.new(0,0,1)
    Tool.GripUp = Vector3.new(0,1,0)
end

--[[
Sets the sword to an out position.
--]]
local function SwordOut()
    Tool.GripForward = Vector3.new(0,-1,0)
    Tool.GripRight = Vector3.new(0,0,1)
    Tool.GripUp = Vector3.new(-1,0,0)
end



--Set up the activated events.
InputHandler.WeaponActivated:Connect(function(TargetPos)
    if Equipped and Tool.Enabled then
        --Send the animation type to the server.
        SwingSwordEvent:FireServer(CurrentSwordState)
        Tool.Enabled = false

        local CurrentTime = tick()
        if CurrentTime - LastAnimationTime > 1.5 then
            CurrentSwordState = 1
        end
        LastAnimationTime = CurrentTime

        if CurrentAnimation then CurrentAnimation:Stop() end

        --Play the current animation.
        if CurrentSwordState == 1 then
            CurrentSwordState = 2
            CurrentAnimation = AnimationPlayer:PlayAnimation("SwordSlash")

            LocalSlashSound:Play()
        elseif CurrentSwordState == 2 then
            CurrentSwordState = 3
            CurrentAnimation = AnimationPlayer:PlayAnimation("SwordThrust")

            LocalLungeSound:Play()
            wait(0.45)
            if LastAnimationTime ~= CurrentTime then return end
            SwordOut()
            wait(0.2)
            if LastAnimationTime ~= CurrentTime then return end
            SwordUp()
        else
            CurrentSwordState = 1
            CurrentAnimation = AnimationPlayer:PlayAnimation("SwordOverhead")

            LocalOverheadSound:Play()
            local UpwardForce = Instance.new("BodyVelocity")
            UpwardForce.Velocity = Vector3.new(0,10,0)
            UpwardForce.MaxForce = Vector3.new(0,4000,0)
            Debris:AddItem(UpwardForce,0.5)
            UpwardForce.Parent = Tool.Parent:FindFirstChild("HumanoidRootPart")

            LocalOverheadSound:Play()
        end
    end
end)



--Set up equip and unequip animations.
Tool.Equipped:Connect(function(NewMouse)
    if not Equipped then
        Equipped = true
        CurrentMouse = NewMouse
        UpdateIcon()

        --Create local sounds, and play equip sound.
        LocalUnsheathSound = UnsheathSound:Clone()
        LocalUnsheathSound.Parent = Handle
        delay(0.55,function()
            if Equipped and LocalUnsheathSound then
                LocalUnsheathSound:Play()
            end
        end)
        UnsheathSound.Volume = 0
        UnsheathSound:Stop()

        LocalSlashSound = SlashSound:Clone()
        LocalSlashSound.Parent = Handle
        SlashSound.Volume = 0
        SlashSound:Stop()

        LocalLungeSound = LungeSound:Clone()
        LocalLungeSound.Parent = Handle
        LungeSound.Volume = 0
        LungeSound:Stop()

        LocalOverheadSound = OverheadSound:Clone()
        LocalOverheadSound.Parent = Handle
        OverheadSound.Volume = 0
        OverheadSound:Stop()

        --Play the equip and idle animations.
        if CurrentUnequipAnimation then CurrentUnequipAnimation:Stop() end
        CurrentEquipAnimation = AnimationPlayer:PlayAnimation("SwordEquip")
        delay(1,function()
            if Equipped then
                CurrentIdleAnimation = AnimationPlayer:PlayAnimation("SwordIdle")
            end
        end)
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Stop the animations.
        if CurrentAnimation then CurrentAnimation:Stop() end
        if CurrentIdleAnimation then CurrentIdleAnimation:Stop() end
        if CurrentEquipAnimation then CurrentEquipAnimation:Stop() end
        CurrentUnequipAnimation = AnimationPlayer:PlayAnimation("SwordUnequip")

        --Destroy the local sounds.
        if LocalUnsheathSound then
            LocalUnsheathSound:Stop()
            LocalUnsheathSound:Destroy()
            UnsheathSound.Volume = UnsheathVolume
        end

        if LocalSlashSound then
            LocalSlashSound:Stop()
            LocalSlashSound:Destroy()
            SlashSound.Volume = SlashVolume
        end

        if LocalLungeSound then
            LocalLungeSound:Stop()
            LocalLungeSound:Destroy()
            LungeSound.Volume = LungeVolume
        end

        if LocalOverheadSound then
            LocalOverheadSound:Stop()
            LocalOverheadSound:Destroy()
            OverheadSound.Volume = OverheadVolume
        end

        --Reset the sword position.
        SwordUp()
    end
end)

Tool:GetPropertyChangedSignal("Enabled"):Connect(UpdateIcon)