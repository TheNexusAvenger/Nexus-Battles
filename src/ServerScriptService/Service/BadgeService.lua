--[[
TheNexusAvenger

Service for managing game badges.
--]]

local RANK_BADGES = {
    [4] = "ReachedRank4",
    [8] = "ReachedRank8",
    [12] = "ReachedRank12",
    [16] = "ReachedRank16",
    [20] = "ReachedRank20",
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxBadgeService = game:GetService("BadgeService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local Badges = ReplicatedStorageProject:GetResource("Data.Badges")
local RankIcons = ReplicatedStorageProject:GetResource("Data.RankIcons")
local StatService = ServerScriptServiceProject:GetResource("Service.StatService")

local BadgeService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
BadgeService:SetClassName("BadgeService")
BadgeService.BadgeCache = {}



--[[
Returns if a player owns a badge.
--]]
function BadgeService:PlayerHasBadge(Player,BadgeName)
    --Create the cache table for the player.
    if not self.BadgeCache[Player] then
        self.BadgeCache[Player] = {}
    end

    --Populate the cache entry if it is missing.
    local BadgeId = Badges[BadgeName]
    local CacheTable = self.BadgeCache[Player]
    if CacheTable[BadgeId] == nil then
        local Worked,Error = pcall(function()
            CacheTable[BadgeId] = RobloxBadgeService:UserHasBadgeAsync(Player.UserId,BadgeId)
        end)
        if not Worked then
            CacheTable[BadgeId] = false
            warn("Getting badge "..tostring(BadgeId).." for "..tostring(Player).." failed because: "..tostring(Error))
        end
    end

    --Return the cached value.
    return CacheTable[BadgeId]
end

--[[
Awards a badge to a player.
--]]
function BadgeService:AwardBadge(Player,BadgeName)
    if not self:PlayerHasBadge(Player,BadgeName) then
        local BadgeId = Badges[BadgeName]
        local CacheTable = self.BadgeCache[Player] or {}
        local Worked,Error = pcall(function()
            RobloxBadgeService:AwardBadge(Player.UserId,BadgeId)
            CacheTable[BadgeId] = true
        end)
        if not Worked then
            warn("Award badge "..tostring(BadgeId).." for "..tostring(Player).." failed because: "..tostring(Error))
        end
    end
end



--[[
Awards the rank badges for a given player.
--]]
local function AwardRankBadges(Player)
    --Get the rank score.
    local PlayerStats = StatService:GetPersistentStats(Player)
    local RankScore = PlayerStats:Get("RankScore"):Get()

    --Award the badges.
    for Rank,BadgeName in pairs(RANK_BADGES) do
        if RankIcons.Normal[Rank].RankScore <= RankScore then
            BadgeService:AwardBadge(Player,BadgeName)
        end
    end
end

--[[
Initializes a player.
--]]
local function PlayerAdded(Player)
    --Load the initial badges.
    for BadgeName,_ in pairs(Badges) do
        BadgeService:PlayerHasBadge(Player,BadgeName)
    end

    --Award the badges for the rank score.
    StatService:GetPersistentStats(Player):Get("RankScore").StatChanged:Connect(function()
        AwardRankBadges(Player)
    end)
    AwardRankBadges(Player)
end



--Connect players joining and load the persistent stats.
Players.PlayerAdded:Connect(function(Player)
    PlayerAdded(Player)
end)
for _,Player in pairs(Players:GetPlayers()) do
    coroutine.wrap(function()
        PlayerAdded(Player)
    end)()
end




return BadgeService