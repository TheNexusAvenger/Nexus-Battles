--[[
TheNexusAvenger

Sets up the secret room.
--]]

local Workspace = game:GetService("Workspace")

local Lobby = Workspace:WaitForChild("Lobby")
local SecretRoom = Lobby:WaitForChild("SecretRoom")
local DavidBazooka = SecretRoom:WaitForChild("DavidBazooka"):WaitForChild("Dancing")

local Humanoids = {
    DavidBazooka:WaitForChild("DancingAnimator"):WaitForChild("Humanoid"),
    DavidBazooka:WaitForChild("DancingAnimator2"):WaitForChild("Humanoid"),
}



--Hide the board.
Lobby:WaitForChild("Leaderboards"):WaitForChild("TotalCoins").Transparency = 1

--Set up the animations.
for _,Humanoid in pairs(Humanoids) do
    local Animation = Instance.new("Animation")
    Animation.AnimationId = "rbxassetid://182435998"
    Humanoid:LoadAnimation(Animation):Play()
end
