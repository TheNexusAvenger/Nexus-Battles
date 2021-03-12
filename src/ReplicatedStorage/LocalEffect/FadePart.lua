--[[
TheNexusAvenger

Fades parts on The Shard.
--]]

local TweenService = game:GetService("TweenService")

return function (Part,Time)
    Time = Time or 3
    if Part then
        Part.CanCollide = false
        TweenService:Create(Part,TweenInfo.new(Time),{
            Transparency = 1
        }):Play()
    end
end