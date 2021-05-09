--[[
TheNexusAvenger

Effect for reflecting projectiles locally.
--]]

local EFFECT_DURATION = 0.6
local EFFECT_TIME_DELAY = 0.2
local END_MESH_RADIUS = 10
local REFLECT_RADIUS = Vector3.new(20,20,20)

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")



--[[
Reflects proctiles and sets the target to the sender.
--]]
local function ReflectProjectiles(Handle,Center)
    if not Handle.Parent then return end
    local Character = Handle.Parent.Parent
    local Player = Players:GetPlayerFromCharacter(Character)

    --Reflect the parts.
    local Parts = Workspace:FindPartsInRegion3(Region3.new(Center - REFLECT_RADIUS,Center + REFLECT_RADIUS),Character,100)
    for _,Projectile in pairs(Parts) do
        local FiredByValue = Projectile:FindFirstChild("FiredBy")
        if FiredByValue and FiredByValue.Value and not Projectile:FindFirstChild("BodyWeld") then
            --Determine the last 2 relevant tags.
            local LastTag,CurrentTag = nil,FiredByValue
            while CurrentTag:FindFirstChild("ReflectedBy") do
                LastTag = CurrentTag
                CurrentTag = CurrentTag:FindFirstChild("ReflectedBy")
            end
            local CurrentLocallyReflected = CurrentTag:FindFirstChild("LocallyReflected")

            --Reflect the part if the projectile was shot or reflected by someone else.
            if (CurrentTag.Value ~= Player) or (LastTag and CurrentLocallyReflected and CurrentTag.Value == Player and LastTag.Value ~= Player and not CurrentLocallyReflected.Value) then
                if CurrentLocallyReflected then CurrentLocallyReflected.Value = true end
                local TargetPlayer = (LastTag and LastTag.Value ~= Player and LastTag.Value) or CurrentTag.Value
                if TargetPlayer.Character then
                    local SourceHumanoidRootPart = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if SourceHumanoidRootPart then
                        local SourcePos = SourceHumanoidRootPart.Position
                        local NewStartPos = Projectile.Position
                        local NewCF = CFrame.new(NewStartPos,SourcePos)
                        local NewDirection = NewCF.LookVector.Unit
                        local Velocity = Projectile.AssemblyLinearVelocity.Magnitude
                        Projectile.CFrame = NewCF
                        Projectile.AssemblyLinearVelocity = NewDirection * Velocity

                        for _,Ins in pairs(Projectile:GetChildren()) do
                            if Ins:IsA("BodyVelocity") then
                                Ins.Velocity = NewDirection * Velocity
                            elseif Ins:IsA("BodyGyro") then
                                Ins.CFrame = NewCF
                            end
                        end
                    end
                end
            end
        end
    end
end



return function (ReflectorHandle)
    local ActivateSound = ReflectorHandle:WaitForChild("ActivateSound")

    --Create the effect.
    local SphereEffect = Instance.new("Part")
    SphereEffect.CanCollide = false
    SphereEffect.Anchored = true
    SphereEffect.Transparency = 1
    SphereEffect.Shape = "Ball"
    SphereEffect.Size = Vector3.new(0.2,0.2,0.2)
    SphereEffect.CFrame = CFrame.new(ReflectorHandle.Position)
    SphereEffect.TopSurface = "Smooth"
    SphereEffect.BottomSurface  = "Smooth"
    SphereEffect.Name = "Reflector"
    SphereEffect.BrickColor = BrickColor.new("Cyan")
    SphereEffect.Transparency = 1
    SphereEffect.Parent = Workspace
    Debris:AddItem(SphereEffect,EFFECT_DURATION + EFFECT_TIME_DELAY)

    local SphereMesh = Instance.new("SpecialMesh")
    SphereMesh.MeshType = "FileMesh"
    SphereMesh.MeshId = "http://www.roblox.com/asset/?id=94736101"
    SphereMesh.TextureId = "http://www.roblox.com/asset/?id=94735715"
    SphereMesh.VertexColor=Vector3.new(1,1,1)
    SphereMesh.Scale = Vector3.new(0.1,0.1,0.1)
    SphereMesh.Parent = SphereEffect

    wait(EFFECT_TIME_DELAY)
    SphereEffect.Transparency = 0
    if not ActivateSound.Playing then ActivateSound:Play() end

    --Reflect projectiles.
    local StartTime = time()
    local CenterPos = ReflectorHandle.Position
    while time() - StartTime < EFFECT_DURATION do
        local Ratio = (time() - StartTime)/EFFECT_DURATION
        local MeshRadius = Ratio * END_MESH_RADIUS

        SphereEffect.CFrame = CFrame.new(CenterPos)
        ReflectProjectiles(ReflectorHandle,CenterPos)
        SphereMesh.Scale = Vector3.new(MeshRadius,MeshRadius,MeshRadius)
        SphereEffect.Transparency = Ratio
        RunService.RenderStepped:Wait()
    end
end