--[[
TheNexusAvenger

Creates a bomb explosion. Minor modifications from the Rocket Launcher.
--]]

local Configuration = require(script.Parent:WaitForChild("Configuration"))

local FORCE_GRANULARITY = Configuration.FORCE_GRANULARITY
local BLAST_RADIUS = Configuration.BLAST_RADIUS
local BLAST_PRESSURE = Configuration.BLAST_PRESSURE * FORCE_GRANULARITY
local MIN_DAMAGE = Configuration.MIN_DAMAGE
local MAX_DAMAGE = Configuration.MAX_DAMAGE

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local PlayerDamager = require(script.Parent:WaitForChild("PlayerDamager"))
local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")
local RoundService = ServerScriptServiceProject:GetResource("Service.RoundService")

local ExplosionCreator = {}



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
Creates an explosion at the specified location. Return sthe explosion.
--]]
function ExplosionCreator:CreateExplosion(Position,FiredPlayer,ReflectedPlayer,DamageName,ExplosionSound)
    local RegisteredPlayers = {}

    --[[
    Regester hits from exploisions.
    --]]
    local function OnExplosionHit(ExplosionTouchPart,RadiusFromBlast)
        local IsInCharacter = false

        if ExplosionTouchPart.Size.Magnitude/2 < 20 then
            local BreakJoints = (ExplosionTouchPart.Name ~= "Bomb")

            --Damage the character if one exists and disable breaking joints.
            local HitCharacter,HitHumanoid = FindCharacterAncestor(ExplosionTouchPart)
            if HitCharacter then
                IsInCharacter = true
                BreakJoints = false

                local HitPlayer = Players:GetPlayerFromCharacter(HitCharacter)
                if (HitPlayer and not RegisteredPlayers[HitPlayer]) or (not HitPlayer and not RegisteredPlayers[HitCharacter]) then
                    RegisteredPlayers[HitPlayer or HitCharacter] = true

                    local ActualFiredPlayer = ReflectedPlayer or FiredPlayer
                    local DoDamage = PlayerDamager:CanDamageHumanoid(ActualFiredPlayer,HitHumanoid)
                    if DoDamage then
                        local DamageFraction = 0
                        if RadiusFromBlast < BLAST_RADIUS/2 then
                            DamageFraction = 1
                        elseif RadiusFromBlast < BLAST_RADIUS then
                            DamageFraction = 1 - (RadiusFromBlast - BLAST_RADIUS/2)/(BLAST_RADIUS/2)
                        end

                        PlayerDamager:DamageHumanoid(ActualFiredPlayer,HitHumanoid,MIN_DAMAGE + (DamageFraction * (MAX_DAMAGE - MIN_DAMAGE)),DamageName)
                    end
                end
            end

            --Break joints if it isn't a character.
            if BreakJoints then
                ExplosionTouchPart:BreakJoints()
            end

            --If the part is able to fade with explosions, signal it to fade.
            local Destructible = ExplosionTouchPart:FindFirstChild("RocketDestructible")
            if Destructible and Destructible.Value and RadiusFromBlast < BLAST_RADIUS then
                Destructible.Value = false

                LocalEffectService:BroadcastLocalEffect(FiredPlayer,"FadePart",ExplosionTouchPart)
                Debris:AddItem(ExplosionTouchPart,3)
            end

            local DeltaPos = ExplosionTouchPart.Position - Position
            local Normal = DeltaPos.magnitude == 0 and Vector3.new(0,1,0) or DeltaPos.unit
            local PartRadius = ExplosionTouchPart.Size.Magnitude / 2
            local SurfaceArea = PartRadius * PartRadius

            --Set the velocity of the part.
            local Impulse = Normal * BLAST_PRESSURE * SurfaceArea * (1 / 4560)
            local Fraction = 1
            if IsInCharacter then
                Fraction = 1 - math.max(0, math.min(1,(RadiusFromBlast - 2) / BLAST_RADIUS))
            end

            local CurrentVelocity = ExplosionTouchPart.AssemblyAngularVelocity
            local DeltaVelocity = Impulse / ExplosionTouchPart:GetMass()
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Velocity = CurrentVelocity + DeltaVelocity
            BodyVelocity.Parent = ExplosionTouchPart

            local ForceNeeded = Workspace.Gravity * ExplosionTouchPart:GetMass()
            BodyVelocity.MaxForce = Vector3.new(ForceNeeded,ForceNeeded,ForceNeeded) * 10 * Fraction
            Debris:AddItem(BodyVelocity,0.2/FORCE_GRANULARITY)

            local RotImpulse = Impulse * 0.5 * RadiusFromBlast
            local CurrentRotVelocity = ExplosionTouchPart.AssemblyAngularVelocity
            local MomentOfInertia = (2 * ExplosionTouchPart:GetMass() * RadiusFromBlast * RadiusFromBlast/5)
            local DeltaRotVelocity = RotImpulse / MomentOfInertia
            local AngularVelocity = Instance.new("BodyAngularVelocity")
            local TorqueNeeded = 20 * MomentOfInertia
            AngularVelocity.MaxTorque = Vector3.new(TorqueNeeded,TorqueNeeded,TorqueNeeded) * 10 * Fraction
            AngularVelocity.AngularVelocity = CurrentRotVelocity + DeltaRotVelocity
            AngularVelocity.Parent = ExplosionTouchPart
            Debris:AddItem(AngularVelocity,0.2/FORCE_GRANULARITY)
        end
    end

    --Create the explosion.
    local Explosion = Instance.new("Explosion")
    Explosion.BlastPressure = 0
    Explosion.BlastRadius = BLAST_RADIUS
    Explosion.Position = Position
    Explosion.Hit:Connect(OnExplosionHit)
    Explosion.Parent = RoundService:GetPlayerRoundContainer(FiredPlayer) or Workspace

    --Play the sound.
    LocalEffectService:BroadcastLocalEffect(FiredPlayer,"PlaySound",ExplosionSound,1,Position)

    --Return the explosion.
    return Explosion
end



return ExplosionCreator