--[[
TheNexusAvenger

Controls spectating in rounds.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local LeaveRound = ReplicatedStorageProject:GetResource("Replication.Round.LeaveRound")
local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local ToggleTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,255/255))
local ContinueTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))
local FlashScreen = ReplicatedStorageProject:GetResource("UI.FlashScreen")



--[[
Invoked when the spectator round changes.
--]]
local function CurrentSpectatorRoundChanged(CurrentRound)
    --Return if there is no spectator round.
    if not CurrentRound or CurrentRound.State == "ENDED" then
        return
    end

    --Wait for the round to start.
    while CurrentRound.State == "LOADING" do
        CurrentRound:GetPropertyChangedSignal("State"):Wait()
    end
    if CurrentRoundState.CurrentSpectatingRound ~= CurrentRound then return end

    --Get the current spectating player, if any.
    --This allows for spectating the last killing player.
    local SpectateEvents = {}
    local UpdateCharacterEvent
    local CurrentSpectateId = 1
    local CurrentSpectatingCharacter,CurrentSpectatingPlayer
    local FocusedHumanoid = Workspace.CurrentCamera.CameraSubject
    if FocusedHumanoid then
        local FocusedCharacter = FocusedHumanoid.Parent
        if FocusedCharacter then
            local FocusedPlayer = Players:GetPlayerFromCharacter(FocusedCharacter)
            if FocusedPlayer then
                CurrentSpectateId = CurrentRound.Players:Find(FocusedPlayer) or 1
            end
        end
    end

    --Create the focus blur.
    local Camera = Workspace.CurrentCamera
    local Blur = Instance.new("DepthOfFieldEffect")
    Blur.FarIntensity = 1
    Blur.NearIntensity = 1
    Blur.InFocusRadius = 0
    Blur.Parent = Lighting
    table.insert(SpectateEvents,RunService.RenderStepped:Connect(function()
        Blur.FocusDistance = (Camera.Focus.Position - Camera.CFrame.Position).Magnitude
    end))

    --Create the spectate information.
    local SpectateContainer = Instance.new("ScreenGui")
    SpectateContainer.Name = "SpectateGui"
    SpectateContainer.ResetOnSpawn = false
    SpectateContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local CurrentPlayerText = Instance.new("TextLabel")
    CurrentPlayerText.BackgroundTransparency = 1
    CurrentPlayerText.AnchorPoint = Vector2.new(0.5,0)
    CurrentPlayerText.Position = UDim2.new(0.5,0,0.82,0)
    CurrentPlayerText.Size = UDim2.new(0.6,0,0.07,0)
    CurrentPlayerText.SizeConstraint = Enum.SizeConstraint.RelativeYY
    CurrentPlayerText.TextTruncate = Enum.TextTruncate.AtEnd
    CurrentPlayerText.Font = Enum.Font.SourceSansBold
    CurrentPlayerText.TextColor3 = Color3.new(0,0,0)
    CurrentPlayerText.TextStrokeColor3 = Color3.new(1,1,1)
    CurrentPlayerText.TextStrokeTransparency = 0
    CurrentPlayerText.Parent = SpectateContainer

    local SpectateLeftButton,SpectateLeftText = ToggleTextButtonFactory:Create()
    SpectateLeftButton.AnchorPoint = Vector2.new(1,0)
    SpectateLeftButton.Size = UDim2.new(1,0,1,0)
    SpectateLeftButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    SpectateLeftButton.Parent = CurrentPlayerText
    SpectateLeftButton:MapKey(Enum.KeyCode.Q,Enum.UserInputType.MouseButton1)
    SpectateLeftText.Text = "<"

    local SpectateRightButton,SpectateRightText = ToggleTextButtonFactory:Create()
    SpectateRightButton.Position = UDim2.new(1,0,0,0)
    SpectateRightButton.Size = UDim2.new(1,0,1,0)
    SpectateRightButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    SpectateRightButton.Parent = CurrentPlayerText
    SpectateRightButton:MapKey(Enum.KeyCode.E,Enum.UserInputType.MouseButton1)
    SpectateRightText.Text = ">"

    local ContinueButton,ContinueText = ContinueTextButtonFactory:Create()
    ContinueButton.Position = UDim2.new(0.5,0,1.05,0)
    ContinueButton.AnchorPoint = Vector2.new(0.5,0)
    ContinueButton.Size = UDim2.new(0.9 * (0.3 / 0.065),0,0.9,0)
    ContinueButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    ContinueButton.Parent = CurrentPlayerText
    ContinueText.Text = "EXIT"

    SpectateContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local ScreenSize = SpectateContainer.AbsoluteSize
        local RequiredWidth = 0.9 * ScreenSize.Y
        local SizeMultiplier = math.min(1,ScreenSize.X/RequiredWidth)
        CurrentPlayerText.Size = UDim2.new(0.6 * SizeMultiplier,0,0.07 * SizeMultiplier,0)
        CurrentPlayerText.TextSize = SpectateContainer.AbsoluteSize.Y * 0.07 * SizeMultiplier
    end)
    CurrentPlayerText.TextSize = SpectateContainer.AbsoluteSize.Y * 0.07

    --[[
    Closes the spectate mode.
    --]]
    local function CloseSpectate()
        --Disconnect the events.
        if UpdateCharacterEvent then
            UpdateCharacterEvent:Disconnect()
        end
        UpdateCharacterEvent = nil
        for _,Connection in pairs(SpectateEvents) do
            Connection:Disconnect()
        end
        SpectateEvents = {}

        --Destroy the blur and UI.
        Blur:Destroy()
        SpectateContainer:Destroy()
        SpectateLeftButton:Destroy()
        SpectateRightButton:Destroy()
        ContinueButton:Destroy()
    end

    --[[
    Updates the spectating character.
    --]]
    local function UpdateSpectatingCharacter()
        --Disconnect the previous event.
        if UpdateCharacterEvent then
            UpdateCharacterEvent:Disconnect()
            UpdateCharacterEvent = nil
        end

        --Update the visible buttons.
        local ToggleButtonsVisible = (#CurrentRound.Players:GetAll() > 1)
        SpectateLeftButton.Visible = ToggleButtonsVisible
        SpectateRightButton.Visible = ToggleButtonsVisible

        --Get the character and Humanoid.
        local CurrentPlayer = CurrentSpectatingPlayer
        if not CurrentPlayer then CurrentPlayerText.Text = "" return end
        while not CurrentPlayer.Character do
            CurrentPlayer.CharacterAdded:Wait()
        end
        local CurrentCharacter = CurrentPlayer.Character
        local Humanoid = CurrentCharacter:WaitForChild("Humanoid")
        if CurrentSpectatingPlayer ~= CurrentPlayer then return end

        --Connect the character changing.
        UpdateCharacterEvent = CurrentPlayer.CharacterAdded:Connect(UpdateSpectatingCharacter)
        if CurrentSpectatingCharacter == CurrentCharacter then return end

        --Focus the character.
        CurrentPlayerText.Text = CurrentPlayer.DisplayName
        FlashScreen()
        CurrentSpectatingCharacter = CurrentCharacter
        Camera.CameraSubject = Humanoid
    end

    --[[
    Updates the spectating player.
    --]]
    local function UpdateSpectatingPlayer(Increment)
        --Update the id.
        CurrentSpectateId = math.min(CurrentRound.Players:Find(CurrentSpectatingPlayer) or CurrentSpectateId,#CurrentRound.Players:GetAll())
        if Increment then
            CurrentSpectateId = CurrentSpectateId + Increment
            if CurrentSpectateId > #CurrentRound.Players:GetAll() then
                CurrentSpectateId = 1
            elseif CurrentSpectateId < 1 then
                CurrentSpectateId = #CurrentRound.Players:GetAll()
            end
        end
        CurrentSpectatingPlayer = CurrentRound.Players:Get(CurrentSpectateId)

        --Update the character.
        UpdateSpectatingCharacter()
    end

    --Connect updating the specating player.
    UpdateSpectatingPlayer()
    table.insert(SpectateEvents,CurrentRound.Players.ItemAdded:Connect(function()
        UpdateSpectatingPlayer()
    end))
    table.insert(SpectateEvents,CurrentRound.Players.ItemRemoved:Connect(function()
        UpdateSpectatingPlayer()
    end))
    table.insert(SpectateEvents,SpectateLeftButton.MouseButton1Down:Connect(function()
        UpdateSpectatingPlayer(-1)
    end))
    table.insert(SpectateEvents,SpectateRightButton.MouseButton1Down:Connect(function()
        UpdateSpectatingPlayer(1)
    end))

    --Connect closing spectating.
    table.insert(SpectateEvents,CurrentRound:GetPropertyChangedSignal("State"):Connect(function()
        if CurrentRound.State == "ENDED" then
            CloseSpectate()
        end
    end))
    table.insert(SpectateEvents,CurrentRoundState.CurrentSpectatingRoundChanged:Connect(function()
        if not CurrentRoundState.CurrentSpectatingRound then
            CloseSpectate()
        end
    end))
    table.insert(SpectateEvents,ContinueButton.MouseButton1Down:Connect(function()
        CloseSpectate()
        LeaveRound:FireServer()
    end))
end



--Connect the current round changing.
CurrentRoundState.CurrentSpectatingRoundChanged:Connect(CurrentSpectatorRoundChanged)
CurrentSpectatorRoundChanged(CurrentRoundState.CurrentSpectatingRound)