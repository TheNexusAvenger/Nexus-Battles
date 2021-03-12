--[[
TheNexusAvenger

Runs the reflector effect.
--]]

local EFFECT_TIME_DELAY = 0.2
local REFLECT_RADIUS = Vector3.new(20,20,20)

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

    local Parts = Workspace:FindPartsInRegion3(Region3.new(Center - REFLECT_RADIUS,Center + REFLECT_RADIUS),Character,100)
    for _,Projectile in pairs(Parts) do
        local FiredByValue = Projectile:FindFirstChild("FiredBy")
        if FiredByValue and FiredByValue.Value and not Projectile:FindFirstChild("BodyWeld") then
            local ReflectedBy = FiredByValue:FindFirstChild("ReflectedBy")
            if (not ReflectedBy and FiredByValue.Value ~= Player) or (ReflectedBy and ReflectedBy.Value ~= Player) then
                if ReflectedBy then ReflectedBy:Destroy() end
                ReflectedBy = Instance.new("ObjectValue")
                ReflectedBy.Name = "ReflectedBy"
                ReflectedBy.Value = Player
                ReflectedBy.Parent = FiredByValue
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