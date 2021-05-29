--[[
TheNexusAvenger

Contains the information about the armor.
Append new items to end. NEVER overlap or change ids.
--]]

return {
    --Ids 1-100: Head
    CrownOfWealth = {
        Name = "Crown Of Wealth",
        Description = "Gives you an extra 2 coins every time you kill someone. Degrades after giving you 150 extra coins.",
        Slot = "Head",
        Id = 1,
        Cost = 50,
        MaxHealth = 150,
        Modifiers = {
            ExtraCoins = 2,
        },
    },
    SpeedHelmet = {
        Name = "Speedy Visor",
        Description = "+2 Speed",
        Slot = "Head",
        Id = 2,
        Cost = 80,
        MaxHealth = 22000,
        Modifiers = {
            Speed = 2,
        },
    },
    ShardHead = {
        Name = "Shard Helmet",
        Description = "Stolen from the bleak landscape of the shard, offers no protection, but looks really cool.",
        Slot = "Head",
        Id = 3,
        Cost = 1000,
    },

    --Ids 101-200: Body
    LightBodyArmor = {
        Name = "Light Body Armor",
        Description = "This armor provides basic protection.",
        Slot = "Body",
        Id = 101,
        Cost = 100,
        MaxHealth = 300,
        Modifiers = {
            AbsorbDamage = 0.1,
        },
    },
    MediumBodyArmor = {
        Name = "Medium Body Armor",
        Description = "This armor provides moderate protection.",
        Slot = "Body",
        Id = 102,
        Cost = 250,
        MaxHealth = 660,
        Modifiers = {
            AbsorbDamage = 0.2,
        },
    },
    RegenGauntlet = {
        Name = "Regeneration Gauntlet",
        Description = "Provides extra health regeneration.\n+3 restored/second",
        Slot = "Body",
        Id = 103,
        Cost = 250,
        MaxHealth = 900,
        Modifiers = {
            Regeneration = 3,
        },
    },
    ReactiveBody = {
        Name = "Reactive Body Armor",
        Description = "Doesn't prevent any damage, but sends some back the way of your attacker.\n+2 Reactance\n-1 Speed",
        Slot = "Body",
        Id = 104,
        Cost = 300,
        MaxHealth = 800,
        Modifiers = {
            Reactance = 2,
            Speed = -1,
        },
    },
    LeechingBody = {
        Name = "Leeching Body",
        Description = "Leeches 8 health/second from nearby players when you are hurt.",
        Slot = "Body",
        Id = 105,
        Cost = 400,
        MaxHealth = 700,
        Modifiers = {
            Leeching = 8, --TODO: Modifier not implemented
        },
    },
    HeavyBodyArmor = {
        Name = "Heavy Body Armor",
        Description = "This armor provides extreme protection.",
        Slot = "Body",
        Id = 106,
        Cost = 500,
        MaxHealth = 1050,
        Modifiers = {
            AbsorbDamage = 0.3,
        },
    },
    ShardBody = {
        Name = "Shard Plating",
        Description = "Stolen from the bleak landscape of the shard, offers no protection, but looks really cool.",
        Slot = "Body",
        Id = 107,
        Cost = 2000,
    },

    --Ids 201-300: Legs
    LightLegArmor = {
        Name = "Light Leg Armor",
        Description = "This armor provides extra protection.",
        Slot = "Legs",
        Id = 201,
        Cost = 75,
        MaxHealth = 150,
        Modifiers = {
            AbsorbDamage = 0.05,
        },
    },
    SpeedBoots = {
        Name = "Speedy Boots",
        Description = "+2 Speed",
        Slot = "Legs",
        Id = 202,
        Cost = 100,
        MaxHealth = 30000,
        Modifiers = {
            Speed = 2,
        },
    },
    ReactiveLegs = {
        Name = "Reactive Leg Armor",
        Description = "Doesn't prevent any damage, but sends some back the way of your attacker.\n+1 Reactance\n-1 Speed",
        Slot = "Legs",
        Id = 203,
        Cost = 200,
        MaxHealth = 550,
        Modifiers = {
            Reactance = 1,
            Speed = -1,
        },
    },
}