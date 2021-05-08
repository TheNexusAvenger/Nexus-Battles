--[[
TheNexusAvenger

Displays a coin from world space (such as being picked up).
--]]

local Players = game:GetService("Players")

local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local DisplayWorldSpaceCoin = PlayerScripts:WaitForChild("CoinWallet"):WaitForChild("DisplayWorldSpaceCoin")

return function(WorldPosition)
    DisplayWorldSpaceCoin:Fire(WorldPosition)
end