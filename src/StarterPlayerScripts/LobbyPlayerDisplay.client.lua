--[[
TheNexusAvenger

Displays all the players in the game in the lobby.
--]]

local PLAYER_ENTRIES_PER_DISPLAY = 4



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Lobby = Workspace:WaitForChild("Lobby")
local PlayerScreens = Lobby:WaitForChild("PlayerScreens"):GetChildren()
table.sort(PlayerScreens,function(a,b) return a.Name < b.Name end)
local RankIcon = ReplicatedStorageProject:GetResource("UI.Icon.RankIcon")

local PlayersToDisplay = {}



--[[
Handles a player being added.
--]]
local function PlayerAdded(Player)
    --Get the stats.
    local PlayerStats = Player:WaitForChild("PersistentStats")
    local TotalKnockoutsValue = PlayerStats:WaitForChild("TotalKOs")
    local TimesMVPValue = PlayerStats:WaitForChild("TimesMVP")
    if not Player.Parent then return end

    --Create and add the player data.
    local PlayerData = {
        Player = Player,
        Knockouts = TotalKnockoutsValue.Value,
        MVPs = TimesMVPValue.Value,
    }
    table.insert(PlayersToDisplay,PlayerData)

    --Sort the players by name.
    table.sort(PlayersToDisplay,function(a,b)
        return string.lower(a.Player.Name) < string.lower(b.Player.Name)
    end)

    --Connect updating the stats.
    TotalKnockoutsValue:GetPropertyChangedSignal("Value"):Connect(function()
        PlayerData.Knockouts = TotalKnockoutsValue.Value
    end)
    TimesMVPValue:GetPropertyChangedSignal("Value"):Connect(function()
        PlayerData.MVPs = TimesMVPValue.Value
    end)
end

--[[
Handles a player being removed.
--]]
local function PlayerRemoved(Player)
    --Get the index to remove.
    local IndexToRemove
    for i,PlayerData in pairs(PlayersToDisplay) do
        if PlayerData.Player == Player then
            IndexToRemove = i
            break
        end
    end

    --Remove the index.
    if IndexToRemove then
        table.remove(PlayersToDisplay,IndexToRemove)
    end
end



--Connect the players.
Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoved)
for _,Player in pairs(Players:GetPlayers()) do
    coroutine.wrap(function()
        PlayerAdded(Player)
    end)()
end

--Create the displays.
for i,Screen in pairs(PlayerScreens) do
    --Create the container.
    local PlayerDisplaySurfaceGui = Instance.new("SurfaceGui")
    PlayerDisplaySurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    PlayerDisplaySurfaceGui.PixelsPerStud = 25
    PlayerDisplaySurfaceGui.ResetOnSpawn = false
    PlayerDisplaySurfaceGui.Name = "PlayersDisplay"
    PlayerDisplaySurfaceGui.Adornee = Screen:WaitForChild("Screen")
    PlayerDisplaySurfaceGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local PlayersContainer = Instance.new("Frame")
    PlayersContainer.BackgroundTransparency = 1
    PlayersContainer.Size = UDim2.new(1,0,1,0)
    PlayersContainer.ClipsDescendants = true
    PlayersContainer.Parent = PlayerDisplaySurfaceGui

    --Create the player entries.
    local PlayerEntries = {}
    for _ = 1,PLAYER_ENTRIES_PER_DISPLAY + 1 do
        local PlayerContainer = Instance.new("Frame")
        PlayerContainer.BackgroundTransparency = 1
        PlayerContainer.Size = UDim2.new(1/PLAYER_ENTRIES_PER_DISPLAY,0,1,0)
        PlayerContainer.ClipsDescendants = true
        PlayerContainer.Parent = PlayersContainer

        local PlayerImage = Instance.new("ImageLabel")
        PlayerImage.BackgroundTransparency = 1
        PlayerImage.Position = UDim2.new(0.025,0,0.025,0)
        PlayerImage.Size = UDim2.new(0.95,0,0.95,0)
        PlayerImage.SizeConstraint = Enum.SizeConstraint.RelativeXX
        PlayerImage.Parent = PlayerContainer

        local PlayerImageCorner = Instance.new("UICorner")
        PlayerImageCorner.CornerRadius = UDim.new(0.2,0)
        PlayerImageCorner.Parent = PlayerImage

        local RankImage = Instance.new("ImageLabel")
        RankImage.BackgroundTransparency = 1
        RankImage.Position = UDim2.new(0.475,0,0.475,0)
        RankImage.Size = UDim2.new(0.5,0,0.5,0)
        RankImage.Parent = PlayerImage
        local PlayerRankIcon = RankIcon.new(RankImage)

        local PlayerNameText = Instance.new("TextLabel")
        PlayerNameText.BackgroundTransparency = 1
        PlayerNameText.Size = UDim2.new(0.95,0,0.075,0)
        PlayerNameText.Position = UDim2.new(0.025,0,0.675,0)
        PlayerNameText.Font = Enum.Font.SourceSansBold
        PlayerNameText.TextScaled = true
        PlayerNameText.TextColor3 = Color3.new(0,0,0)
        PlayerNameText.TextStrokeColor3 = Color3.new(1,1,1)
        PlayerNameText.TextStrokeTransparency = 0
        PlayerNameText.Parent = PlayerContainer

        local KnockoutsText = Instance.new("TextLabel")
        KnockoutsText.BackgroundTransparency = 1
        KnockoutsText.Size = UDim2.new(0.4,0,0.15,0)
        KnockoutsText.Position = UDim2.new(0.075,0,0.75,0)
        KnockoutsText.Font = Enum.Font.SourceSansBold
        KnockoutsText.TextScaled = true
        KnockoutsText.TextColor3 = Color3.new(0,0,0)
        KnockoutsText.TextStrokeColor3 = Color3.new(1,1,1)
        KnockoutsText.TextStrokeTransparency = 0
        KnockoutsText.Parent = PlayerContainer

        local KnockoutsTitleText = Instance.new("TextLabel")
        KnockoutsTitleText.BackgroundTransparency = 1
        KnockoutsTitleText.Size = UDim2.new(0.4,0,0.075,0)
        KnockoutsTitleText.Position = UDim2.new(0.075,0,0.875,0)
        KnockoutsTitleText.Font = Enum.Font.SourceSansBold
        KnockoutsTitleText.TextScaled = true
        KnockoutsTitleText.TextColor3 = Color3.new(0,0,0)
        KnockoutsTitleText.TextStrokeColor3 = Color3.new(1,1,1)
        KnockoutsTitleText.TextStrokeTransparency = 0
        KnockoutsTitleText.Text = "Knockouts"
        KnockoutsTitleText.Parent = PlayerContainer

        local MVPsText = Instance.new("TextLabel")
        MVPsText.BackgroundTransparency = 1
        MVPsText.Size = UDim2.new(0.4,0,0.15,0)
        MVPsText.Position = UDim2.new(0.525,0,0.75,0)
        MVPsText.Font = Enum.Font.SourceSansBold
        MVPsText.TextScaled = true
        MVPsText.TextColor3 = Color3.new(0,0,0)
        MVPsText.TextStrokeColor3 = Color3.new(1,1,1)
        MVPsText.TextStrokeTransparency = 0
        MVPsText.Parent = PlayerContainer

        local MVPsTitleText = Instance.new("TextLabel")
        MVPsTitleText.BackgroundTransparency = 1
        MVPsTitleText.Size = UDim2.new(0.4,0,0.075,0)
        MVPsTitleText.Position = UDim2.new(0.525,0,0.875,0)
        MVPsTitleText.Font = Enum.Font.SourceSansBold
        MVPsTitleText.TextScaled = true
        MVPsTitleText.TextColor3 = Color3.new(0,0,0)
        MVPsTitleText.TextStrokeColor3 = Color3.new(1,1,1)
        MVPsTitleText.TextStrokeTransparency = 0
        MVPsTitleText.Text = "MVPs"
        MVPsTitleText.Parent = PlayerContainer

        table.insert(PlayerEntries,{
            Container = PlayerContainer,
            PlayerImage = PlayerImage,
            PlayerRankIcon = PlayerRankIcon,
            PlayerNameText = PlayerNameText,
            KnockoutsText = KnockoutsText,
            MVPsText = MVPsText,
        })
    end

    --Update the displays continously.
    local ListOffset = (i - 1) * PLAYER_ENTRIES_PER_DISPLAY
    local MaxPlayers = PLAYER_ENTRIES_PER_DISPLAY * #PlayerScreens
    RunService.Stepped:Connect(function()
        --Hide the display if the lobby is not in Workspace.
        if Lobby.Parent ~= Workspace then
            PlayerDisplaySurfaceGui.Enabled = false
            return
        end
        PlayerDisplaySurfaceGui.Enabled = true

        --Determine the offset of the list.
        local TimeOffset = tick() % 1
        local StartIndex = math.ceil(tick() % #PlayersToDisplay)
        if #PlayersToDisplay <= MaxPlayers then
            TimeOffset = 0
            StartIndex = 0
        end

        --Update the entries.
        for i,PlayerEntry in pairs(PlayerEntries) do
            --Get the player.
            local StatIndex = StartIndex + ListOffset + i
            if #PlayersToDisplay >= MaxPlayers then
                while StatIndex > #PlayersToDisplay do
                    StatIndex = StatIndex - #PlayersToDisplay
                end
            end
            local PlayerData = PlayersToDisplay[StatIndex]

            --Update the display.
            PlayerEntry.Container.Position = UDim2.new((i - 1 - TimeOffset)/PLAYER_ENTRIES_PER_DISPLAY,0,0,0)
            if PlayerData then
                PlayerEntry.Container.Visible = true
                PlayerEntry.PlayerImage.Image = "rbxthumb://type=AvatarHeadShot&id="..tostring(PlayerData.Player.UserId).."&w=420&h=420"
                PlayerEntry.PlayerRankIcon.Player = PlayerData.Player
                PlayerEntry.PlayerNameText.Text = PlayerData.Player.DisplayName
                PlayerEntry.KnockoutsText.Text = tostring(PlayerData.Knockouts)
                PlayerEntry.MVPsText.Text = tostring(PlayerData.MVPs)
            else
                PlayerEntry.Container.Visible = false
                PlayerEntry.PlayerRankIcon.Player = nil
            end
        end
    end)
end