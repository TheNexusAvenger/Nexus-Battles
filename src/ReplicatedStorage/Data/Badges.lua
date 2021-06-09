--[[
TheNexusAvenger

Badges that can be awarded.
--]]

if game.GameId == 2346548105 then
    --Nexus Development Quality Assurance
    return {
        ReachedRank4 = 2124761040,
        ReachedRank8 = 2124761041,
        ReachedRank12 = 2124761042,
        ReachedRank16 = 2124761044,
        ReachedRank20 = 2124761045,
        PlayedRocksVsBazookasRound = 2124761047,
    }
else
    --Release Game
    return {
        ReachedRank4 = 2124761797,
        ReachedRank8 = 2124761798,
        ReachedRank12 = 2124761800,
        ReachedRank16 = 2124761801,
        ReachedRank20 = 2124761803,
        PlayedRocksVsBazookasRound = 2124761807,
    }
end