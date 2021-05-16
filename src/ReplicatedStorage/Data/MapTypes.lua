--[[
TheNexusAvenger

Maps that can be used.
--]]

return {
    Bloxburg = {
        GameTypes = {"FreeForAll","OneWeaponRocketLauncher","OneWeaponSuperball","OneWeaponMadness","Party","BurnDown","Juggernaut","SwordElimination","TeamDeathmatch","TeamSwap","CaptureTheFlag",},
        ImageId = 116668979, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(70/255,70/255,70/255),
            FogColor = Color3.new(159/255,159/255,159/255),
            FogEnd = 2000,
            TimeOfDay = 14,
        },
    },
    Crossroads = {
        GameTypes = {"FreeForAll","OneWeaponRocketLauncher","OneWeaponSuperball","OneWeaponMadness","Party","BurnDown","Juggernaut","SwordElimination","TeamDeathmatch","TeamSwap",},
        ImageId = 116669007, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(75/255,75/255,75/255),
            FogColor = Color3.new(212/255,250/255,255/255),
            FogEnd = 2000,
            ShadowColor = Color3.new(1,1,1),
            TimeOfDay = 9,
        },
    },
    RavenRock = {
        GameTypes = {"FreeForAll","OneWeaponSword","OneWeaponBomb","OneWeaponSuperball","OneWeaponRocketLauncher","OneWeaponMadness","Party","BurnDown","Juggernaut","SwordElimination","TeamDeathmatch","TeamSwap",},
        ImageId = 116669027, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(75/255,75/255,75/255),
            FogColor = Color3.new(212/255,250/255,255/255),
            FogEnd = 2000,
            ShadowColor = Color3.new(1,1,1),
            TimeOfDay = 10,
        },
    },
    Skylands = {
        GameTypes = {"FreeForAll","OneWeaponRocketLauncher","OneWeaponSuperball","OneWeaponMadness","Party","BurnDown","Juggernaut","SwordSwept","TeamDeathmatch","TeamSwap","CaptureTheFlag",},
        ImageId = 119699444, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(80/255,80/255,80/255),
            FogColor = Color3.new(147/255,207/255,227/255),
            FogEnd = 800,
            FogStart = 200,
            ShadowColor = Color3.new(116/255,116/255,116/255),
            TimeOfDay = 14,
        },
    },
    TheDepths = {
        GameTypes = {"OneWeaponBomb","BurnDown",},
        ImageId = 122085514, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(127/255,127/255,127/255),
            OutdoorAmbient = Color3.new(127/255,127/255,127/255),
            ShadowColor = Color3.new(179/255,179/255,184/255),
            TimeOfDay = 14,
        },
    },
    TheShard = {
        GameTypes = {"FreeForAll","OneWeaponSuperball","OneWeaponMadness","Juggernaut","TeamDeathmatch","TeamSwap",},
        ImageId = 117446222, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(75/255,75/255,75/255),
            FogColor = Color3.new(212/255,250/255,255/255),
            FogEnd = 2000,
            ShadowColor = Color3.new(1,1,1),
            TimeOfDay = 9,
        },
    },
    DodgeballArena = {
        GameTypes = {"Dodgeball",},
        ImageId = 122328784, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(33/255,33/255,33/255),
            FogColor = Color3.new(0,0,0),
            FogEnd = 1000000,
            FogStart = 10000,
            OutdoorAmbient = Color3.new(27/255,27/255,27/255),
            ShadowColor = Color3.new(190/255,190/255,190/255),
            TimeOfDay = 1,
        },
    },
    RocketRace = {
        GameTypes = {"RocketRace",},
        ImageId = 3040728324, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(0,0,0),
            FogColor = Color3.new(0,0,0),
            FogEnd = 500,
            FogStart = 100,
            OutdoorAmbient = Color3.new(100/255,100/255,100/255),
            ShadowColor = Color3.new(100/255,100/255,100/255),
            TimeOfDay = 8,
        },
    },
    KingOfTheHill = {
        GameTypes = {"KingOfTheHill",},
        ImageId = 300084452, --TODO: Update image
        Lighting = {
            Ambient = Color3.new(128/255,128/255,128/255),
            FogEnd = 1000,
            FogStart = 100,
            ShadowColor = Color3.new(0/255,0/255,0/255),
            TimeOfDay = 14,
        }
    },
}