--[[
TheNexusAvenger

Displays the global leaderboards in the lobby.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Leaderboards = Workspace:WaitForChild("Lobby"):WaitForChild("Leaderboards")
local UsernamesCache = {}
local Boards = {
    TotalKOs = Leaderboards:WaitForChild("TotalKOs"),
    TotalCoins = Leaderboards:WaitForChild("TotalCoins"),
    TimesMVP = Leaderboards:WaitForChild("TimesMVP"),
}
local StatNames = {
    TotalKOs = "Knockouts",
    TotalCoins = "Collected Coins",
    TimesMVP = "MVPs"
}



--[[
Returns the username for the given id.
--]]
local function GetUsername(Id)
    --Add the cache entry if it doesn't exist.
    if not UsernamesCache[Id] then
        local Player = Players:GetPlayerByUserId(Id)
        if Player then
            --Set the name to the player in the game.
            UsernamesCache[Id] = Player.DisplayName
        else
            --Load the player name from the API.
            UsernamesCache[Id] = "Loading..."
            coroutine.wrap(function()
                local Worked,Return = pcall(function()
                    UsernamesCache[Id] = Players:GetNameFromUserIdAsync(Id)
                end)
                if not Worked then
                    warn("Failed to get username for "..tostring(Id).." because "..tostring(Return))
                    UsernamesCache[Id] = "(ERROR)"
                end
            end)()
        end
    end

    --Return the cached entry.
    return UsernamesCache[Id]
end



--Set up the boards.
for StatName,Board in pairs(Boards) do
    --Get the stats.
    local StatDisplayName = StatNames[StatName]
    local StatValue = ReplicatedStorage:WaitForChild("Replication"):WaitForChild("Leaderboard"):WaitForChild(StatName)
    local Stats = HttpService:JSONDecode(StatValue.Value)
    StatValue:GetPropertyChangedSignal("Value"):Connect(function()
        Stats = HttpService:JSONDecode(StatValue.Value)
    end)

    --Create the frames for the stats to cover the list with 1 extra.
    local BoardSurfaceGui = Instance.new("SurfaceGui")
    BoardSurfaceGui.ClipsDescendants = true
    BoardSurfaceGui.LightInfluence = 1
    BoardSurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    BoardSurfaceGui.PixelsPerStud = 50
    BoardSurfaceGui.Adornee = Board
    BoardSurfaceGui.Parent = Board

    local StatFrames = {}
    for _ = 1,math.ceil(Board.Size.Y/2) + 1 do
        local Background = Instance.new("Frame")
        Background.BorderSizePixel = 0
        Background.Size = UDim2.new(1,0,0,100)
        Background.Parent = BoardSurfaceGui

        local RankText = Instance.new("TextLabel")
        RankText.BackgroundTransparency = 1
        RankText.Size = UDim2.new(0,90,0,60)
        RankText.Position = UDim2.new(0,5,0,20)
        RankText.Font = Enum.Font.SourceSansBold
        RankText.TextColor3 = Color3.new(0,0,0)
        RankText.TextStrokeColor3 = Color3.new(0.8,0.8,0.8)
        RankText.TextStrokeTransparency = 0
        RankText.TextScaled = true
        RankText.Parent = Background

        local PlayerImage = Instance.new("ImageLabel")
        PlayerImage.BackgroundTransparency = 1
        PlayerImage.Size = UDim2.new(0,90,0,90)
        PlayerImage.Position = UDim2.new(0,105,0,5)
        PlayerImage.Parent = Background

        local PlayerImageCorner = Instance.new("UICorner")
        PlayerImageCorner.CornerRadius = UDim.new(0.2,0)
        PlayerImageCorner.Parent = PlayerImage

        local PlayerNameText = Instance.new("TextLabel")
        PlayerNameText.BackgroundTransparency = 1
        PlayerNameText.Size = UDim2.new(1,-210,0,60)
        PlayerNameText.Position = UDim2.new(0,205,0,0)
        PlayerNameText.Font = Enum.Font.SourceSansBold
        PlayerNameText.TextColor3 = Color3.new(0,0,0)
        PlayerNameText.TextStrokeColor3 = Color3.new(0.8,0.8,0.8)
        PlayerNameText.TextStrokeTransparency = 0
        PlayerNameText.TextSize = 60
        PlayerNameText.TextXAlignment = Enum.TextXAlignment.Left
        PlayerNameText.TextTruncate = Enum.TextTruncate.AtEnd
        PlayerNameText.Parent = Background

        local PlayerStatText = Instance.new("TextLabel")
        PlayerStatText.BackgroundTransparency = 1
        PlayerStatText.Size = UDim2.new(1,-240,0,40)
        PlayerStatText.Position = UDim2.new(0,235,0,55)
        PlayerStatText.Font = Enum.Font.SourceSansBold
        PlayerStatText.TextColor3 = Color3.new(0.3,0.3,0.3)
        PlayerStatText.TextStrokeColor3 = Color3.new(0.8,0.8,0.8)
        PlayerStatText.TextStrokeTransparency = 0
        PlayerStatText.TextScaled = true
        PlayerStatText.TextXAlignment = Enum.TextXAlignment.Left
        PlayerStatText.TextTruncate = Enum.TextTruncate.AtEnd
        PlayerStatText.Parent = Background

        table.insert(StatFrames,{
            Background = Background,
            RankText = RankText,
            PlayerImage = PlayerImage,
            PlayerNameText = PlayerNameText,
            PlayerStatText = PlayerStatText,
        })
    end

    --Connect updating the board.
    RunService.Stepped:Connect(function()
        --Determine the offset of the list.
        local TimeOffset = tick() % 1
        local ColorOffset = math.ceil(tick() % 2)
        local StartIndex = math.ceil(tick() % #Stats)
        if #Stats < #StatFrames then
            TimeOffset = 0
            ColorOffset = 0
            StartIndex = 0
        end

        --Update the entries.
        for i,StatFrame in pairs(StatFrames) do
            --Get the stat.
            local StatIndex = StartIndex + i
            if #Stats >= #StatFrames then
                while StatIndex > #Stats do
                    StatIndex = StatIndex - #Stats
                end
            end
            local PlayerStats = Stats[StatIndex]

            --Update the entries.
            StatFrame.Background.BackgroundColor3 = ((ColorOffset + i) % 2 == 0 and Color3.new(1,1,1) or Color3.new(0.9,0.9,0.9))
            StatFrame.Background.Position = UDim2.new(0,0,0,100 * (i - 1 - TimeOffset))
            if PlayerStats then
                StatFrame.RankText.Text = tostring(StatIndex)
                StatFrame.PlayerImage.Image = "rbxthumb://type=AvatarHeadShot&id="..tostring(PlayerStats.UserId).."&w=420&h=420"
                StatFrame.PlayerNameText.Text = GetUsername(PlayerStats.UserId)
                StatFrame.PlayerStatText.Text = tostring(PlayerStats.Value).." "..tostring(StatDisplayName)
            else
                StatFrame.RankText.Text = ""
                StatFrame.PlayerImage.Image = ""
                StatFrame.PlayerNameText.Text = ""
                StatFrame.PlayerStatText.Text = ""
            end
        end
    end)
end