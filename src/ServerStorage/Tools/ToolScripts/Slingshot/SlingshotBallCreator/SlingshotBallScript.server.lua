--[[
TheNexusAvenger

Runs the server slingshot ball.
--]]

local Configuration = require(script:WaitForChild("Configuration"))

local SLINGSHOT_DECAY_TIME = Configuration.SLINGSHOT_DECAY_TIME
local SLINGSHOT_START_DAMAGE = Configuration.SLINGSHOT_START_DAMAGE



local SlingshotBall = script.Parent
local Debris = game:GetService("Debris")

local PlayerDamager = require(script:WaitForChild("PlayerDamager"))
local FiredByValue = SlingshotBall:WaitForChild("FiredBy",10^99)
while FiredByValue.Value == nil do FiredByValue.Changed:Wait() end

local CurrentDamage = SLINGSHOT_START_DAMAGE
local FiredPlayer = FiredByValue.Value
local FiredCharacter = FiredPlayer.Character

local LastHitCharacter
local TouchConnection

Debris:AddItem(SlingshotBall,SLINGSHOT_DECAY_TIME)



--[[
Returns the player that reflected the ball, if any.
--]]
local function GetReflectedByPlayer()
    local ReflectedByValue = FiredByValue:FindFirstChild("ReflectedBy")
    while ReflectedByValue and ReflectedByValue:FindFirstChild("ReflectedBy") do
        ReflectedByValue = ReflectedByValue:FindFirstChild("ReflectedBy")
    end
    return ReflectedByValue and ReflectedByValue.Value
end

--[[
Returns the name of the weapon to display in a kill feed.
--]]
local function GetDamageName()
    if GetReflectedByPlayer() then
        return "Reflector"
    end
    return "Slingshot"
end

--[[
Handles the ball being touched.
--]]
local function SlingshotBallHit(TouchPart)
    if TouchPart.Name == "Handle" or not TouchPart.Parent then return end

    local HitHumanoid = TouchPart.Parent:FindFirstChild("Humanoid")
    if HitHumanoid and HitHumanoid.Parent ~= LastHitCharacter then
        if SLINGSHOT_START_DAMAGE == CurrentDamage and TouchPart.Parent == FiredCharacter then
            return
        end

        LastHitCharacter = HitHumanoid.Parent
        PlayerDamager:DamageHumanoid(GetReflectedByPlayer() or FiredPlayer,HitHumanoid,CurrentDamage,GetDamageName())
    else
        if not TouchPart.CanCollide then return end
        CurrentDamage = CurrentDamage/1.42

        if CurrentDamage < 1 and TouchConnection then
            TouchConnection:disconnect()
            TouchConnection = nil
            SlingshotBall:Destroy()
        end
    end
end



--Set up the touched connection.
TouchConnection = SlingshotBall.Touched:Connect(function(TouchPart)
    SlingshotBallHit(TouchPart)
end)