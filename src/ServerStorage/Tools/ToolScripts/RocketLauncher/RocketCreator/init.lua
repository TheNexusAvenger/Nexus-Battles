--[[
TheNexusAvenger

Creates buffer and non-buffer rockets.
--]]

local RocketCreator = {}

local RocketScript = script:WaitForChild("RocketScript")
local ExplosionCreator = script.Parent:WaitForChild("ExplosionCreator")
local PlayerDamagerScript = script.Parent:WaitForChild("PlayerDamager")
local ConfigurationScript = script.Parent:WaitForChild("Configuration")



--[[
Creates both buffer and non-buffer rockets.
--]]
function RocketCreator:CreateRocket(IsBufferRocket)
    --Create the base parts and mesh.
    local Rocket = Instance.new("Part")
    Rocket.Name = "Rocket"
    Rocket.Size = Vector3.new(1,1,4)
    Rocket.CanCollide = false

    local Mesh = Instance.new("SpecialMesh")
    Mesh.Name = "RocketMesh"
    Mesh.MeshId = "http://www.roblox.com/asset/?id=94690081"
    Mesh.TextureId = "http://www.roblox.com/asset/?id=94689966"
    Mesh.Parent = Rocket

    if IsBufferRocket then
        --If it is a buffer rocket, add the effects, physics, and scripts.
        Mesh.Scale = Vector3.new(2.5,2.5,2)

        local Fire = Instance.new("Fire")
        Fire.Heat = 5
        Fire.Size = 2
        Fire.Parent = Rocket

        local Light = Instance.new("PointLight")
        Light.Name = "Light"
        Light.Color = Color3.new(1,170/255,0)
        Light.Range = 10
        Light.Shadows = true
        Light.Parent = Rocket

        local BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(0,0,0)
        BodyGyro.Parent = Rocket

        local RocketPropulsion = Instance.new("BodyVelocity")
        RocketPropulsion.MaxForce = Vector3.new(0,0,0)
        RocketPropulsion.Parent = Rocket

        local SwooshSound = Instance.new("Sound")
        SwooshSound.Name = "SwooshSound"
        SwooshSound.Looped = true
        SwooshSound.SoundId = "rbxasset://sounds/Rocket whoosh 01.wav"
        SwooshSound.Volume = 1
        SwooshSound.Parent = Rocket

        local NewRocketScript = RocketScript:Clone()
        NewRocketScript.Disabled = false
        NewRocketScript.Parent = Rocket

        ExplosionCreator:Clone().Parent = NewRocketScript
        PlayerDamagerScript:Clone().Parent = NewRocketScript
        ConfigurationScript:Clone().Parent = NewRocketScript
    end

    return Rocket
end



return RocketCreator