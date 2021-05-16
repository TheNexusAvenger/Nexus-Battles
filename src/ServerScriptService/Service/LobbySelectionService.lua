--[[
TheNexusAvenger

Static class for managing the round selectors in the lobby.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local GameTypes = ReplicatedStorageProject:GetResource("Data.GameTypes")
local MapTypes = ReplicatedStorageProject:GetResource("Data.MapTypes")
local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local ObjectReplicator = NexusRoundSystem:GetObjectReplicator()
local RoundService = ServerScriptServiceProject:GetResource("Service.RoundService")

local LobbySelectionService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
LobbySelectionService:SetClassName("LobbySelectionService")
LobbySelectionService.RoundOptions = {}



--Set up the replicaiton.
local LobbyReplication = Instance.new("Folder")
LobbyReplication.Name = "Lobby"
LobbyReplication.Parent = ReplicatedStorageProject:GetResource("Replication")

local SetReady = Instance.new("RemoteEvent")
SetReady.Name = "SetReady"
SetReady.Parent = LobbyReplication

local StartSpectating = Instance.new("RemoteEvent")
StartSpectating.Name = "StartSpectating"
StartSpectating.Parent = LobbyReplication

local LobbySelectionRounds = ObjectReplicator:CreateObject("ReplicatedContainer")
LobbySelectionRounds.Name = "LobbySelectionRounds"
LobbySelectionRounds.Parent = ObjectReplicator:GetGlobalContainer()

--Load the round options.
for MapName,MapData in pairs(MapTypes) do
    for _ = 1,MapData.Weight or 1 do
        for _,GameName in pairs(MapData.GameTypes or {}) do
            local GameData = GameTypes[GameName]
            if not GameData then
                error("Game type doesn't exist: "..tostring(GameName))
            end
            for _ = 1,GameData.Weight or 1 do
                table.insert(LobbySelectionService.RoundOptions,{
                    Map = MapName,
                    Type = GameName,
                })
            end
        end
    end
end



--[[
Initializes a part in the lobby for starting rounds.
--]]
function LobbySelectionService:InitializePart(Part,RoundValidationFunction)
    --Create the round display.
    local DisplayGui = Instance.new("SurfaceGui")
    DisplayGui.Face = Enum.NormalId.Top
    DisplayGui.CanvasSize = Vector2.new(400,400)
    DisplayGui.LightInfluence = 1
    DisplayGui.Parent = Part

    local MapImage = Instance.new("ImageLabel")
    MapImage.BorderSizePixel = 0
    MapImage.Size = UDim2.new(1,0,1,0)
    MapImage.Parent = DisplayGui

    local RoundTypeText = Instance.new("TextLabel")
    RoundTypeText.BackgroundTransparency = 1
    RoundTypeText.Size = UDim2.new(0.9,0,0.15,0)
    RoundTypeText.Position = UDim2.new(0.05,0,0.8,0)
    RoundTypeText.Font = Enum.Font.SourceSansBold
    RoundTypeText.TextScaled = true
    RoundTypeText.TextColor3 = Color3.new(1,1,1)
    RoundTypeText.TextStrokeColor3 = Color3.new(0,0,0)
    RoundTypeText.TextStrokeTransparency = 0
    RoundTypeText.Parent = DisplayGui

    --Start creating rounds.
    while true do
        --Select a random round type.
        local SelectedRound = LobbySelectionService.RoundOptions[math.random(1,#LobbySelectionService.RoundOptions)]
        while RoundValidationFunction and not RoundValidationFunction(GameTypes[SelectedRound.Type],GameTypes[SelectedRound.Type]) do
            SelectedRound = LobbySelectionService.RoundOptions[math.random(1,#LobbySelectionService.RoundOptions)]
        end
        local MapType = MapTypes[SelectedRound.Map]
        local RoundType = GameTypes[SelectedRound.Type]

        --Set up te part for the current round.
        MapImage.Image = "rbxassetid://"..tostring(MapType.ImageId or 0)
        RoundTypeText.Text = RoundType.DisplayName or SelectedRound.Type

        --Start the round for selecting players.
        local LobbySelectionRound = ObjectReplicator:CreateObject("LobbySelectionRound")
        if RoundType.DisplayName then LobbySelectionRound.RoundName = RoundType.DisplayName end
        if RoundType.RequiredPlayers then LobbySelectionRound.RequiredPlayers = RoundType.RequiredPlayers end
        if RoundType.MaxPlayers then LobbySelectionRound.MaxPlayers = RoundType.MaxPlayers end
        LobbySelectionRound.SelectionPart = Part
        LobbySelectionRound.Parent = LobbySelectionRounds

        --Connect removing ready indicators.
        LobbySelectionRound.ReadyPlayers.ItemRemoved:Connect(function(Player)
            local Character = Player.Character
            if Character then
                local Head = Character:FindFirstChild("Head")
                if Head then
                    local ReadyIndicator = Head:FindFirstChild("ReadyIndicator")
                    if ReadyIndicator then
                        ReadyIndicator:Destroy()
                    end
                end
            end
        end)

        --Wait for the round to complete.
        while LobbySelectionRound.Timer.State ~= "COMPLETE" do
            LobbySelectionRound.Timer:GetPropertyChangedSignal("State"):Wait()
        end

        --Start the round.
        RoundService:StartRound(SelectedRound.Type,SelectedRound.Map,LobbySelectionRound.Players:GetAll())

        --Clear the lobby round and prepare to restart.
        wait(3)
        LobbySelectionRound:Destroy()
    end
end

--[[
Sets a player as ready.
--]]
function LobbySelectionService:SetPlayerReady(Player)
    --Set the player as ready in their selection round.
    for _,Round in pairs(LobbySelectionRounds:GetChildren()) do
        if Round.Players:Contains(Player) then
            --Add the ready indicator.
            local Character = Player.Character
            if Character then
                local Head = Character:FindFirstChild("Head")
                if Head then
                    local ReadyIndicator = Instance.new("BillboardGui")
                    ReadyIndicator.Name = "ReadyIndicator"
                    ReadyIndicator.LightInfluence = 0
                    ReadyIndicator.Size = UDim2.new(1,0,1,0)
                    ReadyIndicator.StudsOffset = Vector3.new(0,2,0)
                    ReadyIndicator.Parent = Head

                    local CheckmarkContainer = Instance.new("Frame")
                    CheckmarkContainer.BackgroundTransparency = 1
                    CheckmarkContainer.Size = UDim2.new(1,0,1,0)
                    CheckmarkContainer.Position = UDim2.new(-0.2,0,0,0)
                    CheckmarkContainer.Rotation = 45
                    CheckmarkContainer.Parent = ReadyIndicator

                    local CheckmarkBottom = Instance.new("Frame")
                    CheckmarkBottom.BorderSizePixel = 0
                    CheckmarkBottom.BackgroundColor3 = Color3.new(0,1,0)
                    CheckmarkBottom.Size = UDim2.new(0.6,0,0.2,0)
                    CheckmarkBottom.Position = UDim2.new(0.4,0,0.8,0)
                    CheckmarkBottom.Parent = CheckmarkContainer

                    local CheckmarkSide = Instance.new("Frame")
                    CheckmarkSide.BorderSizePixel = 0
                    CheckmarkSide.BackgroundColor3 = Color3.new(0,1,0)
                    CheckmarkSide.Size = UDim2.new(0.2,0,1,0)
                    CheckmarkSide.Position = UDim2.new(0.8,0,0,0)
                    CheckmarkSide.Parent = CheckmarkContainer
                end
            end

            --Set the player as ready.
            Round:SetPlayerReady(Player)
            break
        end
    end
end



--Connect the remote events.
SetReady.OnServerEvent:Connect(function(Player)
    LobbySelectionService:SetPlayerReady(Player)
end)

StartSpectating.OnServerEvent:Connect(function(Player,RoundId)
    RoundService:StartSpectating(Player,RoundId)
end)



return LobbySelectionService