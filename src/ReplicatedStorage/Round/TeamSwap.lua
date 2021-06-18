--[[
TheNexusAvenger

Class for a Team Swap round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local TeamSwap = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseTeamRound")):Extend()
TeamSwap:SetClassName("TeamSwap")
TeamSwap:AddFromSerializeData("TeamSwap")
NexusReplication:GetObjectReplicator():RegisterType("TeamSwap",TeamSwap)



--[[
Creates the round object.
--]]
function TeamSwap:__new()
    self:InitializeSuper()
    self.Name = "TeamSwap"
end

--[[
Starts the round.
--]]
function TeamSwap:RoundStarted()
    local RoundEvents = {}

    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword","Superball","Slingshot","Bomb","RocketLauncher","Reflector"})
    end

    --Spawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)

        --Connect the player being killed.
        table.insert(RoundEvents,self:GetService("DamageService"):GetWOEvent(Player):Connect(function(KillingPlayer)
            if KillingPlayer and self.Players:Contains(Player) and self.Players:Contains(KillingPlayer) then
                Player.TeamColor = KillingPlayer.TeamColor
                self:EndIfTeamEmpty()
            end
        end))
    end

    --Wait for the timer to complete.
    self:EndIfTeamEmpty()
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
Ends the round if everyone is on the same team.
--]]
function TeamSwap:EndIfTeamEmpty()
    --Determine the total teams.
    local TeamsWithPlayers = {}
    local TotalTeams = 0
    for _,Player in pairs(self.Players:GetAll()) do
        local TeamName = Player.TeamColor.Name
        if not TeamsWithPlayers[TeamName] then
            TeamsWithPlayers[TeamName] = true
            TotalTeams = TotalTeams + 1
        end
    end

    --End the timer if there is only 1 team.
    if TotalTeams <= 1 then
        self.Timer:Complete()
    end
end



return TeamSwap