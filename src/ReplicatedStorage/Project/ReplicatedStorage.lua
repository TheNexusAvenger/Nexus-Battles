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
local NexusRoundSystem = Project:GetResource("NexusRoundSystem")
NexusRoundSystem:GetObjectReplicator():GetGlobalContainer()



--[[
Clears the project after testing.
--]]
function Project:Clear()
    NexusRoundSystem:ClearInstances()
end



--Return the project.
return Project