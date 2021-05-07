--[[
TheNexusAvenger

Wraps a TextLabel to show a timer.
--]]

local ZOOM_TIME_THRESHOLD = 30
local TICK_SOUND = "rbxassetid://156286438"



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local TextTimer = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
TextTimer:SetClassName("TextTimer")



--Create the timer tick sound.
local TickSound = Instance.new("Sound")
TickSound.SoundId = TICK_SOUND



--[[
Creates the text-based timer.
--]]
function TextTimer:__new(TextLabel,Timer)
    self:InitializeSuper()

    --Set up the timer.
    self.TextLabel = TextLabel
    self.Timer = Timer
    self.LastProcessedTime = 0
    self.TimerTextScale = Instance.new("UIScale")
    self.TimerTextScale.Parent = TextLabel

    --Connect the events.
    self.UpdateEvent = RunService.Stepped:Connect(function()
        self:UpdateText()
    end)
end

--[[
Updates the displayed text.
--]]
function TextTimer:UpdateText()
    --Get and format the remaining time.
    local RemainingTime = math.ceil(self.Timer:GetRemainingTime())
    self.TextLabel.Text = string.format("%d:%02d",math.floor(RemainingTime/60),RemainingTime % 60)

    --Zoom the time if it changes and is below the threshold.
    if RemainingTime ~= self.LastProcessedTime then
        self.LastProcessedTime = RemainingTime
        if RemainingTime <= ZOOM_TIME_THRESHOLD then
            SoundService:PlayLocalSound(TickSound)
            TweenService:Create(self.TimerTextScale,TweenInfo.new(0.25),{
                Scale = 1.5,
            }):Play()
            wait(0.25)
            TweenService:Create(self.TimerTextScale,TweenInfo.new(0.25),{
                Scale = 1,
            }):Play()
        end
    end
end

--[[
Destroys the text timer.
--]]
function TextTimer:Destroy()
    self.UpdateEvent:Disconnect()
    self.TimerTextScale:Destroy()
end



return TextTimer