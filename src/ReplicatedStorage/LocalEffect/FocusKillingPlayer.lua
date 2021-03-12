--[[
TheNexusAvenger

Focuses on a player when killed.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local FlashScreen = ReplicatedStorageProject:GetResource("UI.FlashScreen")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

return function (FocusPlayer)
    --Return if the round is inactive.
    wait(1)
    if not CurrentRoundState.CurrentRound or CurrentRoundState.CurrentRound.State == "ENDED" then
        return
    end

    --Return if the focus doesn't exist.
    if not FocusPlayer.Character then
        return
    end
    local FocusHumanoid = FocusPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not FocusHumanoid then
        return
    end
    local Head = FocusPlayer.Character:FindFirstChild("Head")
    if not Head then
        return
    end

    --Flash the screen and display the killing player.
    FlashScreen()
    local Camera = Workspace.CurrentCamera
    Camera.CameraSubject = FocusHumanoid

    local FocusCover = Instance.new("ScreenGui")
    FocusCover.Name = "FocusCover"
    FocusCover.ResetOnSpawn = false
    FocusCover.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local BlockTopFrame = Instance.new("Frame")
    BlockTopFrame.BackgroundColor3 = Color3.new(0,0,0)
    BlockTopFrame.BorderSizePixel = 0
    BlockTopFrame.Size = UDim2.new(1,0,0.4,0)
    BlockTopFrame.Position = UDim2.new(0,0,-0.3,0)
    BlockTopFrame.Visible = false
    BlockTopFrame.Parent = FocusCover

    local BlockBottomFrame = Instance.new("Frame")
    BlockBottomFrame.BackgroundColor3 = Color3.new(0,0,0)
    BlockBottomFrame.BorderSizePixel = 0
    BlockBottomFrame.Size = UDim2.new(1,0,0.4,0)
    BlockBottomFrame.Position = UDim2.new(0,0,0.9,0)
    BlockBottomFrame.Visible = false
    BlockBottomFrame.Parent = FocusCover

    local Blur = Instance.new("DepthOfFieldEffect")
    Blur.FarIntensity = 1
    Blur.NearIntensity = 1
    Blur.InFocusRadius = 0
    Blur.Parent = Lighting

    coroutine.wrap(function()
        while Blur.Parent do
            Blur.FocusDistance = (Head.Position - Camera.CFrame.Position).Magnitude
            wait()
        end
    end)()

    --Wait for a flash to be applied.
    --This happens after respawning or the round ending.
    while true do
        if PlayerGui.ChildAdded:Wait().Name == "Flash" then
            break
        end
    end

    --Clear the GUI.
    FocusCover:Destroy()
    Blur:Destroy()
end