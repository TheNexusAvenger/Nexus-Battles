--[[
TheNexusAvenger

Class for a One Weapon Rocket Launcher round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local OneWeaponSword = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
OneWeaponSword:SetClassName("OneWeaponSword")
NexusReplication:RegisterType("OneWeaponSword",OneWeaponSword)



--[[
Creates the round object.
--]]
function OneWeaponSword:__new()
    self:InitializeSuper()
    self.Name = "OneWeaponSword"
end

--[[
Starts the round.
--]]
function OneWeaponSword:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword"})
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



return OneWeaponSword