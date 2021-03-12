--[[
TheNexusAvenger

Centralizes storing and playing animations.
Unless non-Roblox animations become public, the R15 animations will not work.
--]]

local ASSET_URL = "http://www.roblox.com/asset?id="



local AnimationIds
if game.PlaceId == 6341211542 then
    --Test place (under Nexus Development Quality Assurance)
    AnimationIds = {
        --Bomb
        ["BombHold"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94861246",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960980426",
        },
        ["BombThrow"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94861252",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960981686",
        },

        --Broom
        ["BroomIdle"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."101074752",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960982045",
        },
        ["BroomWhack"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."101078539",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960982598",
        },

        --Reflector
        ["ReflectorActivate"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94190213",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960983050",
        },

        --Rocket Launcher
        ["RocketLauncherFireAndReload"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94771598",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960984492",
        },

        --Slingshot
        ["SlingshotEquip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94123357",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960984865",
        },
        ["SlingshotShoot"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94126022",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960985364",
        },

        --Superball
        ["SuperballEquip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94156535",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960986220",
        },
        ["SuperballUnequip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94156580",
            --Unused
        },
        ["SuperballIdle"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94156486",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960986577",
        },
        ["SuperballThrow"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94157627",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960986912",
        },

        --Sword
        ["SwordEquip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94160581",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960987338",
        },
        ["SwordUnequip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94095929",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960987857",
        },
        ["SwordIdle"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94108418",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960988663",
        },
        ["SwordSlash"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94161088",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960989171",
        },
        ["SwordThrust"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94161333",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960989618",
        },
        ["SwordOverhead"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94160738",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960990006",
        },

        --Lobby Flag
        ["FlagPlant"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."74897796",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2960990569",
        }
    }
else
    --Production (under Nexus Development).
    AnimationIds = {
        --Bomb
        ["BombHold"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94861246",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117071887",
        },
        ["BombThrow"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94861252",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117073081",
        },

        --Broom
        ["BroomIdle"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."101074752",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117074222",
        },
        ["BroomWhack"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."101078539",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117075188",
        },

        --Reflector
        ["ReflectorActivate"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94190213",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117076127",
        },

        --Rocket Launcher
        ["RocketLauncherFireAndReload"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94771598",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117147821",
        },

        --Slingshot
        ["SlingshotEquip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94123357",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117134813",
        },
        ["SlingshotShoot"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94126022",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117077332",
        },

        --Superball
        ["SuperballEquip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94156535",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117139414",
        },
        ["SuperballUnequip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94156580",
            --Unused
        },
        ["SuperballIdle"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94156486",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117136844",
        },
        ["SuperballThrow"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94157627",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117138253",
        },

        --Sword
        ["SwordEquip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94160581",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117140777",
        },
        ["SwordUnequip"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94095929",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."02117145389",
        },
        ["SwordIdle"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94108418",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117141602",
        },
        ["SwordSlash"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94161088",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117143663",
        },
        ["SwordThrust"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94161333",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117144519",
        },
        ["SwordOverhead"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."94160738",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117142586",
        },

        --Lobby Flag
        ["FlagPlant"] = {
            [Enum.HumanoidRigType.R6] = ASSET_URL.."74897796",
            [Enum.HumanoidRigType.R15] = ASSET_URL.."2117146258",
        }
    }
end

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
                local AnimationGroup = AnimationIds[AnimationName]
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