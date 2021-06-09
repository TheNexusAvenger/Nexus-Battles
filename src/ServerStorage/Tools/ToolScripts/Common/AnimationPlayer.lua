--[[
TheNexusAvenger

Centralizes storing and playing animations.
Unless non-Roblox animations become public, the R15 animations will not work.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animations = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Animations"))
local AnimationSettings = {
    --Bomb
    ["BombHold"] = {
        FadeTime = 0,
        Weight = 1,
        Speed = 2,
    },

    --Broom
    ["BroomWhack"] = {
        FadeTime = 0,
        Weight = 1,
        Speed = 10, --Should be BROOM_WHACK_SPEED
    },

    --Reflector
    ["ReflectorActivate"] = {
        FadeTime = 0.1,
        Weight = 1,
        Speed = 6,
    },

    --Rocket Launcher
    ["RocketLauncherFireAndReload"] = {
        FadeTime = 0.1,
        Weight = 1,
        Speed = 1.5,
    },

    --Lobby Flag
    ["FlagPlant"] = {
        Speed = 0.5,
    }
}



local AnimationPlayer = {}

local Tool = script.Parent



--[[
Returns an animation class for the given id.
--]]
local AnimationCache = {}
local function GetAnimation(AnimationId)
    if not AnimationCache[AnimationId] then
        local Animation = Instance.new("Animation")
        Animation.AnimationId = AnimationId
        AnimationCache[AnimationId] = Animation
    end

    return AnimationCache[AnimationId]
end

--[[
Players the animation by name for the tool holder.
--]]
function AnimationPlayer:PlayAnimation(AnimationName)
    local Character = Tool.Parent
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            local Animator = Humanoid:FindFirstChildOfClass("Animator")
            if Animator then
                local AnimationGroup = Animations[AnimationName]
                if AnimationGroup then
                    local AnimationId = AnimationGroup[Humanoid.RigType]
                    if AnimationId then
                        local LoadedAnimation = Animator:LoadAnimation(GetAnimation(AnimationId))
                        local AnimationData = AnimationSettings[AnimationName] or {}
                        LoadedAnimation:Play(AnimationData.FadeTime,AnimationData.Weight,AnimationData.Speed)

                        return LoadedAnimation
                    end
                else
                    warn("Missing animation name: "..tostring(AnimationName))
                end
            end
        end
    end
end



return AnimationPlayer