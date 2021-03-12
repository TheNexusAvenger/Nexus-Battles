--[[
TheNexusAvenger

Hides players of other rounds on the client.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local ActiveRounds = NexusRoundSystem:GetObjectReplicator():GetGlobalContainer():WaitForChildBy("Name","ActiveRounds")
local SameRoundPlayersId
local OtherRoundPlayersId
while not SameRoundPlayersId and not OtherRoundPlayersId do
    pcall(function()
        SameRoundPlayersId = PhysicsService:GetCollisionGroupId("SameRoundPlayers")
        OtherRoundPlayersId = PhysicsService:GetCollisionGroupId("OtherRoundPlayers")
    end)
    wait()
end



--[[
Returns the round for a player.
--]]
local function GetPlayerRound(Player)
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(Player) then
            return Round
        end
    end
end

--[[
Updates the visiblity of the instance.
--]]
local function UpdateInstance(Ins,Player,PlayerRound)
    if not PlayerRound then PlayerRound = GetPlayerRound(Player) end
    local InSameRound = (Player == Players.LocalPlayer or PlayerRound == CurrentRoundState.CurrentRound)
    if Ins:IsA("BasePart") then
        --Update the transparency and collisions.
        Ins.LocalTransparencyModifier = (InSameRound and 0 or 1)
        Ins.CollisionGroupId = (InSameRound and SameRoundPlayersId or OtherRoundPlayersId)
    elseif Ins:IsA("Decal") then
        --Update the visibility of the decal.
        Ins.Transparency = (InSameRound and 0 or 1)
    elseif Ins:IsA("Humanoid") then
        --Update the visibility of the nametag.
        Ins.DisplayDistanceType = (InSameRound and Enum.HumanoidDisplayDistanceType.Viewer or Enum.HumanoidDisplayDistanceType.None)
    elseif Ins:IsA("Forcefield") then
        --Update the visibility of the forcefield.
        Ins.Visible = InSameRound
    end
end

--[[
Updates the current parts of a character.
--]]
local function UpdateCharacter(Character,Player)
    if not Character then return end
    local Round = GetPlayerRound(Player)
    for _,Part in pairs(Character:GetDescendants()) do
        UpdateInstance(Part,Player,Round)
    end
end

--[[
Updates all the characters.
--]]
local function UpdateAllCharacters()
    for _,Player in pairs(Players:GetPlayers()) do
        UpdateCharacter(Player.Character,Player)
    end
end

--[[
Invoked when a character is added.
--]]
local function CharacterAdded(Character,Player)
    if not Character then return end
    Character.DescendantAdded:Connect(function(Part)
        UpdateInstance(Part,Player)
    end)
    UpdateCharacter(Character,Player)
end

--[[
Invoked when a player is added.
--]]
local function PlayerAdded(Player)
    Player.CharacterAdded:Connect(function(Character)
        CharacterAdded(Character,Player)
    end)
    CharacterAdded(Player.Character,Player)
end

--[[
Invoked when a round is added.
--]]
local function RoundAdded(Round)
    Round.Players.ItemAdded:Connect(function(Player)
        CharacterAdded(Player.Character,Player)
    end)
    Round.Players.ItemRemoved:Connect(function(Player)
        CharacterAdded(Player.Character,Player)
    end)
    for _,Player in pairs(Round.Players:GetAll()) do
        CharacterAdded(Player.Character,Player)
    end
end



--Connect the events.
Players.PlayerAdded:Connect(PlayerAdded)
for _,Player in pairs(Players:GetPlayers()) do
    PlayerAdded(Player)
end
ActiveRounds.ChildAdded:Connect(RoundAdded)
for _,Round in pairs(ActiveRounds:GetChildren()) do
    RoundAdded(Round)
end
CurrentRoundState.CurrentRoundChanged:Connect(UpdateAllCharacters)