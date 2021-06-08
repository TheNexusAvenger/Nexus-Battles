--[[
TheNexusAvenger

Damages players hit by the rock.
--]]

local Players = game:GetService("Players")

local Rock = script.Parent
local PlayerDamager = require(script:WaitForChild("PlayerDamager"))

local HitPlayers = {}



--Connect the rock touching a player.
Rock.Touched:Connect(function(Part)
    --Return if the rock is too slow.
    if Rock.Velocity.Magnitude <= 5 then return end

    --Determine the Humanoid to damage.
    local FiredPlayer = Rock:WaitForChild("FiredBy").Value
    if not Part then return end
    local Character = Part.Parent
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    local Player = Players:GetPlayerFromCharacter(Character)
    if Player == FiredPlayer or HitPlayers[Player] then return end

    --Damage the player.
    HitPlayers[Player] = true
    PlayerDamager:DamageHumanoid(FiredPlayer,Humanoid,10,"DualRocks")
    Rock:WaitForChild("Hit"):Play()
end)