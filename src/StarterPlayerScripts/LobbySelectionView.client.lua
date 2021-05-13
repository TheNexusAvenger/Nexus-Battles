--[[
TheNexusAvenger

Displays information about the current round
the player is selecting in the lobby.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local LobbySelectionRounds = NexusRoundSystem:GetObjectReplicator():GetGlobalContainer():WaitForChildBy("Name","LobbySelectionRounds")
local SetReady = ReplicatedStorageProject:GetResource("Replication.Lobby.SetReady")
local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local GreenTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))



--[[
Displays the information about the
lobby selection.
--]]
local function ShowLobbyInformation(Round)
    --Create the round information container.
    local RoundInformation = Instance.new("ScreenGui")
    RoundInformation.ResetOnSpawn = false
    RoundInformation.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local RoundTypeNameText = Instance.new("TextLabel")
    RoundTypeNameText.BackgroundTransparency = 1
    RoundTypeNameText.Size = UDim2.new(1,0,0.075,0)
    RoundTypeNameText.Position = UDim2.new(0,0,1,0)
    RoundTypeNameText.Font = "SourceSansBold"
    RoundTypeNameText.TextColor3 = Color3.new(0,0,0)
    RoundTypeNameText.TextStrokeColor3 = Color3.new(1,1,1)
    RoundTypeNameText.TextStrokeTransparency = 0
    RoundTypeNameText.TextScaled = true
    RoundTypeNameText.Parent = RoundInformation

    local RequiredPlayersText = Instance.new("TextLabel")
    RequiredPlayersText.BackgroundTransparency = 1
    RequiredPlayersText.Size = UDim2.new(1,0,0.05,0)
    RequiredPlayersText.Position = UDim2.new(0,0,1,0)
    RequiredPlayersText.Font = "SourceSansBold"
    RequiredPlayersText.TextColor3 = Color3.new(0,0,0)
    RequiredPlayersText.TextStrokeColor3 = Color3.new(1,1,1)
    RequiredPlayersText.TextStrokeTransparency = 0
    RequiredPlayersText.TextScaled = true
    RequiredPlayersText.Parent = RoundInformation

    local ReadyPlayersText = Instance.new("TextLabel")
    ReadyPlayersText.BackgroundTransparency = 1
    ReadyPlayersText.Size = UDim2.new(1,0,0.04,0)
    ReadyPlayersText.Position = UDim2.new(0,0,1,0)
    ReadyPlayersText.Font = "SourceSansBold"
    ReadyPlayersText.TextColor3 = Color3.new(0,0,0)
    ReadyPlayersText.TextStrokeColor3 = Color3.new(1,1,1)
    ReadyPlayersText.TextStrokeTransparency = 0
    ReadyPlayersText.TextScaled = true
    ReadyPlayersText.Visible = false
    ReadyPlayersText.Parent = RoundInformation

    --Create the ready button.
    local ReadyButton,ReadyText = GreenTextButtonFactory:Create()
    ReadyButton.Size = UDim2.new(0.3,0,0.06,0)
    ReadyButton.Position = UDim2.new(0.5,0,1,0)
    ReadyButton.AnchorPoint = Vector2.new(0.5,0)
    ReadyButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    ReadyButton:SetControllerIcon(Enum.KeyCode.ButtonX)
    ReadyButton:MapKey(Enum.KeyCode.ButtonX,Enum.UserInputType.MouseButton1)
    ReadyButton.Parent = RoundInformation
    ReadyText.Text = "READY"

    --[[
    Clears the events.
    --]]
    local Events = {}
    local function DisconnectEvents()
        for _,Connection in pairs(Events) do
            Connection:Disconnect()
        end
        Events = {}
    end

    --[[
    Updates the text.
    --]]
    local RequiredPlayersMet = false
    local function UpdateText()
        local CurrentPlayers,RequiedPlayers,MaxPlayers = #Round.Players:GetAll(),Round.RequiredPlayers,Round.MaxPlayers
        RequiredPlayersMet = (CurrentPlayers >= RequiedPlayers)
        RoundTypeNameText.Text = string.upper(Round.RoundName)
        if CurrentPlayers >= RequiedPlayers then
            RequiredPlayersText.Text = tostring(CurrentPlayers).."/"..tostring(MaxPlayers).." Players"
        else
            RequiredPlayersText.Text = tostring(RequiedPlayers).." Players Required"
        end
        ReadyPlayersText.Text = tostring(#Round.ReadyPlayers:GetAll()).."/"..tostring(CurrentPlayers).." Ready"
        ReadyPlayersText.Visible = (Round.ReadyPlayers:Contains(Players.LocalPlayer))
    end

    --Connect leaving the round.
    table.insert(Events,Round.Players.ItemRemoved:Connect(function(Player)
        if Player == Players.LocalPlayer then
            DisconnectEvents()
            if Player == Players.LocalPlayer then
                RoundTypeNameText:TweenPosition(UDim2.new(0,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.7,true,function()
                    RoundInformation:Destroy()
                end)
                RequiredPlayersText:TweenPosition(UDim2.new(0,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.6,true,function()
                    RequiredPlayersText:Destroy()
                end)
                ReadyPlayersText:TweenPosition(UDim2.new(0,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true,function()
                    ReadyPlayersText:Destroy()
                end)
                if ReadyButton.AdornFrame.Parent then
                    ReadyButton.AdornFrame:TweenPosition(UDim2.new(0.5,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true,function()
                        ReadyButton:Destroy()
                    end)
                end
            end
        end
    end))

    --Connect the round starting.
    table.insert(Events,CurrentRoundState.CurrentRoundChanged:Connect(function()
        DisconnectEvents()
        RoundInformation:Destroy()
        ReadyButton:Destroy()
    end))

    --Connect being ready.
    table.insert(Events,ReadyButton.MouseButton1Down:Connect(function()
        SetReady:FireServer()
        ReadyButton.AdornFrame:TweenPosition(UDim2.new(0.5,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Back,0.5,true,function()
            ReadyButton:Destroy()
        end)
    end))

    --Connect updating the text.
    table.insert(Events,Round.Players.ItemAdded:Connect(UpdateText))
    table.insert(Events,Round.Players.ItemRemoved:Connect(UpdateText))
    table.insert(Events,Round.ReadyPlayers.ItemAdded:Connect(UpdateText))
    table.insert(Events,Round.ReadyPlayers.ItemRemoved:Connect(UpdateText))
    table.insert(Events,RunService.RenderStepped:Connect(function()
        local WhiteFactor = (RequiredPlayersMet and 1 or (math.sin((tick() * 2) % (2 * math.pi))/2) + 0.5)
        RequiredPlayersText.TextStrokeColor3 = Color3.new(1,WhiteFactor,WhiteFactor)
    end))
    UpdateText()

    --Show the text.
    RoundTypeNameText:TweenPosition(UDim2.new(0,0,0.6,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.5)
    RequiredPlayersText:TweenPosition(UDim2.new(0,0,0.66,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.55)
    ReadyPlayersText:TweenPosition(UDim2.new(0,0,0.72,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.6)
    ReadyButton.AdornFrame:TweenPosition(UDim2.new(0.5,0,0.71,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.6)
end

--[[
Connects a new lobby round.
--]]
local function ConnectLobbyRound(Round)
    Round.Players.ItemAdded:Connect(function(Player)
        if Player == Players.LocalPlayer then
            ShowLobbyInformation(Round)
        end
    end)
end



--Connect the lobby rounds.
LobbySelectionRounds.ChildAdded:Connect(ConnectLobbyRound)
for _,Round in pairs(LobbySelectionRounds:GetChildren()) do
    ConnectLobbyRound(Round)
end