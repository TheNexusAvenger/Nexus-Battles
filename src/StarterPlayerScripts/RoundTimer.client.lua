--[[
TheNexusAvenger

Controls the UI for the timer and round loading.
--]]

local ZOOM_TIME_THRESHOLD = 30



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local FlashScreen = ReplicatedStorageProject:GetResource("UI.FlashScreen")
local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local GameTypes = ReplicatedStorageProject:GetResource("Data.GameTypes")



--Create the user interface.
local RoundGui = Instance.new("ScreenGui")
RoundGui.Name = "RoundGui"
RoundGui.ResetOnSpawn = false
RoundGui.DisplayOrder = 5
RoundGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local LoadingTopFrame = Instance.new("Frame")
LoadingTopFrame.BackgroundColor3 = Color3.new(0,0,0)
LoadingTopFrame.BorderSizePixel = 0
LoadingTopFrame.Size = UDim2.new(1,0,0.4,0)
LoadingTopFrame.Position = UDim2.new(0,0,-0.3,0)
LoadingTopFrame.Visible = false
LoadingTopFrame.Parent = RoundGui

local LoadingBottomFrame = Instance.new("Frame")
LoadingBottomFrame.BackgroundColor3 = Color3.new(0,0,0)
LoadingBottomFrame.BorderSizePixel = 0
LoadingBottomFrame.Size = UDim2.new(1,0,0.4,0)
LoadingBottomFrame.Position = UDim2.new(0,0,0.9,0)
LoadingBottomFrame.Visible = false
LoadingBottomFrame.Parent = RoundGui

local TimerMessageText = Instance.new("TextLabel")
TimerMessageText.BackgroundTransparency = 1
TimerMessageText.Size = UDim2.new(1,0,0.05,0)
TimerMessageText.Position = UDim2.new(0,0,0.02,0)
TimerMessageText.Font = "SourceSansBold"
TimerMessageText.TextColor3 = Color3.new(0,0,0)
TimerMessageText.TextStrokeColor3 = Color3.new(1,1,1)
TimerMessageText.TextStrokeTransparency = 0
TimerMessageText.TextScaled = true
TimerMessageText.Visible = false
TimerMessageText.Parent = RoundGui

local TimerTimeText = Instance.new("TextLabel")
TimerTimeText.BackgroundTransparency = 1
TimerTimeText.Size = UDim2.new(1,0,0.075,0)
TimerTimeText.Position = UDim2.new(0.5,0,0.06 + (0.075/2),0)
TimerTimeText.AnchorPoint = Vector2.new(0.5,0.5)
TimerTimeText.Font = "SourceSansBold"
TimerTimeText.TextColor3 = Color3.new(0,0,0)
TimerTimeText.TextStrokeColor3 = Color3.new(1,1,1)
TimerTimeText.TextStrokeTransparency = 0
TimerTimeText.TextScaled = true
TimerTimeText.Visible = false
TimerTimeText.Parent = RoundGui

local TimerTimeScale = Instance.new("UIScale")
TimerTimeScale.Parent = TimerTimeText

local GameTypeNameText = Instance.new("TextLabel")
GameTypeNameText.BackgroundTransparency = 1
GameTypeNameText.Size = UDim2.new(1,0,0.075,0)
GameTypeNameText.Position = UDim2.new(0,0,0.125,0)
GameTypeNameText.Font = "SourceSansBold"
GameTypeNameText.TextColor3 = Color3.new(0,0,0)
GameTypeNameText.TextStrokeColor3 = Color3.new(1,1,1)
GameTypeNameText.TextStrokeTransparency = 0
GameTypeNameText.TextScaled = true
GameTypeNameText.Visible = false
GameTypeNameText.Parent = RoundGui

local GameTypeDescriptionText = Instance.new("TextLabel")
GameTypeDescriptionText.BackgroundTransparency = 1
GameTypeDescriptionText.Size = UDim2.new(1,0,0.05,0)
GameTypeDescriptionText.Position = UDim2.new(0,0,0.18,0)
GameTypeDescriptionText.Font = "SourceSansBold"
GameTypeDescriptionText.TextColor3 = Color3.new(0,0,0)
GameTypeDescriptionText.TextStrokeColor3 = Color3.new(1,1,1)
GameTypeDescriptionText.TextStrokeTransparency = 0
GameTypeDescriptionText.TextScaled = true
GameTypeDescriptionText.Visible = false
GameTypeDescriptionText.Parent = RoundGui



--[[
Invoked when the round changes.
--]]
local function CurrentRoundChanged(CurrentRound)
    --Hide the user interface if there is no round.
    if not CurrentRound then
        LoadingTopFrame.Visible = false
        LoadingBottomFrame.Visible = false
        TimerMessageText.Visible = false
        TimerTimeText.Visible = false
        GameTypeNameText.Visible = false
        GameTypeDescriptionText.Visible = false
        return
    end

    --Display the loading information.
    if CurrentRound.State == "LOADING" then
        --Flash the screen and blur the screen.
        local Blur = Instance.new("DepthOfFieldEffect")
        Blur.FocusDistance = 50
        Blur.InFocusRadius = 10
        Blur.Parent = Lighting
        FlashScreen()

        --Set the camera.
        local LoadingCameraPositionPart = CurrentRound.Map:WaitForChild("LoadingCameraPosition")
        local Camera = Workspace.CurrentCamera
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = LoadingCameraPositionPart.CFrame
        Camera.Focus = LoadingCameraPositionPart.CFrame * CFrame.new(0,0,-1)

        --Display the information.
        local GameData = GameTypes[CurrentRound.Name]
        LoadingTopFrame.Visible = true
        LoadingBottomFrame.Visible = true
        TimerMessageText.Visible = false
        TimerTimeText.Visible = false
        GameTypeNameText.Visible = true
        GameTypeDescriptionText.Visible = true
        GameTypeNameText.Text = string.upper(GameData.DisplayName)
        GameTypeDescriptionText.Text = GameData.Description

        --Wait for the character to load.
        Players.LocalPlayer.CharacterAdded:Wait()
        Blur:Destroy()
        FlashScreen()
        Camera.CameraType = Enum.CameraType.Custom
    end

    --Update the visible components.
    LoadingTopFrame.Visible = false
    LoadingBottomFrame.Visible = false
    TimerMessageText.Visible = true
    TimerTimeText.Visible = true
    GameTypeNameText.Visible = false
    GameTypeDescriptionText.Visible = false

    --Update the time.
    local LastRemainingTime = 0
    while CurrentRoundState.CurrentRound == CurrentRound and CurrentRound.State ~= "ENDED" do
        --Update the time.
        local RemainingTime = math.ceil(CurrentRound.Timer:GetRemainingTime())
        TimerMessageText.Text = CurrentRound.TimerText
        TimerTimeText.Text = string.format("%d:%02d",math.floor(RemainingTime/60),RemainingTime % 60)

        --Zoom the time if it changes and is below the threshold.
        if RemainingTime ~= LastRemainingTime then
            LastRemainingTime = RemainingTime
            if RemainingTime <= ZOOM_TIME_THRESHOLD then
                TweenService:Create(TimerTimeScale,TweenInfo.new(0.25),{
                    Scale = 1.5,
                }):Play()
                wait(0.25)
                TweenService:Create(TimerTimeScale,TweenInfo.new(0.25),{
                    Scale = 1,
                }):Play()
            end
        end

        --Wait to update.
        wait()
    end

    --Display the round end.
    if CurrentRoundState.CurrentRound == CurrentRound then
        --Display the blur and the user interface.
        local Blur = Instance.new("DepthOfFieldEffect")
        Blur.FocusDistance = 50
        Blur.InFocusRadius = 10
        Blur.Parent = Lighting
        LoadingTopFrame.Visible = true
        LoadingBottomFrame.Visible = true
        TimerMessageText.Visible = false
        TimerTimeText.Visible = false
        FlashScreen()

        --Set the camera.
        local LoadingCameraPositionPart = CurrentRound.Map:WaitForChild("LoadingCameraPosition")
        local Camera = Workspace.CurrentCamera
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = LoadingCameraPositionPart.CFrame
        Camera.Focus = LoadingCameraPositionPart.CFrame * CFrame.new(0,0,-1)

        --Wait for the player to be done viewing the end.
        CurrentRoundState.CurrentRoundChanged:Wait()
        if not Players.LocalPlayer.Character then
            Players.LocalPlayer.CharacterAdded:Wait()
        end
        FlashScreen()

        --Hide the user interface.
        Blur:Destroy()
        Camera.CameraType = Enum.CameraType.Custom
        LoadingTopFrame.Visible = false
        LoadingBottomFrame.Visible = false
        TimerMessageText.Visible = false
        TimerTimeText.Visible = false
    end
end



--Connect the current round changing.
CurrentRoundState.CurrentRoundChanged:Connect(CurrentRoundChanged)
coroutine.wrap(function()
    CurrentRoundChanged(CurrentRoundState.CurrentRound)
end)()

--Connect flashing the client on character spawning, except the first spawn.
if not Players.LocalPlayer.Character then
    Players.LocalPlayer.CharacterAdded:Wait()
end
Players.LocalPlayer.CharacterAdded:Connect(FlashScreen)