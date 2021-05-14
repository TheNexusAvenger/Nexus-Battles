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
ServerScriptServiceProject:GetResource("Service.DamageService")

--Initialize the lobby selection parts.
for i = 1,3 do
    coroutine.wrap(function()
        LobbySelectionService:InitializePart(Workspace:WaitForChild("RoundPart"..tostring(i)),function(RoundData)
            --Allow the round with the first 2 slots being non-team rounds and the last round being for teams.
            if i == 3 then
                return RoundData.RequiredPlayers >= 4
            else
               return RoundData.RequiredPlayers <= 2
            end
        end)
    end)()
end