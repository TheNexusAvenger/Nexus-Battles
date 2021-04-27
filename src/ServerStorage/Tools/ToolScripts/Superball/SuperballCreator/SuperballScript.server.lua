--[[
TheNexusAvenger

Runs the server superball projectile.
--]]

local Configuration = require(script:WaitForChild("Configuration"))

local SUPERBALL_DECAY_TIME = Configuration.SUPERBALL_DECAY_TIME
local SUPERBALL_MIN_DAMAGE = Configuration.SUPERBALL_MIN_DAMAGE
local SUPERBALL_START_DAMAGE = Configuration.SUPERBALL_START_DAMAGE
local SUPERBALL_DAMAGE_DECAY_RATIO = Configuration.SUPERBALL_DAMAGE_DECAY_RATIO

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))
local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")

local Superball = script.Parent
local PlayerDamager = require(script:WaitForChild("PlayerDamager"))
local FiredByValue = Superball:WaitForChild("FiredBy",10^99)
while FiredByValue.Value == nil do FiredByValue.Changed:Wait() end

local CurrentDamage = SUPERBALL_START_DAMAGE
local LastSoundTime = 0
local FiredPlayer = FiredByValue.Value
local LastHitCharacter

Debris:AddItem(Superball,SUPERBALL_DECAY_TIME)



--[[
Returns the character and humanoid for the given descendants.
--]]
local function FindCharacterAncestor(Ins)
    if Ins and Ins ~= Workspace then
        local Humanoid = Ins:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            return Ins,Humanoid
        else
            return FindCharacterAncestor(Ins.Parent)
        end
    end
end

--[[
Returns the character that reflected the projectile, if any.
--]]
local function GetReflectedByPlayer()
    local ReflectedByValue = FiredByValue:FindFirstChild("ReflectedBy")
    while ReflectedByValue and ReflectedByValue:FindFirstChild("ReflectedBy") do
        ReflectedByValue = ReflectedByValue:FindFirstChild("ReflectedBy")
    end
    return ReflectedByValue and ReflectedByValue.Value
end

--[[
Gets the name to appear on the kill feed.
--]]
local function GetDamageName()
    if GetReflectedByPlayer() then
        return "Reflector"
    end
    return "Superball"
end



--[[
Registers a superball hit.
--]]
local function SuperballHit(TouchPart)
    local Humanoid = (FiredPlayer.Character and FiredPlayer.Character:FindFirstChildOfClass("Humanoid"))
    local HitCharacter,HitHumanoid = FindCharacterAncestor(TouchPart)
    if HitHumanoid then
        --If it hit a character, damage the character.
        if Humanoid and (Humanoid ~= HitHumanoid or CurrentDamage < SUPERBALL_START_DAMAGE) and (not LastHitCharacter or HitCharacter ~= LastHitCharacter) then
            LastHitCharacter = HitCharacter
            PlayerDamager:DamageHumanoid(GetReflectedByPlayer() or FiredPlayer,HitHumanoid,CurrentDamage,GetDamageName())
        end
    else
        --If it hit something else, decrease the damage if it was last hit 0.32 seconds ago.
        local CurrentTime = tick()
        if CurrentTime - LastSoundTime > 0.32 then
            LastSoundTime = CurrentTime
            CurrentDamage = math.max(SUPERBALL_MIN_DAMAGE,CurrentDamage * SUPERBALL_DAMAGE_DECAY_RATIO)
        end

        --Allow hitting the same character twice if it was more than 0.3 second ago.
        if CurrentTime - LastSoundTime > 0.3 then
            LastHitCharacter = nil
        end
    end
end



--Set up touched event.
Superball.Touched:Connect(function(TouchPart)
    SuperballHit(TouchPart)
end)
LocalEffectService:BroadcastLocalEffect(FiredPlayer,"SuperballEffect",Superball)