--[[
TheNexusAvenger

Displays a kill feed message.
--]]

local Players = game:GetService("Players")

local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local DisplayMessage = PlayerScripts:WaitForChild("KillFeed"):WaitForChild("DisplayMessage")

return function(KillFeedData)
    DisplayMessage:Fire(KillFeedData)
end