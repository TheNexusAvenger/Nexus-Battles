--[[
TheNexusAvenger

Controls the UI for the timer and round loading.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local FlashScreen = ReplicatedStorageProject:GetResource("UI.FlashScreen")
local TextTimer = ReplicatedStorageProject:GetResource("UI.TextTimer")
local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local GameTypes = ReplicatedStorageProject:GetResource("Data.GameTypes")



--Connect creating the uesr interface.
CurrentRoundState:ConnectTo("CurrentRound",{
    Start = function(self,CurrentRound)
        --Create the user interface.
        local RoundGui = Instance.new("ScreenGui")
        RoundGui.Name = "RoundGui"
        RoundGui.ResetOnSpawn = false
        RoundGui.DisplayOrder = 5
        RoundGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        self.CurrentRoundGui = RoundGui

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
            if CurrentRound.Players:Contains(Players.LocalPlayer) then
                Players.LocalPlayer.CharacterAdded:Wait()
                local Character = Players.LocalPlayer.Character
                if Character then
                    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                    if Humanoid then
                        Camera.CameraSubject = Humanoid
                    end
                end
            else
                while CurrentRound.State == "LOADING" do
                    CurrentRound:GetPropertyChangedSignal("State"):Wait()
                end
            end
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

        --Set up the round timer.
        local TimerTextChangedEvent = CurrentRound:GetPropertyChangedSignal("TimerText"):Connect(function()
            TimerMessageText.Text = CurrentRound.TimerText
        end)
        TimerMessageText.Text = CurrentRound.TimerText
        local RoundTimer = TextTimer.new(TimerTimeText,CurrentRound.Timer)
        self.CurrentRoundTimer = RoundTimer

        --Wait for the round to end.
        while CurrentRoundState.CurrentRound == CurrentRound and CurrentRound.State ~= "ENDED" do
            CurrentRound:GetPropertyChangedSignal("State"):Wait()
        end
        TimerTextChangedEvent:Disconnect()
        RoundTimer:Destroy()

        --Display the round end.
        if self:IsActive() then
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

            --Reset the camera.
            Camera.CameraType = Enum.CameraType.Custom
            local Character = Players.LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Camera.CameraSubject = Humanoid
                end
            end

            --Destroy the user interface.
            Blur:Destroy()
            self:Clear()
        end
    end,
    Clear = function(self)
        if self.CurrentRoundGui then
            self.CurrentRoundGui:Destroy()
            self.CurrentRoundGui = nil
        end
        if self.CurrentRoundTimer then
            self.CurrentRoundTimer:Destroy()
            self.CurrentRoundTimer = nil
        end
    end,
})



--Connect flashing the client on character spawning, except the first spawn.
if not Players.LocalPlayer.Character then
    Players.LocalPlayer.CharacterAdded:Wait()
end
Players.LocalPlayer.CharacterAdded:Connect(FlashScreen)