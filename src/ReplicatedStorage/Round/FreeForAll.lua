--[[
TheNexusAvenger

Class for a Free For All round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local FreeForAll = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
FreeForAll:SetClassName("FreeForAll")
FreeForAll:AddFromSerializeData("FreeForAll")
NexusReplication:GetObjectReplicator():RegisterType("FreeForAll",FreeForAll)



--[[
Creates the round object.
--]]
function FreeForAll:__new()
    self:InitializeSuper()
    self.Name = "FreeForAll"
end

--[[
Starts the round.
--]]
function FreeForAll:RoundStarted()
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



return FreeForAll