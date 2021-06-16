--[[
TheNexusAvenger

Helper for managing the current round of a player.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusReplication = ReplicatedStorageProject:GetResource("External.NexusReplication")
local NexusEventCreator = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEventCreator")
local ActiveRounds = NexusReplication:GetObjectReplicator():GetGlobalContainer():WaitForChildBy("Name","ActiveRounds")
local NexusObject = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject")

local CurrentRound = NexusObject:Extend()
CurrentRound:SetClassName("CurrentRound")
CurrentRound.CurrentRoundChanged = NexusEventCreator:CreateEvent()
CurrentRound.CurrentPlayingRoundChanged = NexusEventCreator:CreateEvent()
CurrentRound.CurrentSpectatingRoundChanged = NexusEventCreator:CreateEvent()


--[[
Connects to a state.
--]]
function CurrentRound:ConnectTo(Name,Functions)
    --Create the class.
    local StateClass = NexusObject:Extend()
    local CurrentObject = nil
    local CurrentObjectRound = nil

    --[[
    Returns if the object is active.
    --]]
    function StateClass:IsActive()
        return CurrentObject == self.object
    end

    --[[
    Updates the current object.
    --]]
    function StateClass:Update()
        --Return if the round didn't change.
        local NewRound = CurrentRound[Name]
        if NewRound == CurrentObjectRound then return end
        CurrentObjectRound = NewRound

        --Clear the existing object.
        if CurrentObject then
            if CurrentObject.Clear then
                CurrentObject:Clear()
            end
            CurrentObject = nil
        end

        --Create the new object.
        if NewRound then
            CurrentObject = StateClass.new()
            if CurrentObject.Start then
                CurrentObject:Start(NewRound)
            end
        end
    end

    --Add the functions.
    for FunctionName,Function in pairs(Functions) do
        StateClass[FunctionName] = Function
    end

    --Connect the round changing.
    CurrentRound[Name.."Changed"]:Connect(function()
        StateClass:Update()
    end)
    StateClass:Update()
end


--[[
Sets the current round the player is in.
--]]
local function UpdateCurrentRound()
    --Find the current round the player is in.
    local PlayerRound,SpectatorRound
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(Players.LocalPlayer) then
            PlayerRound = Round
        end
        if Round.Spectators:Contains(Players.LocalPlayer) then
            SpectatorRound = Round
        end
    end

    --Update the current round.
    local LastCurrentRound = CurrentRound.CurrentRound
    local NewCurrentRound = PlayerRound or SpectatorRound
    if PlayerRound ~= CurrentRound.CurrentPlayingRound then
        CurrentRound.CurrentPlayingRound = PlayerRound
        CurrentRound.CurrentPlayingRoundChanged:Fire(PlayerRound)
    end
    if SpectatorRound ~= CurrentRound.CurrentSpectatingRound then
        CurrentRound.CurrentSpectatingRound = SpectatorRound
        CurrentRound.CurrentSpectatingRoundChanged:Fire(SpectatorRound)
    end
    if LastCurrentRound ~= NewCurrentRound then
        CurrentRound.CurrentRound = NewCurrentRound
        CurrentRound.CurrentRoundChanged:Fire(NewCurrentRound)
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
    RoundInstance.Spectators.ItemAdded:Connect(function(Player)
        if Player == Players.LocalPlayer then
            UpdateCurrentRound()
        end
    end)
    RoundInstance.Spectators.ItemRemoved:Connect(function(Player)
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