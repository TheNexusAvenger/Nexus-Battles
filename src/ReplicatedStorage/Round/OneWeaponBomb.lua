--[[
TheNexusAvenger

Class for a One Weapon Bomb round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local OneWeaponBomb = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
OneWeaponBomb:SetClassName("OneWeaponBomb")
OneWeaponBomb:AddFromSerializeData("OneWeaponBomb")
NexusReplication:GetObjectReplicator():RegisterType("OneWeaponBomb",OneWeaponBomb)



--[[
Creates the round object.
--]]
function OneWeaponBomb:__new()
    self:InitializeSuper()
    self.Name = "OneWeaponBomb"
end

--[[
Starts the round.
--]]
function OneWeaponBomb:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Bomb"})
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



return OneWeaponBomb