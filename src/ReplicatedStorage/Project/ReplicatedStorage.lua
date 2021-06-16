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

--Initialize Nexus Replication's global container.
local NexusReplication = Project:GetResource("External.NexusReplication")
NexusReplication:GetObjectReplicator():GetGlobalContainer()



--[[
Clears the project after testing.
--]]
function Project:Clear()
    NexusReplication:ClearInstances()
end



--Return the project.
return Project