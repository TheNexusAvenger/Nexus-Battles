--[[
TheNexusAvenger

Controls the visible maps on the client.
--]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local ActiveRounds = NexusRoundSystem:GetObjectReplicator():GetGlobalContainer():WaitForChildBy("Name","ActiveRounds")

local ActiveMaps = Workspace:WaitForChild("ActiveMaps")
local ActiveHiddenMaps = ReplicatedStorageProject:GetResource("ActiveHiddenMaps")
local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")

local CurrentMap,CurrentId



--[[
Invoked when the round changes.
--]]
local function CurrentRoundChanged(CurrentRound)
    --Hide the current map if the id doesn't match.
    local RoundId = CurrentRound and CurrentRound.Id
    if CurrentId ~= RoundId and CurrentMap then
        CurrentMap.Parent = ActiveHiddenMaps
        CurrentMap = nil
    end

    --Move the active map.
    if RoundId then
        CurrentId = RoundId
        CurrentMap = ActiveHiddenMaps:WaitForChild(tostring(RoundId))
        CurrentMap.Parent = ActiveMaps
    end
end



--Connect maps being added.
ActiveMaps.ChildAdded:Connect(function(Map)
    wait()
    if Map.Name ~= tostring(CurrentId) then
        Map.Parent = ActiveHiddenMaps
    end
end)
for _,Map in pairs(ActiveMaps:GetChildren()) do
    if Map.Name ~= tostring(CurrentId) then
        Map.Parent = ActiveHiddenMaps
    end
end

--Connect the current round changing.
CurrentRoundState.CurrentRoundChanged:Connect(CurrentRoundChanged)
CurrentRoundChanged(CurrentRoundState.CurrentRound)

--Connect rounds being cleared.
--Currently, maps may not be properly destroyed on the client.
ActiveRounds.ChildRemoved:Connect(function(Round)
    --Clear the current map.
    if CurrentId == Round.Id and CurrentMap then
        CurrentMap:Destroy()
        CurrentMap = nil
    end

    --Clear the stored map.
    local StoredMap = ActiveHiddenMaps:FindFirstChild(tostring(Round.Id))
    if StoredMap then
        StoredMap:Destroy()
    end
end)