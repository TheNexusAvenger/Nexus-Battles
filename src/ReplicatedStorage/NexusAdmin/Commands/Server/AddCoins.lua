--[[
TheNexusAvenger

Data for a command for adding coins.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local CoinService = ServerScriptServiceProject:GetResource("Service.CoinService")



--Return the command data.
return {
    Keyword = {"addcoins","coins"},
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to execute on.",
        },
        {
            Type = "integer",
            Name = "Coins",
            Description = "Coins to add.",
        },
    },
    Description = "Gives coins to a set of players.",
    Run = function(self,CommandContext,Players,Coins)
        for _,Player in pairs(Players) do
            CoinService:GiveCoins(Player,Coins)
        end
    end,
}