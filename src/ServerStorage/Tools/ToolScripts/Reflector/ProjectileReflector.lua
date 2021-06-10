--[[
TheNexusAvenger

Runs the reflector effect.
--]]

local EFFECT_TIME_DELAY = 0.2
local REFLECT_RADIUS = Vector3.new(24,24,24)



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")

local ProjectileReflector = {}



--[[
Reflects proctiles and sets the target to the sender.
--]]
local function ReflectProjectiles(Handle,Center)
    if not Handle.Parent then return end
    local Character = Handle.Parent.Parent
    local Player = Players:GetPlayerFromCharacter(Character)

    --Set the reflected tags.
    --Actually reflecting is done by the client.
    local Parts = Workspace:FindPartsInRegion3(Region3.new(Center - REFLECT_RADIUS,Center + REFLECT_RADIUS),Character,100)
    for _,Projectile in pairs(Parts) do
        local FiredByValue = Projectile:FindFirstChild("FiredBy")
        if FiredByValue and FiredByValue.Value and not Projectile:FindFirstChild("BodyWeld") then
            --Get the last relevant tag.
            local LatestTag = FiredByValue
            while LatestTag:FindFirstChild("ReflectedBy") do
                LatestTag = LatestTag:FindFirstChild("ReflectedBy")
            end

            --Add the ReflectedBy tag.
            if LatestTag.Value ~= Player then
                local ReflectedBy = Instance.new("ObjectValue")
                ReflectedBy.Name = "ReflectedBy"
                ReflectedBy.Value = Player
                ReflectedBy.Parent = LatestTag

                local LocallyReflected = Instance.new("BoolValue")
                LocallyReflected.Name = "LocallyReflected"
                LocallyReflected.Value = false
                LocallyReflected.Parent = ReflectedBy
            end
        end
    end
end



--[[
Runs the reflect animation and logic.
--]]
function ProjectileReflector:ReflectProjectiles(ReflectorHandle)
    --Play the effect on the clients.
    local Character = ReflectorHandle.Parent.Parent
    if not Character then return end
    local Player = Players:GetPlayerFromCharacter(Character)
    if not Player then return end
    LocalEffectService:BroadcastLocalEffect(Player,"ReflectEffect",ReflectorHandle)

    --Reflect projectiles (set the tags).
    wait(EFFECT_TIME_DELAY)
    local StartTime = time()
    local CenterPos = ReflectorHandle.Position
    while time() - StartTime < EFFECT_TIME_DELAY do
        ReflectProjectiles(ReflectorHandle,CenterPos)
        wait()
    end
end



return ProjectileReflector