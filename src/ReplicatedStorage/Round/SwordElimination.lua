--[[
TheNexusAvenger

Class for a Sword Elimination round.
--]]

local DEFAULT_RESPAWN_TIME = 3



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))

local SwordElimination = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
SwordElimination:SetClassName("SwordElimination")
SwordElimination:AddFromSerializeData("SwordElimination")
NexusRoundSystem:GetObjectReplicator():RegisterType("SwordElimination",SwordElimination)



--[[
Creates the round object.
--]]
function SwordElimination:__new()
    self:InitializeSuper()
    self.Name = "SwordElimination"
end

--[[
Starts the round.
--]]
function SwordElimination:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword"})
    end

    --Spawn the players.
    local RoundEvents = {}
    local DamageService = self:GetService("DamageService")
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,false)
        self:SpawnPlayer(Player)

        --Connect the player being killed.
        local PendingEliminationPlayers = 0
        table.insert(RoundEvents,DamageService:GetWOEvent(Player):Connect(function()
            --End the round if there is only 1 player left (2 with killing player).
            PendingEliminationPlayers = PendingEliminationPlayers + 1
            if #self.Players:GetAll() <= 2 then
                --Set the MVP to the last player.
                --The WO event is not used because the player can reset.
                for _,OtherPlayer in pairs(self.Players:GetAll()) do
                    if Player ~= OtherPlayer then
                        self.MVPs = {OtherPlayer}
                        break
                    end
                end

                --Stop the timer and allow the round to complete.
                self.Timer:Stop()
                self.Timer.State = "COMPLETE"
            else
                self:BroadcastLocalEffect("DisplayAlert",Player.DisplayName.." eliminated! "..tostring(#self.Players:GetAll() - PendingEliminationPlayers).." players left!")
            end

            --Eliminate the player.
            wait(DEFAULT_RESPAWN_TIME)
            if self.State == "ENDED" then return end
            self:EliminatePlayer(Player)
            PendingEliminationPlayers = PendingEliminationPlayers - 1
        end))
    end

    --Wait for the timer to complete.
    while self.Timer.State ~= "COMPLETE" and #self.Players:GetAll() > 1 do
        self.Timer:GetPropertyChangedSignal("State"):Wait()
    end

    --End the round.
    for _,Event in pairs(RoundEvents) do
        Event:Disconnect()
    end
    self:End()
end



return SwordElimination