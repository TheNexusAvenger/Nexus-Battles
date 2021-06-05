--[[
TheNexusAvenger

Service for managing the global leaderboards.
--]]

local MAX_LEADERSTATS = 50
local LEADERBOARD_STATS = {
    "TotalKOs",
    "TotalCoins",
    "TimesMVP",
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local StatService = ServerScriptServiceProject:GetResource("Service.StatService")

local LeaderboardService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
LeaderboardService:SetClassName("LeaderboardService")
LeaderboardService.GlobalStats = {}



--Set up the replicaiton.
local LeaderboardReplication = Instance.new("Folder")
LeaderboardReplication.Name = "Leaderboard"
LeaderboardReplication.Parent = ReplicatedStorageProject:GetResource("Replication")

for _,StatName in pairs(LEADERBOARD_STATS) do
    local StatValue = Instance.new("StringValue")
    StatValue.Name = StatName
    StatValue.Value = "[]"
    StatValue.Parent = LeaderboardReplication
end



--[[
Updates the stat values for the leaderboards.
--]]
function LeaderboardService:UpdateGlobalStatValue(StatName)
    --Get the stat values of the global players and local players.
    local UserStats = {}
    for UserId,Value in pairs(self.GlobalStats[StatName] or {}) do
        if UserId > 0 then
            UserStats[UserId] = Value
        end
    end
    for _,Player in pairs(Players:GetPlayers()) do
        UserStats[Player.UserId] = StatService:GetPersistentStats(Player):Get(StatName):Get()
    end

    --Convert the user stats to a list.
    local Stats = {}
    for UserId,Value in pairs(UserStats) do
        table.insert(Stats,{
            UserId = UserId,
            Value = Value,
        })
    end

    --Sort the values and remove excess values.
    table.sort(Stats,function(a,b)return a.Value > b.Value end)
    while #Stats > MAX_LEADERSTATS do
        table.remove(Stats,MAX_LEADERSTATS + 1)
    end

    --Set the value.
    LeaderboardReplication:WaitForChild(StatName).Value = HttpService:JSONEncode(Stats)
end

--[[
Updates the stats in the ordered data store
for all the players in the game.
--]]
function LeaderboardService:FlushPlayerStats(StatName)
    --Flush the stats of all the players.
    local AllWorked,AllReturned = pcall(function()
        local DataStore = DataStoreService:GetOrderedDataStore("Leaderboard_"..StatName)
        for _,Player in pairs(Players:GetPlayers()) do
            coroutine.wrap(function()
                local Worked,Return = pcall(function()
                    DataStore:SetAsync(tostring(Player.UserId),StatService:GetPersistentStats(Player):Get(StatName):Get())
                end)
                if not Worked then
                    warn("Failed to update stat for "..tostring(Player).." for "..tostring(StatName).." because "..tostring(Return))
                end
            end)()
        end
    end)
    if not AllWorked then
        warn("Failed to update all ordered stats for "..tostring(StatName).." because "..tostring(AllReturned))
    end
end

--[[
Fetches the global stats from the datastore.
--]]
function LeaderboardService:FetchPlayerStats(StatName)
    --Update the fetched stats.
    self.GlobalStats[StatName] = {}
    local Worked,Return = pcall(function()
        local DataStore = DataStoreService:GetOrderedDataStore("Leaderboard_"..StatName)
        local SortedStats = DataStore:GetSortedAsync(false,MAX_LEADERSTATS)
        for _,Entry in pairs(SortedStats:GetCurrentPage()) do
            self.GlobalStats[StatName][tonumber(Entry.key)] = Entry.value
        end
    end)
    if not Worked then
        warn("Failed to fetchordered stats for "..tostring(StatName).." because "..tostring(Return))
    end

    --Update the value.
    LeaderboardService:UpdateGlobalStatValue(StatName)
end



--[[
Handles a player being added.
--]]
local function PlayerAdded(Player)
    local Stats = StatService:GetPersistentStats(Player)
    for _,StatName in pairs(LEADERBOARD_STATS) do
        local Stat = Stats:Get(StatName)
        Stat.StatChanged:Connect(function()
            LeaderboardService:UpdateGlobalStatValue(StatName)
        end)
        LeaderboardService:UpdateGlobalStatValue(StatName)
    end
end



--Start flushing and updating the stats.
coroutine.wrap(function()
    while true do
        for _,StatName in pairs(LEADERBOARD_STATS) do
            LeaderboardService:FlushPlayerStats(StatName)
        end
        wait(60)
    end
end)()
coroutine.wrap(function()
    while true do
        for _,StatName in pairs(LEADERBOARD_STATS) do
            LeaderboardService:FetchPlayerStats(StatName)
        end
        wait(60)
    end
end)()

--Connect the players.
Players.PlayerAdded:Connect(PlayerAdded)
for _,Player in pairs(Players:GetPlayers()) do
    coroutine.wrap(function()
        PlayerAdded(Player)
    end)()
end



return LeaderboardService