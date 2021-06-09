--[[
TheNexusAvenger

Assets in the game that need to be loaded.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")



--[[
Prepares an asset that is an image.
--]]
local function Image(Name,URL)
    local Decal = Instance.new("Decal")
    Decal.Name = Name
    Decal.Texture = URL
    return Decal
end

--[[
Prepares an asset that is a mesh.
--]]
local function Mesh(Name,URL)
    local SpecialMesh = Instance.new("SpecialMesh")
    SpecialMesh.Name = Name
    SpecialMesh.MeshType = Enum.MeshType.FileMesh
    SpecialMesh.MeshId = URL
    return SpecialMesh
end

--[[
Prepares an asset that is a sound.
--]]
local function Sound(Name,URL)
    local Audio = Instance.new("Sound")
    Audio.Name = Name
    Audio.SoundId = URL
    return Audio
end

--[[
Prepares an asset that is an Animation.
--]]
local function Animation(Name,URL)
    local AnimationTrack = Instance.new("Animation")
    AnimationTrack.Name = Name
    AnimationTrack.AnimationId = URL
    return AnimationTrack
end




--Create the base data.
local Assets = {
    --Logo
    Image("Logo Front","rbxassetid://6892136800"),
    Image("Logo Back","rbxassetid://6892136377"),

    --Nexus Button
    Image("Button Corners","rbxassetid://4449507744"),
    Image("Controller Buttons Light","rbxassetid://408462759"),
    Image("Controller Buttons Dark","rbxassetid://408444495"),
    Sound("Button click sound","rbxassetid://421058925"),

    --Local effects
    Image("Juggernaut arrow","rbxassetid://119545962"),
    Sound("Player hit sound","rbxassetid://95522378"),
    Sound("Reflector effect mesh","rbxassetid://94736101"),
    Image("Reflector effect texture","rbxassetid://94735715"),

    --UI
    Sound("Timer tick sound","rbxassetid://156286438"),
    Image("Coin","rbxassetid://121148238"),
    Image("Rank Icons","rbxassetid://6866145490"),

    --Other weapons (not covered in weapon icons)
    Mesh("Rocket Launcher mesh","rbxassetid://94690054"),
    Image("Rocket Launcher texture","rbxassetid://94689966"),
    Image("Red bomb texture","rbxassetid://94691735"),
}

--Add the maps.
for _,MapData in pairs(require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("MapTypes"))) do
    table.insert(Assets,Image("Map Icon","rbxassetid://"..tostring(MapData.ImageId)))
end

--Add the animations.
for AnimationName,Animations in pairs(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Animations"):GetChildren()) do
    table.insert(Assets,Animation("R15 "..AnimationName,Animations[Enum.HumanoidRigType.R15]))
end

--Add the weapon icons.
for _,Weapon in pairs(ReplicatedStorage:WaitForChild("Model"):WaitForChild("WeaponIconModels"):GetChildren()) do
    table.insert(Assets,Weapon)
end

--Return the assets.
return Assets