--[[
TheNexusAvenger

Class for a One Weapon Superball round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local OneWeaponSuperball = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
OneWeaponSuperball:SetClassName("OneWeaponSuperball")
NexusReplication:GetObjectReplicator():RegisterType("OneWeaponSuperball",OneWeaponSuperball)



--[[
Creates the round object.
--]]
function OneWeaponSuperball:__new()
    self:InitializeSuper()
    self.Name = "OneWeaponSuperball"
end

--[[
Starts the round.
--]]
function OneWeaponSuperball:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Superball"})
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



return OneWeaponSuperball