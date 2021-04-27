--[[
TheNexusAvenger

Runs the bomb projectile.
--]]

local Bomb = script.Parent
local BombMesh = Bomb:WaitForChild("BombMesh")
local BeepSound = Bomb:WaitForChild("BeepSound")
local Light = Bomb:WaitForChild("Light")

local Debris = game:GetService("Debris")

local ExplosionCreator = require(script:WaitForChild("ExplosionCreator"))
local FiredByValue = Bomb:WaitForChild("FiredBy",10^99)
while FiredByValue.Value == nil do FiredByValue.Changed:Wait() end

local FiredPlayer = FiredByValue.Value
local Exploded = false

Debris:AddItem(Bomb,5)




--[[
Returns the player that reflected the rocket, if any.
--]]
local function GetReflectedByPlayer()
    local ReflectedByValue = FiredByValue:FindFirstChild("ReflectedBy")
    while ReflectedByValue and ReflectedByValue:FindFirstChild("ReflectedBy") do
        ReflectedByValue = ReflectedByValue:FindFirstChild("ReflectedBy")
    end
    return ReflectedByValue and ReflectedByValue.Value
end

--[[
Returns the name of the weapon for the kill feeds.
--]]
local function GetDamageName()
    if GetReflectedByPlayer() then
        return "Reflector"
    end
    return "Bomb"
end

--[[
Explodes the rocket at the given position.
--]]
local function Explode(Position)
    if Exploded == false then
        Exploded = true

        --Reparent the script to the explosion and destroy the bomb.
        local Explosion = ExplosionCreator:CreateExplosion(Position,FiredPlayer,GetReflectedByPlayer(),GetDamageName(),"rbxasset://sounds/Rocket shot.wav")
        script.Parent = Explosion
        Bomb:Destroy()
    end
end



--Run countdown sequence.
local TickTime = 0.4
local IsRed = true
repeat
    BombMesh.TextureId = IsRed and "http://www.roblox.com/asset/?id=94691735"  or "http://www.roblox.com/asset/?id=94691681"
    Light.Enabled = IsRed
    BeepSound:Play()
    wait(TickTime)

    IsRed = not IsRed
    TickTime = TickTime * 0.9
until TickTime < 0.1

Explode(Bomb.Position)