--[[
TheNexusAvenger

Creates buffer superball projectiles.
--]]

local SuperballCreator = {}

local Workspace = game:GetService("Workspace")

local Tool = script.Parent
local SuperballScript = script:WaitForChild("SuperballScript")
local PlayerDamagerScript = Tool:WaitForChild("PlayerDamager")
local ConfigurationScript = Tool:WaitForChild("Configuration")


--[[
Creates a server superball.
--]]
function SuperballCreator:CreateSuperball()
    --Craete the base parts.
    local Superball = Instance.new("Part")
    Superball.Reflectance = 0.2
    Superball.Name = "Superball"
    Superball.Size = Vector3.new(2,2,2)
    Superball.CustomPhysicalProperties = PhysicalProperties.new(0.7,0,1,1,1)
    Superball.TopSurface = "Smooth"
    Superball.BottomSurface = "Smooth"

    local Mesh = Instance.new("SpecialMesh")
    Mesh.Name = "SuperballMesh"
    Mesh.Scale = Vector3.new(2,2,2)
    Mesh.MeshId = "http://www.roblox.com/asset/?id=96501868"
    Mesh.TextureId = "http://www.roblox.com/asset/?id=96502130"
    Mesh.Parent = Superball

    --Decrease the effect of gravity.
    local FloatForce = Instance.new("BodyForce")
    FloatForce.Force = Vector3.new(0,Superball:GetMass() * Workspace.Gravity * 0.5,0)
    FloatForce.Name = "FloatForce"
    FloatForce.Parent = Superball

    --Add the sound.
    local BoingSound = Instance.new("Sound")
    BoingSound.Name = "BoingSound"
    BoingSound.SoundId = "http://www.roblox.com/Asset?ID=96543718"
    BoingSound.Volume = 0.5
    BoingSound.Parent = Superball

    --Add the scripts.
    local NewSuperballScript = SuperballScript:Clone()
    NewSuperballScript.Disabled = false
    NewSuperballScript.Parent = Superball

    PlayerDamagerScript:Clone().Parent = NewSuperballScript
    ConfigurationScript:Clone().Parent = NewSuperballScript
    return Superball
end



return SuperballCreator