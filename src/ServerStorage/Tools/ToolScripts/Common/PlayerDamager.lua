--[[
TheNexusAvenger

Centralizes player damaging.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))
local DamageService = ServerScriptServiceProject:GetResource("Service.DamageService")

local PlayerDamager = {}



--[[
Returns whether damage can be done to a humanoid.
--]]
function PlayerDamager:CanDamageHumanoid(DamagingPlayer,Humanoid)
    local HitPlayer = Players:GetPlayerFromCharacter(Humanoid.Parent)
    if HitPlayer and DamagingPlayer ~= HitPlayer and HitPlayer.TeamColor == DamagingPlayer.TeamColor and not HitPlayer.Neutral then
        return false
    end

    return true
end

--[[
Damages the humanoid.
--]]
function PlayerDamager:DamageHumanoid(DamagingPlayer,Humanoid,Damage,ToolName)
    --Check if it can be damaged.
    if not PlayerDamager:CanDamageHumanoid(DamagingPlayer,Humanoid) or not Humanoid.Parent then
        return
    end

    --Damage the humanoid.
    DamageService:DamageHumanoid(Humanoid,Damage,DamagingPlayer,ToolName)
end



return PlayerDamager
