--[[
TheNexusAvenger

Creates bomb objects.
--]]

local BombCreator = {}

local Tool = script.Parent

local BombScript = script:WaitForChild("BombScript")
local PlayerDamagerScript = Tool:WaitForChild("PlayerDamager")
local ConfigurationScript = Tool:WaitForChild("Configuration")
local ExplosionCreatorScript = Tool:WaitForChild("ExplosionCreator")



--Creates a bomb.
function BombCreator:CreateBomb()
    local Bomb = Instance.new("Part")
    Bomb.Name = "Bomb"
    Bomb.BottomSurface = "Smooth"
    Bomb.TopSurface = "Smooth"
    Bomb.Shape = "Ball"
    Bomb.Size = Vector3.new(2,2,2)

    local Light = Instance.new("PointLight")
    Light.Name = "Light"
    Light.Color = Color3.new(1,0,0)
    Light.Range = 10
    Light.Shadows = true
    Light.Enabled = false
    Light.Parent = Bomb

    local BombMesh = Instance.new("SpecialMesh")
    BombMesh.MeshId = "http://www.roblox.com/asset/?id=94691640"
    BombMesh.TextureId = "http://www.roblox.com/asset/?id=94691681"
    BombMesh.Scale = Vector3.new(2,2,2)
    BombMesh.Name = "BombMesh"
    BombMesh.Parent = Bomb

    local BeepSound = Instance.new("Sound")
    BeepSound.Name = "BeepSound"
    BeepSound.SoundId = "http://www.roblox.com/asset/?id=94137771"
    BeepSound.Volume = 1
    BeepSound.Parent = Bomb

    local NewBombScript = BombScript:Clone()
    NewBombScript.Disabled = false
    NewBombScript.Parent = Bomb

    PlayerDamagerScript:Clone().Parent = NewBombScript
    ConfigurationScript:Clone().Parent = NewBombScript
    ExplosionCreatorScript:Clone().Parent = NewBombScript

    return Bomb
end



return BombCreator