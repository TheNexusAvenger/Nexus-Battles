--[[
TheNexusAvenger

Project for fetching resources in ReplicatedStorage.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NexusProject = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusProject"))



--Create the project.
local Project = NexusProject.new(ReplicatedStorage)

--Load the round types.
for _,RoundData in pairs(Project:GetResource("Data.GameTypes")) do
    Project:GetResource(RoundData.RoundClass)
end

--Initialize Nexus Round System's global container.
Project:GetResource("NexusRoundSystem"):GetObjectReplicator():GetGlobalContainer()

--Return the project.
return Project