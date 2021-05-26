--[[
TheNexusAvenger

Determines the bonuses for the rank scores for players.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local ActiveRounds = NexusRoundSystem:GetObjectReplicator():GetGlobalContainer():WaitForChildBy("Name","ActiveRounds")



return function(Player)
    --Get the current round for the player.
    local Bonuses = {}
    local CurrentRound
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(Player) then
            CurrentRound = Round
            break
        end
    end

    --Add the bonuses for the rounds.
    if CurrentRound then
        --Add the bonus for being the MVP.
        for _,MVP in pairs(CurrentRound.MVPs) do
            if MVP == Player then
                table.insert(Bonuses,{
                    Message = "+50% for being the MVP!",
                    Multiplier = 0.5,
                })
                break
            end
        end

        --And a friend bonus for each friend.
        for _,OtherPlayer in pairs(CurrentRound.Players:GetAll()) do
            if OtherPlayer ~= Player and OtherPlayer:IsFriendsWith(Player.UserId) then
                table.insert(Bonuses,{
                    Message = "+10% for playing with "..OtherPlayer.DisplayName.."!",
                    Multiplier = 0.1,
                })
            end
        end
    end

    --Add the bonus for being premium.
    if Player.MembershipType == Enum.MembershipType.Premium then
        table.insert(Bonuses,{
            Message = "+25% for being premium!",
            Multiplier = 0.25,
        })
    end

    --Return the bonuses.
    return Bonuses
end