--[[
TheNexusAvenger

Data for a command for creating rounds.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local NexusReplication = ReplicatedStorageProject:GetResource("External.NexusReplication")
local ActiveRounds = NexusReplication:GetGlobalContainer():WaitForChildBy("Name","ActiveRounds")
local RoundService = ServerScriptServiceProject:GetResource("Service.RoundService")
local CharacterService = ServerScriptServiceProject:GetResource("Service.CharacterService")



--Return the command data.
return {
    Keyword = {"testround","createround"},
    Arguments = {
        {
            Type = "roundType",
            Name = "Round",
            Description = "Round type to use.",
            Optional = true,
        },
        {
            Type = "mapType",
            Name = "Map",
            Description = "Mape type to use.",
            Optional = true,
        },
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players execute on.",
            Optional = true,
        },
    },
    Description = "Dumps the replicated objects of Nexus Round System in the server output.",
    Run = function(self,CommandContext,RoundType,MapType,Players)
        MapType = MapType or "Bloxburg"
        RoundType = RoundType or "FreeForAll"
        Players = Players or {CommandContext.Executor}

        --Remove the players from the existing rounds.
        for _,Round in pairs(ActiveRounds:GetChildren()) do
            for _,Player in pairs(Players) do
                if Round.Players:Contains(Player) then
                    Round.Players:Remove(Player)
                end
                if Round.Spectators:Contains(Player) then
                    Round.Spectators:Remove(Player)
                end
            end
        end

        --Despawn the players.
        for _,Player in pairs(Players) do
            CharacterService:DespawnCharacter(Player)
        end

        --Start the new round.
        RoundService:StartRound(RoundType,MapType,Players)
    end,
}