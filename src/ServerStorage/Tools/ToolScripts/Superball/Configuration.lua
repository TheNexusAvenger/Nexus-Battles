--[[
TheNexusAvenger

Configuration of the superball.
--]]

return {
    --Reload time of the superball.
    SUPERBALL_RELOAD_TIME = 1.6,

    --Time between activating and launching superball.
    SUPERBALL_LAUCNH_DELAY = 0.1,

    --Launch speed of the superball.
    SUPERBALL_LAUCNH_VELOCITY = 170,

    --Decay time of the superball.
    SUPERBALL_DECAY_TIME = 5,

    --Starting and minimum damage of the superball.
    SUPERBALL_START_DAMAGE = 42,
    SUPERBALL_MIN_DAMAGE = 10,

    --Decay rate of the damage after bouncing.
    SUPERBALL_DAMAGE_DECAY_RATIO = 1/1.65,

    --Base volume of the superball.
    SUPERBALL_BOING_VOLUME = 2/3,
}