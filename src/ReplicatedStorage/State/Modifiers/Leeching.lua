--[[
TheNexusAvenger

Applies leeching effects to a player.
--]]

local LEECH_MAX_RANGE = 15

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))
local DamageService = ServerScriptServiceProject:GetResource("Service.DamageService")
local InventoryService = ServerScriptServiceProject:GetResource("Service.InventoryService")
local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")

local LastCharacterUpdates = {}



return function(Character,Value)
    --Get the Humanoid and HumanoidRootPart.
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid then return end
    if not HumanoidRootPart then return end
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

        --Leech from other players until they leave or die.
        while Humanoid.Health > 0 and Character.Parent and Player.Parent and Player.Character == Player.Character do
            --Leech health from enemy players.
            local RemainingHealthToLeech = Humanoid.MaxHealth - Humanoid.Health
            local TotalHealthLeeched = 0
            for _,OtherPlayer in pairs(Players:GetPlayers()) do
                if RemainingHealthToLeech == 0 then break end
                if Player ~= OtherPlayer then
                    local OtherCharacter = OtherPlayer.Character
                    if OtherCharacter and (Player.Neutral or Player.TeamColor ~= OtherPlayer.TeamColor) then
                        local OtherHumanoid = OtherCharacter:FindFirstChild("Humanoid")
                        local OtherHumanoidRootPart = OtherCharacter:FindFirstChild("HumanoidRootPart")
                        if OtherHumanoid and OtherHumanoid.Health > 0 and OtherHumanoidRootPart and (OtherHumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude < LEECH_MAX_RANGE then
                            local HealthToLeech = math.min(OtherHumanoid.Health,RemainingHealthToLeech,Value)
                            Humanoid.Health = Humanoid.Health + HealthToLeech
                            DamageService:DamageHumanoid(OtherHumanoid,HealthToLeech,Player,"Leeching")
                            RemainingHealthToLeech = RemainingHealthToLeech - HealthToLeech
                            TotalHealthLeeched = TotalHealthLeeched + HealthToLeech
                            LocalEffectService:BroadcastLocalEffect(Player,"PlayLeechingEffect",OtherHumanoidRootPart,HumanoidRootPart)
                        end
                    end
                end
            end

            --Damage the armor.
            if TotalHealthLeeched > 0 then
                InventoryService:DamageArmor(Player,"Leeching",TotalHealthLeeched/Value)
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