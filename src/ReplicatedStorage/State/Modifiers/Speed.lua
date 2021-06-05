--[[
TheNexusAvenger

Applies speed boosts to a player.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local InventoryService = ServerScriptServiceProject:GetResource("Service.InventoryService")

local LastCharacterUpdates = {}
return function(Character,Value)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not HumanoidRootPart then return end
    Humanoid.WalkSpeed = 16 + Value

    --Get the reference player.
    local Player = Players:GetPlayerFromCharacter(Character)
    if not Player then return end

    --Start damaging the armor while walking.
    coroutine.wrap(function()
        --Set the start time to stop after getting another call.
        local StartTime = tick()
        LastCharacterUpdates[Character] = StartTime

        --Damage the armor until they leave or die.
        local LastPosition = HumanoidRootPart.Position
        while Humanoid.Health > 0 and Character.Parent and Player.Parent and Player.Character == Player.Character do
            --Damage the armor.
            local CurrentPosition = HumanoidRootPart.Position
            local Magnitude = (CurrentPosition - LastPosition).Magnitude
            if Magnitude <= Humanoid.WalkSpeed * 2 then
                InventoryService:DamageArmor(Player,"Speed",Magnitude)
            end
            LastPosition = CurrentPosition

            --Wait 1 second to continue.
            wait(1)
        end

        --Clear the value.
        if LastCharacterUpdates[Character] == StartTime then
            LastCharacterUpdates[Character] = nil
        end
    end)()
end