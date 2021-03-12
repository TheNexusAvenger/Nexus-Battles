--[[
TheNexusAvenger

Plays a sound for hitting a player.
--]]

local Players = game:GetService("Players")

return function ()
    local HitSound = Players.LocalPlayer:FindFirstChild("HitSound")
    if not HitSound then
        HitSound = Instance.new("Sound")
        HitSound.Name = "HitSound"
        HitSound.SoundId = "http://www.roblox.com/Asset?ID=95522378"
        HitSound.Volume = 1
        HitSound.Parent = Players.LocalPlayer
    end
    HitSound:Play()
end
