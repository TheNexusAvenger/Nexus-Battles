--[[
TheNexusAvenger

Runs the rocket projectile.
--]]

local Configuration = require(script:WaitForChild("Configuration"))

local ROCKET_DECAY_TIME = Configuration.ROCKET_DECAY_TIME
local IGNORE_LIST = Configuration.IGNORE_LIST

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local Rocket = script.Parent
local SwooshSound = Rocket:WaitForChild("SwooshSound")

local ExplodeEvent = Instance.new("RemoteEvent")
ExplodeEvent.Name = "Explode"
ExplodeEvent.Parent = Rocket

local ExplosionCreator = require(script:WaitForChild("ExplosionCreator"))
local FiredByValue = Rocket:WaitForChild("FiredBy",10^99)
while FiredByValue.Value == nil do FiredByValue.Changed:Wait() end

local FiredPlayer = FiredByValue.Value
local FiredCharacter = FiredPlayer.Character
local Exploded = false

SwooshSound:Play()
Debris:AddItem(Rocket,ROCKET_DECAY_TIME)

for Key,Value in pairs(IGNORE_LIST) do
    if type(Key) == "string" then
        IGNORE_LIST[string.lower(Key)] = Value
    end
end



--[[
Returns the character and humanoid of a descendants.
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
Returns the player that reflected the rocket, if any.
--]]
local function GetReflectedByPlayer()
    local ReflectedByValue = FiredByValue:FindFirstChild("ReflectedBy")
    return ReflectedByValue and ReflectedByValue.Value
end

--[[
Returns the name of the weapon for the kill feeds.
--]]
local function GetDamageName()
    if GetReflectedByPlayer() then
        return "Reflector"
    end
    return "Rocket Launcher"
end

--[[
Explodes the rocket at the given position.
--]]
local function Explode(Position)
    if Exploded == false then
        Exploded = true
        local Explosion = ExplosionCreator:CreateExplosion(Position,FiredPlayer,GetReflectedByPlayer(),GetDamageName(),"rbxasset://sounds/collide.wav")
        script.Parent = Explosion
        Rocket:Destroy()
    end
end



--Register touched events.
Rocket.Touched:Connect(function(TouchPart)
    if not Exploded and not IGNORE_LIST[string.lower(TouchPart.Name)] and (not TouchPart:IsDescendantOf(FiredCharacter) or GetReflectedByPlayer()) then
        Explode((Rocket.CFrame * CFrame.new(0,0,-Rocket.Size.Z/2)).Position)
    end
end)

ExplodeEvent.OnServerEvent:Connect(function(_,Position)
    local PositionDelta = (Rocket.Position - Position).magnitude
    if PositionDelta < 50 or PositionDelta > 5000 then
        Explode(Position)
    end
end)