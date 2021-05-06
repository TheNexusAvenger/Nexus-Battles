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
    --Convert the most valuable players to a map.
    local OverrideMVPsMap = {}
    for _,Player in pairs(OverrideMVPs or {}) do
        OverrideMVPsMap[Player] = true
    end

    --Sort the players.
    table.sort(Players,function(Player1,Player2)
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
    return Players
end



return StatSorter