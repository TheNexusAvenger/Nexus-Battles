--[[
TheNexusAvenger

Manages persistent and non-persistent stats for players.
--]]

local DEFAULT_STATS = {
    {
        Name = "Coins",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
    {
        Name = "TotalCoins",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
    {
        Name = "Inventory",
        ValueType = "StringValue",
        DefaultValue = "[]",
    },
    {
        Name = "TimesMVP",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
    {
        Name = "TotalKOs",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
    {
        Name = "TotalWOs",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
    {
        Name = "MostKOs",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
    {
        Name = "MostWOs",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
    {
        Name = "LongestKOStreak",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local StatContainer = ReplicatedStorageProject:GetResource("State.Stats.StatContainer")

local StatService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
StatService:SetClassName("StatService")
StatService.CachedPersistentStats = {}
StatService.CachedTemporaryStats = {}



--[[
Returns the persistent stat container for the player.
--]]
function StatService:GetPersistentStats(Player)
    --Create the persistent stats if they don't exist.
    if not self.CachedPersistentStats[Player] then
        self.CachedPersistentStats[Player] = StatContainer.GetContainer(Player,"PersistentStats")
        --TODO: Set data source for DataStores.

        --Create the stats.
        for _,StatData in pairs(DEFAULT_STATS) do
            self.CachedPersistentStats[Player]:Create(StatData.Name,StatData.ValueType,StatData.DefaultValue)
        end
    end

    --Return the cached stats.
    return self.CachedPersistentStats[Player]
end

--[[
Returns the temporary stat container for the player.
--]]
function StatService:GetTemporaryStats(Player,Create)
    if Create == nil then Create = true end

    --Create the temporary stats if they don't exist.
    if not self.CachedTemporaryStats[Player] and Create then
        self.CachedTemporaryStats[Player] = StatContainer.GetContainer(Player,"TemporaryStats")
    end

    --Return the cached stats.
    return self.CachedTemporaryStats[Player]
end

--[[
Clears the temporary stats of the player.
--]]
function StatService:ClearTemporaryStats(Player)
    if StatService.CachedTemporaryStats[Player] then
        StatService.CachedTemporaryStats[Player]:Destroy()
        StatService.CachedTemporaryStats[Player] = nil
    end
end



--Connect players leaving.
Players.PlayerRemoving:Connect(function(Player)
    --Clear the persistent stats.
    if StatService.CachedPersistentStats[Player] then
        StatService.CachedPersistentStats[Player]:Destroy()
        StatService.CachedPersistentStats[Player] = nil
    end

    --Clear the temporary stats.
    StatService:ClearTemporaryStats(Player)
end)



return StatService