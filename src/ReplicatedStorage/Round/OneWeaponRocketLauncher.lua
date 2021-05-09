--[[
TheNexusAvenger

Class for a One Weapon Rocket Launcher round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))

local OneWeaponRocketLauncher = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
OneWeaponRocketLauncher:SetClassName("OneWeaponRocketLauncher")
OneWeaponRocketLauncher:AddFromSerializeData("OneWeaponRocketLauncher")
NexusRoundSystem:GetObjectReplicator():RegisterType("OneWeaponRocketLauncher",OneWeaponRocketLauncher)



--[[
Creates the round object.
--]]
function OneWeaponRocketLauncher:__new()
    self:InitializeSuper()
    self.Name = "OneWeaponRocketLauncher"
end

--[[
Starts the round.
--]]
function OneWeaponRocketLauncher:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"RocketLauncher"})
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



return OneWeaponRocketLauncher