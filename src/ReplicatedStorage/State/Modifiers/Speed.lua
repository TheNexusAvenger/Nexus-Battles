--[[
TheNexusAvenger

Applies speed boosts to a player.
--]]

return function(Character,Value)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    Humanoid.WalkSpeed = 16 + Value
end