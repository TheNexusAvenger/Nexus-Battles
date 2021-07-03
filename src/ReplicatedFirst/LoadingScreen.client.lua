--[[
TheNexusAvenger

Loads assets at the beginning of the game.
--]]

local TWEEN_TO_CHARACTER_TIME = 2
local LOBBY_CAMEAR_CFRAME = CFrame.new(71.336792, 224.332581, 34.2545738, 0.599687099, -0.16191265, 0.783683419, 7.45058149e-09, 0.979317129, 0.202331454, -0.800234675, -0.121335559, 0.58728379)

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")



--Create the initial user interface.
local LoadingCompleteValue = Instance.new("BoolValue")
LoadingCompleteValue.Name = "LoadingComplete"
LoadingCompleteValue.Value = false
LoadingCompleteValue.Parent = Players.LocalPlayer

local LoadingScreenCompleteValue = Instance.new("BoolValue")
LoadingScreenCompleteValue.Name = "LoadingScreenComplete"
LoadingScreenCompleteValue.Value = false
LoadingScreenCompleteValue.Parent = Players.LocalPlayer

local LoadingScreenContainer = Instance.new("ScreenGui")
LoadingScreenContainer.Name = "LoadingScreen"
LoadingScreenContainer.ResetOnSpawn = false
LoadingScreenContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local LoadingLogoContainer = Instance.new("Frame")
LoadingLogoContainer.BackgroundTransparency = 1
LoadingLogoContainer.AnchorPoint = Vector2.new(0.5,0.5)
LoadingLogoContainer.Position = UDim2.new(0.5,0,0.5,0)
LoadingLogoContainer.Size = UDim2.new(0.9,0,0.9,0)
LoadingLogoContainer.Parent = LoadingScreenContainer

local LoadingBarContainer = Instance.new("Frame")
LoadingBarContainer.BackgroundTransparency = 1
LoadingBarContainer.Size = UDim2.new(0,0,1,0)
LoadingBarContainer.ClipsDescendants = true
LoadingBarContainer.Parent = LoadingLogoContainer

local LogoBack = Instance.new("ImageLabel")
LogoBack.BackgroundTransparency = 1
LogoBack.Size = UDim2.new(1,0,1,0)
LogoBack.SizeConstraint = Enum.SizeConstraint.RelativeYY
LogoBack.Image = "rbxassetid://6892136800"
LogoBack.Parent = LoadingBarContainer

local LogoFront = Instance.new("ImageLabel")
LogoFront.BackgroundTransparency = 1
LogoFront.Size = UDim2.new(1,0,1,0)
LogoFront.Image = "rbxassetid://6892136377"
LogoFront.ZIndex = 5
LogoFront.Parent = LoadingLogoContainer
ReplicatedFirst:RemoveDefaultLoadingScreen()

local LoadingBlur = Instance.new("BlurEffect")
LoadingBlur.Parent = Lighting

local SkipButton,SkipText

--Lock the camera.
local Camera = Workspace.CurrentCamera
local CameraLockEvent = Camera.Changed:Connect(function()
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = LOBBY_CAMEAR_CFRAME
    Camera.Focus = LOBBY_CAMEAR_CFRAME * CFrame.new(0,0,-1)
end)
Camera.CameraType = Enum.CameraType.Scriptable



--[[
Updates the size of the UI.
--]]
local function UpdateSize()
    if LoadingScreenContainer.AbsoluteSize.X > LoadingScreenContainer.AbsoluteSize.Y then
        LoadingLogoContainer.SizeConstraint = Enum.SizeConstraint.RelativeYY
    else
        LoadingLogoContainer.SizeConstraint = Enum.SizeConstraint.RelativeXX
    end
end



--Connect the size changing.
LoadingScreenContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
UpdateSize()

--Create the skip button.
local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local TextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))

SkipButton,SkipText = TextButtonFactory:Create()
SkipButton.Size = UDim2.new(0.3,0,0.06,0)
SkipButton.Position = UDim2.new(0.5,0,0.8,0)
SkipButton.AnchorPoint = Vector2.new(0.5,0)
SkipButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
SkipButton:SetControllerIcon(Enum.KeyCode.ButtonX)
SkipButton:MapKey(Enum.KeyCode.ButtonX,Enum.UserInputType.MouseButton1)
SkipButton.Parent = LoadingScreenContainer
SkipText.Text = "SKIP"

--Connect skipping the loading.
SkipButton.MouseButton1Down:Connect(function()
    LoadingCompleteValue.Value = true
    LoadingBarContainer:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,0.25,true)
end)

--Load the assets.
coroutine.wrap(function()
    local Assets = ReplicatedStorageProject:GetResource("Data.Assets")
    for i,Asset in pairs(Assets) do
        if LoadingCompleteValue.Value then break end
        ContentProvider:PreloadAsync({Asset})
        if LoadingCompleteValue.Value then break end
        LoadingBarContainer:TweenSize(UDim2.new(i/#Assets,0,1,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,0.1,true)
    end
    LoadingCompleteValue.Value = true
end)()

--Wait for the loading to complete.
while not LoadingCompleteValue.Value do
    LoadingCompleteValue:GetPropertyChangedSignal("Value"):Wait()
end

--Hide the skip button.
SkipButton.AdornFrame:TweenPosition(UDim2.new(0.5,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true,function()
    SkipButton:Destroy()
end)

--Wait for the data to load.
if not Players.LocalPlayer:FindFirstChild("DataLoadSuccessful") then
    local PendingDataText = Instance.new("TextLabel")
    PendingDataText.BackgroundTransparency = 1
    PendingDataText.Size = UDim2.new(1,0,0.06,0)
    PendingDataText.Position = UDim2.new(0,0,0.8,0)
    PendingDataText.Font = "SourceSansBold"
    PendingDataText.Text = "LOADING DATA"
    PendingDataText.TextColor3 = Color3.new(1,1,1)
    PendingDataText.TextStrokeColor3 = Color3.new(0,0,0)
    PendingDataText.TextStrokeTransparency = 0
    PendingDataText.TextScaled = true
    PendingDataText.Parent = LoadingScreenContainer

    Players.LocalPlayer:WaitForChild("DataLoadSuccessful")
end

--Unlock the camera.
CameraLockEvent:Disconnect()
CameraLockEvent = nil

--Hide the loading UI and tween the camera.
wait(0.5)
local Character = Players.LocalPlayer.Character
local HumanoidRootPart = nil
if Character then
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
end
coroutine.wrap(function()
    local StartTweenTime = tick()
    while tick() - StartTweenTime < TWEEN_TO_CHARACTER_TIME do
        --Determine the ratio to tween.
        local CurrentTime = (tick() - StartTweenTime)/TWEEN_TO_CHARACTER_TIME
        local LerpRatio = 1 - (((math.cos((CurrentTime/TWEEN_TO_CHARACTER_TIME) * (2 * math.pi)))/2) + 0.5)

        --Determine the target CFrame.
        local TargetCFrame = CFrame.new()
        if HumanoidRootPart then
            TargetCFrame = HumanoidRootPart.CFrame * CFrame.new(0,(HumanoidRootPart.Size.Y/2) + 0.5,0) * CFrame.Angles(math.rad(-15),0,0) * CFrame.new(0,0,12.5)
        end

        --Move the camera.
        local CurrentCFrame = LOBBY_CAMEAR_CFRAME:Lerp(TargetCFrame,LerpRatio)
        Camera.CFrame = CurrentCFrame
        Camera.Focus = HumanoidRootPart.CFrame

        --Wait until the next frame to update.
        RunService.RenderStepped:Wait()
    end
end)()
TweenService:Create(LogoFront,TweenInfo.new(TWEEN_TO_CHARACTER_TIME),{
    ImageTransparency = 1,
}):Play()
TweenService:Create(LogoBack,TweenInfo.new(TWEEN_TO_CHARACTER_TIME),{
    ImageTransparency = 1,
}):Play()
TweenService:Create(LoadingBlur,TweenInfo.new(TWEEN_TO_CHARACTER_TIME),{
    Size = 0,
}):Play()
wait(TWEEN_TO_CHARACTER_TIME)
LoadingScreenContainer:Destroy()
LoadingBlur:Destroy()
Camera.CameraType = Enum.CameraType.Custom

--Register the loading screen as completed.
LoadingScreenCompleteValue.Value = true