--[[
TheNexusAvenger

Helper for managing the current round of a player.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local NexusEventCreator = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEventCreator")
local ActiveRounds = NexusRoundSystem:GetObjectReplicator():GetGlobalContainer():WaitForChildBy("Name","ActiveRounds")

local CurrentRound = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
CurrentRound:SetClassName("CurrentRound")
CurrentRound.CurrentRoundChanged = NexusEventCreator:CreateEvent()




--[[
Sets the current round the player is in.
--]]
local function UpdateCurrentRound()
    --Find the current round the player is in.
    local PlayerRound
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(Players.LocalPlayer) then
            PlayerRound = Round
            break
        end
    end

    --Update the current round.
    if PlayerRound ~= CurrentRound.CurrentRound then
        CurrentRound.CurrentRound = PlayerRound
        CurrentRound.CurrentRoundChanged:Fire(PlayerRound)
    end
end

--[[
Registers adding a round.
--]]
local function RegisterRound(RoundInstance)
    --Connect the player being added.
    RoundInstance.Players.ItemAdded:Connect(function(Player)
        if Player == Players.LocalPlayer then
            UpdateCurrentRound()
        end
    end)
    RoundInstance.Players.ItemRemoved:Connect(function(Player)
        if Player == Players.LocalPlayer then
            UpdateCurrentRound()
        end
    end)
    UpdateCurrentRound()
end



--Connect adding rounds.
UpdateCurrentRound()
ActiveRounds.ChildAdded:Connect(RegisterRound)
ActiveRounds.ChildRemoved:Connect(UpdateCurrentRound)
for _,Round in pairs(ActiveRounds:GetChildren()) do
    RegisterRound(Round)
end



return CurrentRound