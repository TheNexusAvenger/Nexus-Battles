--[[
TheNexusAvenger

Class for a Team Death Match round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local TeamDeathmatch = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseTeamRound")):Extend()
TeamDeathmatch:SetClassName("TeamDeathmatch")
TeamDeathmatch:AddFromSerializeData("TeamDeathmatch")
NexusReplication:GetObjectReplicator():RegisterType("TeamDeathmatch",TeamDeathmatch)



--[[
Creates the round object.
--]]
function TeamDeathmatch:__new()
    self:InitializeSuper()
    self.Name = "TeamDeathmatch"
end

--[[
Starts the round.
--]]
function TeamDeathmatch:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword","Superball","Slingshot","Bomb","RocketLauncher","Reflector"})
    end

    --Spawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)
    end

    --Wait for the timer to complete.
    while self.Timer.State ~= "COMPLETE" do
        self.Timer:GetPropertyChangedSignal("State"):Wait()
    end

    --End the round.
    self:End()
end



return TeamDeathmatch