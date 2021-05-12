--[[
TheNexusAvenger

Helper class for sorting stats.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local StatSorter = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
StatSorter:SetClassName("StatSorter")



--[[
Creates the stat sorter.
--]]
function StatSorter:__new(RoundStats)
    self:InitializeSuper()

    --Parse the stats.
    self.SortStats = {}
    for _,StatData in pairs(RoundStats) do
        if StatData.Prefer then
            table.insert(self.SortStats,{
                Name = StatData.Name,
                DefaultValue = StatData.DefaultValue or 0,
                PreferHigher = (string.lower(StatData.Prefer) == "higher"),
            })
        end
    end
end

--[[
Returns a list of players in order by their temporary stats.
--]]
function StatSorter:GetSortedPlayers(Players,OverrideMVPs)
    --Clone the Players table.
    local NewPlayers = {}
    for _,Player in pairs(Players) do
        table.insert(NewPlayers,Player)
    end

    --Convert the most valuable players to a map.
    local OverrideMVPsMap = {}
    for _,Player in pairs(OverrideMVPs or {}) do
        OverrideMVPsMap[Player] = true
    end

    --Sort the players.
    table.sort(NewPlayers,function(Player1,Player2)
        --Get the player stats.
        local Player1Stats,Player2Stats = Player1:FindFirstChild("TemporaryStats"),Player2:FindFirstChild("TemporaryStats")

        --Return if 1 player is the MVP.
        if OverrideMVPsMap[Player1] and not OverrideMVPsMap[Player2] then
            return true
        elseif not OverrideMVPsMap[Player1] and OverrideMVPsMap[Player2] then
            return false
        end

        --Return if two stats are different.
        for _,StatSortData in pairs(self.SortStats) do
            local Name,Default,PreferHigher = StatSortData.Name,StatSortData.DefaultValue,StatSortData.PreferHigher
            local Stat1,Stat2 = (Player1Stats and Player1Stats:FindFirstChild(Name)),(Player2Stats and Player2Stats:FindFirstChild(Name))
            local Value1,Value2 = (Stat1 and Stat1.Value or Default),(Stat2 and Stat2.Value or Default)

            --Return based on the values being different.
            if Value1 ~= Value2 then
                if PreferHigher then
                    return Value1 > Value2
                else
                    return Value2 > Value1
                end
            end
        end

        --Return based on the name if all other stats are equal.
        return Player1.DisplayName < Player2.DisplayName
    end)

    --Return the player.
    return NewPlayers
end

--[[
Returns the MVPs given the current stats.
--]]
function StatSorter:GetMVPs(Players)
    --Return an empty list if there are no players.
    if #Players == 0 then
        return {}
    end

    --Sort the players.
    local SortedPlayers = self:GetSortedPlayers(Players)
    local MVPs = {}

    --Add the players that have the same stats as the first player.
    local FirstPlayer = SortedPlayers[1]
    local Player1Stats = FirstPlayer:FindFirstChild("TemporaryStats")
    for _,Player in pairs(SortedPlayers) do
        local OtherPlayerStats = Player:FindFirstChild("TemporaryStats")

        --Determine if there is at least 1 stat that doesn't match.
        local AllStatsMatch = true
        for _,StatSortData in pairs(self.SortStats) do
            local Name,Default = StatSortData.Name,StatSortData.DefaultValue
            local Stat1,Stat2 = (Player1Stats and Player1Stats:FindFirstChild(Name)),(OtherPlayerStats and OtherPlayerStats:FindFirstChild(Name))
            local Value1,Value2 = (Stat1 and Stat1.Value or Default),(Stat2 and Stat2.Value or Default)
            if Value1 ~= Value2 then
                AllStatsMatch = false
                break
            end
        end

        --Add the player or break the loop.
        --All players after the next match will not have the same stats since they are sorted.
        if AllStatsMatch then
            table.insert(MVPs,Player)
        else
            break
        end
    end

    --Return the MVPs.
    return MVPs
end



return StatSorter