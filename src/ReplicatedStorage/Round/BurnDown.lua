--[[
TheNexusAvenger

Class for a Burn Down round.
--]]

local INITIAL_WEAPONS = {
    "Sword",
    "Superball",
    "Slingshot",
    "RocketLauncher",
    "Bomb",
    "Reflector",
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local BurnDown = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
BurnDown:SetClassName("BurnDown")
NexusReplication:RegisterType("BurnDown",BurnDown)



--[[
Creates the round object.
--]]
function BurnDown:__new()
    self:InitializeSuper()
    self.Name = "BurnDown"
end

--[[
Starts the round.
--]]
function BurnDown:RoundStarted()
    --Set up the initial loadouts.
    local Loadouts = {}
    for _,Player in pairs(self.Players:GetAll()) do
        Loadouts[Player] = {}
        for _,WeaponName in pairs(INITIAL_WEAPONS) do
            table.insert(Loadouts[Player],WeaponName)
        end
        self:SetStarterTools(Player,Loadouts[Player])
    end

    --Spawn the players.
    local RoundEvents = {}
    local DamageService = self:GetService("DamageService")
    local LocalEffectService = self:GetService("LocalEffectService")
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)

        --Connect the events.
        table.insert(RoundEvents,DamageService:GetKOEvent(Player):Connect(function(_,ToolName)
            if ToolName then
                --Remove the tool from the loadout.
                local PlayerLoadout = Loadouts[Player]
                local IndexToRemove
                for i,Tool in pairs(PlayerLoadout) do
                    if Tool == ToolName then
                        IndexToRemove = i
                        break
                    end
                end
                if IndexToRemove then
                    table.remove(PlayerLoadout,IndexToRemove)
                end

                --Set the player tools.
                self:SetStarterTools(Player,PlayerLoadout)
                self:SetTools(Player,PlayerLoadout)

                --End the round if there are no more weapons.
                local ToolCount = #PlayerLoadout
                if ToolCount == 0 then
                    self.Timer:Complete()
                    self.MVPs = {Player}
                    self:BroadcastLocalEffect("DisplayAlert",Player.DisplayName.." wins!")
                    return
                end

                --Set the player as "on fire" if they are on the last weapon.
                if ToolCount == 1 then
                    --Add the fire as the player.
                    local Character = Player.Character
                    if Character then
                        local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
                        if Torso then
                            local Fire = Instance.new("Fire")
                            Fire.Parent = Torso
                        end
                    end

                    --Alert everyone that the player is on fire to draw attention.
                    LocalEffectService:BroadcastLocalEffect(Player,"DisplayAlert",Player.DisplayName.." is on fire!")
                end

                --Alert the player.
                LocalEffectService:PlayLocalEffect(Player,"DisplayAlert",ToolCount.." weapon"..(ToolCount ~= 1 and "s" or "").." left!")
            end
        end))
        table.insert(RoundEvents,DamageService:GetWOEvent(Player):Connect(function()
            local PlayerLoadout = Loadouts[Player]
            if #PlayerLoadout == 1 then
                --Add a random tool if the player was down to 1 tool.
                while true do
                    local NewWeapon = INITIAL_WEAPONS[math.random(1,#INITIAL_WEAPONS)]
                    if NewWeapon ~= PlayerLoadout[1] then
                        table.insert(PlayerLoadout,NewWeapon)
                        break
                    end
                end

                --Alert the player.
                LocalEffectService:PlayLocalEffect(Player,"DisplayAlert","Denied! 2 weapons left!")
            end
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



return BurnDown