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
    {
        Name = "CapturedFlags",
        ValueType = "IntValue",
        DefaultValue = 0,
    },
    {
        Name = "RankScore",
        ValueType = "NumberValue",
        DefaultValue = 0,
    },
    {
        Name = "PurchaseHistory",
        ValueType = "StringValue",
        DefaultValue = "[]"
    },
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusDataStore = ReplicatedStorageProject:GetResource("External.NexusDataStore")
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
        local PersistentStats = StatContainer.GetContainer(Player,"PersistentStats")
        self.CachedPersistentStats[Player] = PersistentStats

        --Set the data source.
        local DataLoadSuccessful = false
        local Worked,Error = pcall(function()
            local DataSource = NexusDataStore:GetSaveData(Player)
            PersistentStats:SetDataSource(DataSource)
            DataLoadSuccessful = DataSource.DataLoadSuccessful
        end)
        if not Worked then
            warn("Failed to set data source for "..tostring(Player).." because: "..tostring(Error))
        end

        --Add the load indicator.
        local DataLoadSuccessfulValue = Instance.new("BoolValue")
        DataLoadSuccessfulValue.Name = "DataLoadSuccessful"
        DataLoadSuccessfulValue.Value = DataLoadSuccessful
        DataLoadSuccessfulValue.Parent = Player

        --Create the stats.
        for _,StatData in pairs(DEFAULT_STATS) do
            PersistentStats:Create(StatData.Name,StatData.ValueType,StatData.DefaultValue)
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



--Connect players joining and load the persistent stats.
Players.PlayerAdded:Connect(function(Player)
    StatService:GetPersistentStats(Player)
end)
for _,Player in pairs(Players:GetPlayers()) do
    coroutine.wrap(function()
        StatService:GetPersistentStats(Player)
    end)()
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