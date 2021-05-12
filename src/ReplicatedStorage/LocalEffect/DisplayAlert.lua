--[[
TheNexusAvenger

Displays a message for the player.
--]]

local GUI_TWEEN_TARGET = UDim2.new(0.5,0,0.75,0)
local GUI_TWEEN_TIME = 0.5
local GUI_DISPLAY_TIME = 3



local Players = game:GetService("Players")

local CurrentAlert


local AlertContainer = Instance.new("ScreenGui")
AlertContainer.Name = "AlertGui"
AlertContainer.DisplayOrder = 20
AlertContainer.ResetOnSpawn = false
AlertContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")



return function(Message)
    --Remove the current alert.
    if CurrentAlert then
        CurrentAlert:Destroy()
    end

    --Create the label.
    local AlertLabel = Instance.new("TextLabel")
    AlertLabel.Name = "AlertLabel"
    AlertLabel.BackgroundTransparency = 1
    AlertLabel.Position = UDim2.new(0.5,0,1,0)
    AlertLabel.AnchorPoint = Vector2.new(0.5,0)
    AlertLabel.Size = UDim2.new(1,0,0.06,0)
    AlertLabel.Font = Enum.Font.SourceSansBold
    AlertLabel.TextScaled = true
    AlertLabel.Text = Message
    AlertLabel.TextStrokeColor3 = Color3.new(240/255,1,250/255)
    AlertLabel.TextStrokeTransparency = 0
    AlertLabel.Parent = AlertContainer
    CurrentAlert = AlertLabel

    --Tween the label in and out.
    AlertLabel:TweenPosition(GUI_TWEEN_TARGET,"Out","Back",GUI_TWEEN_TIME,true,function()
        if AlertLabel.Position == GUI_TWEEN_TARGET then
            wait(GUI_DISPLAY_TIME)
            if AlertLabel.Parent then
                AlertLabel:TweenPosition(UDim2.new(0.5,0,1,0),"In","Back",GUI_TWEEN_TIME)
            end
        end
    end)
end