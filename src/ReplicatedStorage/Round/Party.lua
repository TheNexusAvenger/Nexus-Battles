--[[
TheNexusAvenger

Class for a Party round.
--]]

local WEAPON_OPTIONS = {
    "Sword",
    "Superball",
    "Slingshot",
    "Bomb",
    "RocketLauncher",
}
local TOTAL_WEAPONS = 3



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local Party = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
Party:SetClassName("Party")
Party:AddFromSerializeData("Party")
NexusReplication:GetObjectReplicator():RegisterType("Party",Party)



--[[
Creates the round object.
--]]
function Party:__new()
    self:InitializeSuper()
    self.Name = "Party"
end

--[[
Starts the round.
--]]
function Party:RoundStarted()
    --Determine the random weapons.
    local SelectedWeapons = {}
    local SelectedWeaponsMap = {}
    for _ = 1,math.min(#WEAPON_OPTIONS,TOTAL_WEAPONS) do
        while true do
            local RandomWeaponId = math.random(1,#WEAPON_OPTIONS)
            if not SelectedWeaponsMap[RandomWeaponId] then
                SelectedWeaponsMap[RandomWeaponId] = true
                table.insert(SelectedWeapons,WEAPON_OPTIONS[RandomWeaponId])
                break
            end
        end
    end

    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,SelectedWeapons)
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



return Party