--[[
TheNexusAvenger

Project for fetching resources in ServerScriptService.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NexusProject = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusProject"))



return NexusProject.new(game:GetService("ServerScriptService"))