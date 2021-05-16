--[[
TheNexusAvenger

Runs the server code.
--]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local GameTypes = ReplicatedStorageProject:GetResource("Data.GameTypes")

local Replication = Instance.new("Folder")
Replication.Name = "Replication"
Replication.Parent = ReplicatedStorage

local LobbySelectionService = ServerScriptServiceProject:GetResource("Service.LobbySelectionService")



--Load the services that don't load immediately.
ServerScriptServiceProject:GetResource("Service.DamageService")

--Determine if there are any rounds that require 4 or more players.
local RoundWith4PlayersExists = false
for _,RoundData in pairs(GameTypes) do
    if RoundData.RequiredPlayers and RoundData.RequiredPlayers >= 4 then
        RoundWith4PlayersExists = true
        break
    end
end

--Initialize the lobby selection parts.
for i = 1,3 do
    coroutine.wrap(function()
        LobbySelectionService:InitializePart(Workspace:WaitForChild("RoundPart"..tostring(i)),function(RoundData)
            --Allow the round with the first 2 slots being non-team rounds and the last round being for teams.
            if i == 3 then
                return not RoundWith4PlayersExists or RoundData.RequiredPlayers >= 4
            else
               return RoundData.RequiredPlayers <= 2
            end
        end)
    end)()
end