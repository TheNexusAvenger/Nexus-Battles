--[[
TheNexusAvenger

Class for a Team Destruction round.
--]]

local DEFAULT_RESPAWN_TIME = 3
local TEAM_COLOR_NAME_TO_NAME = {
    ["Bright red"] = "Red team",
    ["Bright blue"] = "Blue team",
    ["Bright green"] = "Green team",
    ["Bright yellow"] = "Yellow team",
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))
local ObjectReplication = NexusReplication:GetObjectReplicator()

local TeamDestruction = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseTeamRound")):Extend()
TeamDestruction:SetClassName("TeamDestruction")
TeamDestruction:AddFromSerializeData("TeamDestruction")
NexusReplication:GetObjectReplicator():RegisterType("TeamDestruction",TeamDestruction)



--[[
Creates the round object.
--]]
function TeamDestruction:__new()
    self:InitializeSuper()
    self.Name = "TeamDestruction"

    --Set the 4 team colors.
    self.TeamColors = {
        BrickColor.new("Bright red"),
        BrickColor.new("Bright blue"),
        BrickColor.new("Bright green"),
        BrickColor.new("Bright yellow"),
    }

    --Set up the scores.
    if NexusReplication:IsServer() then
        self.TeamScores = ObjectReplication:CreateObject("ReplicatedTable")
        self.TeamScores:Set("Bright red",0)
        self.TeamScores:Set("Bright blue",0)
        self.TeamScores:Set("Bright green",0)
        self.TeamScores:Set("Bright yellow",0)
    end
    self:AddToSerialization("TeamScores","ObjectReference")
end

--[[
Starts the round.
--]]
function TeamDestruction:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword","Superball","Slingshot","Bomb","RocketLauncher","Reflector"})
    end

    --Set up the round state.
    local TeamSpawns = self.Map:WaitForChild("SpawnPoints"):WaitForChild("TeamSpawnPoints")
    local EliminatedTeams = {}

    --[[
    Updates the team score based on the remaining spawns.
    --]]
    local function UpdateScore()
        --Get the total spawns.
        local TotalSpawns = {
            ["Bright red"] = 0,
            ["Bright blue"] = 0,
            ["Bright green"] = 0,
            ["Bright yellow"] = 0,
        }
        for _,SpawnPart in pairs(TeamSpawns:GetChildren()) do
            if SpawnPart:IsA("BasePart") then
                local TeamColor = SpawnPart.BrickColor.Name
                if TotalSpawns[TeamColor] then
                    TotalSpawns[TeamColor] = TotalSpawns[TeamColor] + 1
                end
            end
        end

        --Update the scores.
        local ScoresAbove0 = 0
        for Name,Score in pairs(TotalSpawns) do
            self.TeamScores:Set(Name,Score)
            if Score > 0 then
                ScoresAbove0 = ScoresAbove0 + 1
            end

            --Display that the team was eliminated.
            if Score == 0 and not EliminatedTeams[Name] then
                EliminatedTeams[Name] = true
                self:BroadcastLocalEffect("DisplayAlert","The "..tostring(TEAM_COLOR_NAME_TO_NAME[Name]).." has been eliminated!")
            end
        end

        --End the round if there is 1 team left.
        if ScoresAbove0 <= 1 then
            self.Timer:Stop()
            self.Timer.State = "COMPLETE"
        end
    end

    --Connect the spawn events.
    TeamSpawns.ChildAdded:Connect(UpdateScore)
    TeamSpawns.ChildRemoved:Connect(UpdateScore)
    UpdateScore()

    --Spawn the players.
    local RoundEvents = {}
    local DamageService = self:GetService("DamageService")
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)

        --Connect eliminated players.
        table.insert(RoundEvents,DamageService:GetWOEvent(Player):Connect(function()
            --Eliminate the player if the team is eliminated.
            wait(DEFAULT_RESPAWN_TIME)
            if not EliminatedTeams[Player.TeamColor.Name] then return end
            if self.State == "ENDED" then return end
            self:EliminatePlayer(Player)
        end))
    end

    --Wait for the timer to complete.
    while self.Timer.State ~= "COMPLETE" do
        self.Timer:GetPropertyChangedSignal("State"):Wait()
    end

    --End the round.
    for _,Event in pairs(RoundEvents) do
        Event:Disconnect()
    end
    self:End()
end

--[[
Disposes of the object.
--]]
function TeamDestruction:Dispose()
    self.super:Dispose()

    --Destroy the objects.
    self.TeamScores:Destroy()
end



return TeamDestruction