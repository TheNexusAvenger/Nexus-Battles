--[[
TheNexusAvenger

Class for a One Weapon Madness round.
--]]

local WEAPON_OPTIONS = {
    "Sword",
    "Superball",
    "Slingshot",
    "RocketLauncher",
    "Bomb",
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))

local OneWeaponMadness = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
OneWeaponMadness:SetClassName("OneWeaponMadness")
OneWeaponMadness:AddFromSerializeData("OneWeaponMadness")
NexusRoundSystem:GetObjectReplicator():RegisterType("OneWeaponMadness",OneWeaponMadness)



--[[
Creates the round object.
--]]
function OneWeaponMadness:__new()
    self:InitializeSuper()
    self.Name = "OneWeaponMadness"
end

--[[
Starts the round.
--]]
function OneWeaponMadness:RoundStarted()
    local LastWeapons = {}
    local RoundEvents = {}

    --[[
    Replaces the tools for the given character.
    --]]
    local function ReplaceRandomTool(Player,Character,DisplayMessage)
        --Return if the character isn't alive.
        if not Character then return end
        if not self.Players:Contains(Player) then return end
        local Humanoid = Character:WaitForChild("Humanoid")
        if Humanoid.Health <= 0  then
            return
        end

        --Replace the last tool and set the tool.
        local Backpack = Player:WaitForChild("Backpack")
        while true do
            local NewWeapon = WEAPON_OPTIONS[math.random(1,#WEAPON_OPTIONS)]
            if NewWeapon ~= LastWeapons[Player] then
                LastWeapons[Player] = NewWeapon
                break
            end
        end
        self:SetTools(Player,{LastWeapons[Player]})

        if DisplayMessage then
            --Equip the new tool.
            Humanoid:EquipTool(Backpack:GetChildren()[1])

            --Display the message.
            self:GetService("LocalEffectService"):PlayLocalEffect(Player,"DisplayAlert","Lets change things up a bit!")
        end
    end

    --[[
    Handles a player being added.
    --]]
    local function PlayerAdded(Player)
        table.insert(RoundEvents,Player.CharacterAdded:Connect(function(Character)
            ReplaceRandomTool(Player,Character)
        end))
        ReplaceRandomTool(Player,Player.Character)
    end

    --Spawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)
        coroutine.wrap(function()
            --Connect the character being added.
            PlayerAdded(Player)

            --Connect the player getting kills.
            table.insert(RoundEvents,self:GetService("DamageService"):GetKOEvent(Player):Connect(function()
                ReplaceRandomTool(Player,Player.Character,true)
            end))
        end)()
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



return OneWeaponMadness