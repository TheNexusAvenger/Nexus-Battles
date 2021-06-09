--[[
TheNexusAvenger

Runs the server code.
--]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local MapTypes = ReplicatedStorageProject:GetResource("Data.MapTypes")
local GameTypes = ReplicatedStorageProject:GetResource("Data.GameTypes")

local Replication = Instance.new("Folder")
Replication.Name = "Replication"
Replication.Parent = ReplicatedStorage

local LobbySelectionService = ServerScriptServiceProject:GetResource("Service.LobbySelectionService")



--Load the services that don't load immediately.
ServerScriptServiceProject:GetResource("Service.DamageService")
ServerScriptServiceProject:GetResource("Service.LeaderboardService")
ServerScriptServiceProject:GetResource("Service.ShopService")
ServerScriptServiceProject:GetResource("Service.RobuxService")
ServerScriptServiceProject:GetResource("Service.BadgeService")

--Determine if there are any rounds that require 4 or more players.
local RoundWith4PlayersExists = false
for _,MapData in pairs(MapTypes) do
    for _,RoundTypeName in pairs(MapData.GameTypes or {}) do
        local RoundData = GameTypes[RoundTypeName]
        if RoundData.RequiredPlayers and RoundData.RequiredPlayers >= 4 then
            RoundWith4PlayersExists = true
            break
        end
    end
end

--Determine if there are any rounds with RocksVsBazookas exist.
local RocksVsBazookasExists = false
for _,MapData in pairs(MapTypes) do
    for _,RoundTypeName in pairs(MapData.GameTypes or {}) do
        if RoundTypeName == "RocksVsBazookas" then
            RocksVsBazookasExists = true
            break
        end
    end
end

--Initialize the lobby selection parts.
for i = 1,4 do
    coroutine.wrap(function()
        LobbySelectionService:InitializePart(Workspace:WaitForChild("Lobby"):WaitForChild("RoundParts"):WaitForChild("RoundPart"..tostring(i)),function(RoundData)
            --Allow the round with the first 2 slots being non-team rounds and the last round being for teams.
            if i == 3 then
                return (not RoundWith4PlayersExists or RoundData.RequiredPlayers >= 4) and not RoundData.Hidden
            elseif i == 4 then
                return not RocksVsBazookasExists or RoundData.DisplayName == "???"
            else
               return RoundData.RequiredPlayers <= 2 and not RoundData.Hidden
            end
        end)
    end)()
end