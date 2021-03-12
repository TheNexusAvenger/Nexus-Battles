--[[
TheNexusAvenger

Players local effects on the client.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local PlayLocalEffect = ReplicatedStorageProject:GetResource("Replication.LocalEffect.PlayLocalEffect")



--Connect playing local effects.
PlayLocalEffect.OnClientEvent:Connect(function(Name,...)
    ReplicatedStorageProject:GetResource("LocalEffect."..tostring(Name))(...)
end)