--[[
TheNexusAvenger

Manages showing the spectatable rounds and
spectating them.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local ActiveRounds = NexusRoundSystem:GetObjectReplicator():GetGlobalContainer():WaitForChildBy("Name","ActiveRounds")
local MapTypes = ReplicatedStorageProject:GetResource("Data.MapTypes")
local GameTypes = ReplicatedStorageProject:GetResource("Data.GameTypes")
local StartSpectating = ReplicatedStorageProject:GetResource("Replication.Lobby.StartSpectating")
local GreenTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))



--Set up the spectate parts.
local RoundChangedEvents = {}
local SpectateGuis = {}
local SpectateParts = Workspace:WaitForChild("Lobby"):WaitForChild("SpectateParts"):GetChildren()
local SpectatePartsToRound = {}
local ClearCurrentSpectatatePrompt
table.sort(SpectateParts,function(a,b) return a.Name < b.Name end)

for _,SpectatePart in pairs(SpectateParts) do
    local DisplayGui = Instance.new("SurfaceGui")
    DisplayGui.Face = Enum.NormalId.Top
    DisplayGui.CanvasSize = Vector2.new(400,400)
    DisplayGui.LightInfluence = 1
    DisplayGui.Enabled = false
    DisplayGui.Parent = SpectatePart

    local MapImage = Instance.new("ImageLabel")
    MapImage.BorderSizePixel = 0
    MapImage.Size = UDim2.new(1,0,1,0)
    MapImage.Parent = DisplayGui

    local MapTypeText = Instance.new("TextLabel")
    MapTypeText.BackgroundTransparency = 1
    MapTypeText.Size = UDim2.new(0.9,0,0.075,0)
    MapTypeText.Position = UDim2.new(0.01,0,0.01,0)
    MapTypeText.Font = Enum.Font.SourceSansBold
    MapTypeText.TextScaled = true
    MapTypeText.TextColor3 = Color3.new(1,1,1)
    MapTypeText.TextStrokeColor3 = Color3.new(0,0,0)
    MapTypeText.TextStrokeTransparency = 0
    MapTypeText.TextXAlignment = Enum.TextXAlignment.Left
    MapTypeText.Parent = MapImage

    local RoundTypeText = Instance.new("TextLabel")
    RoundTypeText.BackgroundTransparency = 1
    RoundTypeText.Size = UDim2.new(0.9,0,0.15,0)
    RoundTypeText.Position = UDim2.new(0.05,0,0.725,0)
    RoundTypeText.Font = Enum.Font.SourceSansBold
    RoundTypeText.TextScaled = true
    RoundTypeText.TextColor3 = Color3.new(1,1,1)
    RoundTypeText.TextStrokeColor3 = Color3.new(0,0,0)
    RoundTypeText.TextStrokeTransparency = 0
    RoundTypeText.Parent = DisplayGui

    local PlayersText = Instance.new("TextLabel")
    PlayersText.BackgroundTransparency = 1
    PlayersText.Size = UDim2.new(0.9,0,0.1,0)
    PlayersText.Position = UDim2.new(0.05,0,0.85,0)
    PlayersText.Font = Enum.Font.SourceSansBold
    PlayersText.TextScaled = true
    PlayersText.TextColor3 = Color3.new(1,1,1)
    PlayersText.TextStrokeColor3 = Color3.new(0,0,0)
    PlayersText.TextStrokeTransparency = 0
    PlayersText.Parent = DisplayGui

    table.insert(SpectateGuis,{
        Part = SpectatePart,
        Container = DisplayGui,
        MapImage = MapImage,
        MapTypeText = MapTypeText,
        RoundTypeText = RoundTypeText,
        PlayersText = PlayersText,
    })
end



--[[
Returns the text for the given amount of players.
--]]
local function GetPlayersText(TotalPlayers)
    return tostring(TotalPlayers).." Player"..(TotalPlayers == 1 and "" or "s")
end

--[[
Updates the displayed rounds.
--]]
local function UpdateDisplayedRounds()
    --Get the non-ended rounds.
    local Rounds = {}
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.State ~= "ENDED" then
            table.insert(Rounds,Round)
        end
    end

    --Disconnect the existing events.
    for _,Event in pairs(RoundChangedEvents) do
        Event:Disconnect()
    end
    RoundChangedEvents = {}

    --Update the displays.
    for i,SpectateGui in pairs(SpectateGuis) do
        local Round = Rounds[i]
        SpectatePartsToRound[SpectateGui.Part] = Round
        if Round then
            --Set up the initial display.
            SpectateGui.Container.Enabled = true
            SpectateGui.MapImage.Image = "rbxassetid://"..tostring(MapTypes[Round.MapName].ImageId)
            SpectateGui.MapTypeText.Text = MapTypes[Round.MapName].DisplayName or Round.MapName
            SpectateGui.RoundTypeText.Text = tostring(GameTypes[Round.Name].DisplayName)
            SpectateGui.PlayersText.Text = GetPlayersText(#Round.Players:GetAll())

            --Connect the events.
            table.insert(RoundChangedEvents,Round:GetPropertyChangedSignal("State"):Connect(function()
                UpdateDisplayedRounds()
            end))
            table.insert(RoundChangedEvents,Round.Players.ItemAdded:Connect(function()
                SpectateGui.PlayersText.Text = GetPlayersText(#Round.Players:GetAll())
            end))
            table.insert(RoundChangedEvents,Round.Players.ItemRemoved:Connect(function()
                SpectateGui.PlayersText.Text = GetPlayersText(#Round.Players:GetAll())
            end))
        else
            SpectateGui.Container.Enabled = false
        end
    end
end

--[[
Updates the spectate prompt.
--]]
local function UpdateSpectatePrompt(Round)
    --Clear the last prompt.
    if ClearCurrentSpectatatePrompt then
        ClearCurrentSpectatatePrompt()
        ClearCurrentSpectatatePrompt = nil
    end

    --Return if there is no round.
    if not Round then
        return
    end

    --Create the prompt.
    local SpectateInformation = Instance.new("ScreenGui")
    SpectateInformation.Name = "SpectateInformation"
    SpectateInformation.ResetOnSpawn = false
    SpectateInformation.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local RoundTypeNameText = Instance.new("TextLabel")
    RoundTypeNameText.BackgroundTransparency = 1
    RoundTypeNameText.Size = UDim2.new(1,0,0.075,0)
    RoundTypeNameText.Position = UDim2.new(0,0,1,0)
    RoundTypeNameText.Font = "SourceSansBold"
    RoundTypeNameText.TextColor3 = Color3.new(0,0,0)
    RoundTypeNameText.TextStrokeColor3 = Color3.new(1,1,1)
    RoundTypeNameText.TextStrokeTransparency = 0
    RoundTypeNameText.TextScaled = true
    RoundTypeNameText.Parent = SpectateInformation

    local TotalPlayersText = Instance.new("TextLabel")
    TotalPlayersText.BackgroundTransparency = 1
    TotalPlayersText.Size = UDim2.new(1,0,0.05,0)
    TotalPlayersText.Position = UDim2.new(0,0,1,0)
    TotalPlayersText.Font = "SourceSansBold"
    TotalPlayersText.TextColor3 = Color3.new(0,0,0)
    TotalPlayersText.TextStrokeColor3 = Color3.new(1,1,1)
    TotalPlayersText.TextStrokeTransparency = 0
    TotalPlayersText.TextScaled = true
    TotalPlayersText.Parent = SpectateInformation

    local SpectateButton,SpectateText = GreenTextButtonFactory:Create()
    SpectateButton.Size = UDim2.new(0.3,0,0.06,0)
    SpectateButton.Position = UDim2.new(0.5,0,1,0)
    SpectateButton.AnchorPoint = Vector2.new(0.5,0)
    SpectateButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    SpectateButton:SetControllerIcon(Enum.KeyCode.ButtonX)
    SpectateButton:MapKey(Enum.KeyCode.ButtonX,Enum.UserInputType.MouseButton1)
    SpectateButton.Parent = SpectateInformation
    SpectateText.Text = "SPECTATE"

    --[[
    Updates the displayed text.
    --]]
    local function UpdateText()
        RoundTypeNameText.Text = (GameTypes[Round.Name] or {}).DisplayName or Round.Name
        TotalPlayersText.Text = GetPlayersText(#Round.Players:GetAll())
    end

    --Connect the events.
    local Events = {}
    table.insert(Events,Round:GetPropertyChangedSignal("Name"):Connect(UpdateText))
    table.insert(Events,Round.Players.ItemAdded:Connect(UpdateText))
    table.insert(Events,Round.Players.ItemRemoved:Connect(UpdateText))
    table.insert(Events,SpectateButton.MouseButton1Down:Connect(function()
        --Signal the server to start spectating.
        StartSpectating:FireServer(Round.Id)

        --Clear the events.
        for _,Event in pairs(Events) do
            Event:Disconnect()
        end

        --Clear the UI.
        SpectateInformation:Destroy()
        SpectateButton:Destroy()
    end))
    UpdateText()

    --[[
    Clears the prompt.
    Intended to be called externally (shouldn't be local).
    --]]
    function ClearCurrentSpectatatePrompt()
        --Clear the events.
        for _,Event in pairs(Events) do
            Event:Disconnect()
        end

        --Hide the UI.
        if SpectateInformation.Parent then 
            RoundTypeNameText:TweenPosition(UDim2.new(0,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.7,true,function()
                SpectateInformation:Destroy()
            end)
            TotalPlayersText:TweenPosition(UDim2.new(0,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.6,true,function()
                TotalPlayersText:Destroy()
            end)
            if SpectateButton.AdornFrame.Parent then
                SpectateButton.AdornFrame:TweenPosition(UDim2.new(0.5,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true,function()
                    SpectateButton:Destroy()
                end)
            end
        end
    end

    --Show the prompt.
    RoundTypeNameText:TweenPosition(UDim2.new(0,0,0.6,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.5)
    TotalPlayersText:TweenPosition(UDim2.new(0,0,0.66,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.55)
    SpectateButton.AdornFrame:TweenPosition(UDim2.new(0.5,0,0.71,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.6)
end



--Connect the rounds changing.
ActiveRounds.ChildAdded:Connect(UpdateDisplayedRounds)
ActiveRounds.ChildRemoved:Connect(UpdateDisplayedRounds)
UpdateDisplayedRounds()

--Update entering the spectate option.
local CurrentSpectateRound
while true do
    --Get the spectate part the player is standing on.
    local NewSpectatePart
    local Character = Players.LocalPlayer.Character
    if Character and Character.Parent then
        local Humanoid,HumanoidRootPart = Character:FindFirstChild("Humanoid"),Character:FindFirstChild("HumanoidRootPart")
        if Humanoid and Humanoid.Health > 0 and HumanoidRootPart then
            for _,SpectatePart in pairs(SpectateParts) do
                local RelativeCFrame = SpectatePart.CFrame:Inverse() * HumanoidRootPart.CFrame
                local Size2 = SpectatePart.Size/2
                if RelativeCFrame.X >= -Size2.X and RelativeCFrame.X <= Size2.X and RelativeCFrame.Z >= -Size2.Z and RelativeCFrame.Z <= Size2.Z and RelativeCFrame.Y >= 0 then
                    NewSpectatePart = SpectatePart
                    break
                end
            end
        end
    end

    --Update the spectate part.
    local NewSpectateRound = (NewSpectatePart and SpectatePartsToRound[NewSpectatePart])
    if NewSpectateRound ~= CurrentSpectateRound then
        CurrentSpectateRound = NewSpectateRound
        UpdateSpectatePrompt(NewSpectateRound)
    end
    wait()
end