--[[
TheNexusAvenger

Icon for displaying an armor item.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local ArmorIcon = ReplicatedStorageProject:GetResource("UI.Icon.Base3DIcon"):Extend()
ArmorIcon:SetClassName("WeaponIcon")



--[[
Creates the armor icon.
--]]
function ArmorIcon:__new(WeaponName)
    self:InitializeSuper(ReplicatedStorageProject:GetResource("Model.MeshDeformationArmorModels."..tostring(WeaponName)):Clone())
    self.RotationOffset = CFrame.Angles(0,0,math.rad(20))
end



return ArmorIcon