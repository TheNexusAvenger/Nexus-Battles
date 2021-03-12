--[[
TheNexusAvenger

Helper that flashes the screen for a transition.
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")



--[[
Flashes the screen.
This method does not delay.
--]]
return function()
    coroutine.wrap(function()
        --Create the frame.
        local FlashGui = Instance.new("ScreenGui")
        FlashGui.Name = "Flash"
        FlashGui.DisplayOrder = 100
        FlashGui.ResetOnSpawn = false
        FlashGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

        local FlashFrame = Instance.new("Frame")
        FlashFrame.BackgroundColor3 = Color3.new(1,1,1)
        FlashFrame.Size = UDim2.new(3,0,3,0)
        FlashFrame.Position = UDim2.new(-1,0,-1,0)
        FlashFrame.Parent = FlashGui

        --Flash the UI.
        TweenService:Create(FlashFrame,TweenInfo.new(0.2),{
            BackgroundTransparency = 1
        }):Play()
        wait(0.5)

        ---Clear the UI.
        FlashGui:Destroy()
    end)()
end