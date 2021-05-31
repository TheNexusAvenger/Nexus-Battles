--[[
TheNexusAvenger

Applies regeneration buff to a player.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local InventoryService = ServerScriptServiceProject:GetResource("Service.InventoryService")

local LastCharacterUpdates = {}

return function(Character,Value)
    --Get the Humanoid.
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    LastCharacterUpdates[Character] = nil
    if Value == 0 then return end

    --Get the reference player.
    local Player = Players:GetPlayerFromCharacter(Character)
    if not Player then return end

    --Start healing the player.
    coroutine.wrap(function()
        --Set the start time to stop after getting another call.
        local StartTime = tick()
        LastCharacterUpdates[Character] = StartTime

        --Heal the player until they leave or die.
        while Humanoid.Health > 0 and Character.Parent and Player.Parent and Player.Character == Player.Character do
            --Heal the player.
            local AmountToHeal = math.min(Humanoid.MaxHealth - Humanoid.Health,Value)
            if AmountToHeal > 0 then
                Humanoid.Health = Humanoid.Health + AmountToHeal
                InventoryService:DamageArmor(Player,"Regeneration",AmountToHeal/Value)
            end

            --Wait 1 second to continue.
            wait(1)
        end

        --Clear the value.
        if LastCharacterUpdates[Character] == StartTime then
            LastCharacterUpdates[Character] = nil
        end
    end)()
end