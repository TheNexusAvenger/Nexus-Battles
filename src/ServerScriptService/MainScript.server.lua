--[[
TheNexusAvenger

Runs the server code.
--]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local Replication = Instance.new("Folder")
Replication.Name = "Replication"
Replication.Parent = ReplicatedStorage

local LobbySelectionService = ServerScriptServiceProject:GetResource("Service.LobbySelectionService")



--Load the services that don't load immediately.
ServerScriptServiceProject:GetResource("Service.LocalEffectService")
ServerScriptServiceProject:GetResource("Service.StatService")

--Initialize the lobby selection parts.
for i = 1,3 do
    coroutine.wrap(function()
		LobbySelectionService:InitializePart(Workspace:WaitForChild("RoundPart"..tostring(i)))
	end)()
end