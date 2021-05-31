--[[
TheNexusAvenger

Updates the displayed coins for the player without
animating a coin from the center of the screen.
--]]

local Players = game:GetService("Players")

local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local UpdateCoins = PlayerScripts:WaitForChild("CoinWallet"):WaitForChild("UpdateCoins")

return function(AddedCoins)
    UpdateCoins:Fire(AddedCoins)
end