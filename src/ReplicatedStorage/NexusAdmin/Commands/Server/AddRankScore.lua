--[[
TheNexusAvenger

Data for a command for adding to rank scores.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local StatService = ServerScriptServiceProject:GetResource("Service.StatService")



--Return the command data.
return {
    Keyword = {"addrankscore","addrank","rankscore"},
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to execute on.",
        },
        {
            Type = "integer",
            Name = "RankScore",
            Description = "Rank Score to add.",
        },
    },
    Description = "Gives rank score points to a set of players.",
    Run = function(self,CommandContext,Players,RankScore)
        for _,Player in pairs(Players) do
            StatService:GetPersistentStats(Player):Get("RankScore"):Increment(RankScore)
        end
    end,
}