--[[
TheNexusAvenger

Updates the displayed coins for the player.
--]]

local Players = game:GetService("Players")

local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local DisplayCoinsUpdate = PlayerScripts:WaitForChild("CoinWallet"):WaitForChild("DisplayCoinsUpdate")

return function()
    DisplayCoinsUpdate:Fire()
end