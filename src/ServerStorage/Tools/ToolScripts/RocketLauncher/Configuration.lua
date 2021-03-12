--[[
TheNexusAvenger

Configuration of the rocket launcher.
--]]

return {
    --Reload time of the rocket.
    ROCKET_RELOAD_TIME = 3,

    --Times for showing rocket.
    ROCKET_RELOAD_WAIT_TO_SHOW_TIME = 1,
    ROCKET_RELOAD_VISIBLE_TIME = 0.45,

    --Speed of the rocket.
    ROCKET_LAUNCH_SPEED = 60,

    --List of the instances to ignore by name. Case does not matter.
    IGNORE_LIST = {
        rocket = true,
        effect = true,
        water = true,
        handle = true,
        reflector = true,
    },

    --Blast radius of the rocket.
    BLAST_RADIUS = 7,

    --Force of rocket launcher blast.
    FORCE_GRANULARITY = 2,
    BLAST_PRESSURE = 750000,

    --Time before the rocket disappears after launching.
    ROCKET_DECAY_TIME = 30,

    --Maximum and minimum damage of the rocket on characters.
    MAX_DAMAGE = 80,
    MIN_DAMAGE = 42,
}