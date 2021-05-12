--[[
TheNexusAvenger

Icon for displaying a weapon.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local WeaponIcon = ReplicatedStorageProject:GetResource("UI.Icon.Base3DIcon"):Extend()
WeaponIcon:SetClassName("WeaponIcon")



--[[
Creates the base 3D icon.
--]]
function WeaponIcon:__new(WeaponName)
    self:InitializeSuper(ReplicatedStorageProject:GetResource("Model.WeaponIconModels."..tostring(WeaponName)):Clone())
    self.RotationOffset = CFrame.Angles(0,0,math.rad(40))
end



return WeaponIcon