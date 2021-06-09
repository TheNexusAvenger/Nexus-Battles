--[[
TheNexusAvenger

Displays the personal stats in the lobby.
--]]

local WEAPON_ORDER = {
    Sword = 1,
    Superball = 2,
    Slingshot = 3,
    RocketLauncher = 4,
    Bomb = 5,
    Reflector = 6,
    Broom = 7,
    Leeching = 8,
    Reactance = 9,
    DualRocks = 10,
}
local IGNORED_STATS = {
    ["Inventory"] = true,
}



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Lobby = Workspace:WaitForChild("Lobby")
local StatsBoard = Lobby:WaitForChild("StatsBoard")
local StatsBoardPart = StatsBoard:WaitForChild("Board")
local RankIcons = ReplicatedStorageProject:GetResource("Data.RankIcons")
table.sort(RankIcons.Normal,function(a,b) return a.RankScore < b.RankScore end)
local WeaponIconModels = ReplicatedStorageProject:GetResource("Model.WeaponIconModels"):GetChildren()
local WeaponIcon = ReplicatedStorageProject:GetResource("UI.Icon.WeaponIcon")

local PersistentStats = Players.LocalPlayer:WaitForChild("PersistentStats")
local RankScoreValue = PersistentStats:WaitForChild("RankScore")



--Create the board.
local BoardSurfaceGui = Instance.new("SurfaceGui")
BoardSurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
BoardSurfaceGui.PixelsPerStud = 25
BoardSurfaceGui.ResetOnSpawn = false
BoardSurfaceGui.Name = "PersonalStatsBoard"
BoardSurfaceGui.Adornee = StatsBoardPart
BoardSurfaceGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local CurrentRankImage = Instance.new("ImageLabel")
CurrentRankImage.BackgroundTransparency = 1
CurrentRankImage.Size = UDim2.new(0.7,0,0.7,0)
CurrentRankImage.Position = UDim2.new(0.025,0,0.025,0)
CurrentRankImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
CurrentRankImage.Parent = BoardSurfaceGui

local CurrentRankText = Instance.new("TextLabel")
CurrentRankText.BackgroundTransparency = 1
CurrentRankText.Size = UDim2.new(1,0,0.3,0)
CurrentRankText.Position = UDim2.new(0,0,0.7,0)
CurrentRankText.Font = Enum.Font.SourceSansBold
CurrentRankText.TextScaled = true
CurrentRankText.TextStrokeTransparency = 0
CurrentRankText.TextStrokeColor3 = Color3.new(0,0,0)
CurrentRankText.Parent = CurrentRankImage

local IndividualStatsContainer = Instance.new("Frame")
IndividualStatsContainer.BackgroundTransparency = 1
IndividualStatsContainer.Size = UDim2.new(0.55,0,0.7,0)
IndividualStatsContainer.Position = UDim2.new(0.425,0,0.025,0)
IndividualStatsContainer.Parent = BoardSurfaceGui

local WeaponKills = Instance.new("Frame")
WeaponKills.BackgroundTransparency = 1
WeaponKills.AnchorPoint = Vector2.new(0,1)
WeaponKills.Size = UDim2.new(0.95,0,0.95/10,0)
WeaponKills.Position = UDim2.new(0.025,0,0.975,0)
WeaponKills.SizeConstraint = Enum.SizeConstraint.RelativeXX
WeaponKills.Parent = BoardSurfaceGui

local WeaponIcons = {}
for _,Model in pairs(WeaponIconModels) do
    local Icon = WeaponIcon.new(Model.Name)
    Icon.Size = UDim2.new(1/#WeaponIconModels,0,1/#WeaponIconModels,0)
    Icon.SizeConstraint = Enum.SizeConstraint.RelativeXX
    Icon.Parent = WeaponKills

    local TotalText = Instance.new("TextLabel")
    TotalText.BackgroundTransparency = 1
    TotalText.Size = UDim2.new(0.9,0,0.6,0)
    TotalText.Position = UDim2.new(0.05,0,0.2,0)
    TotalText.Font = Enum.Font.SourceSansBold
    TotalText.TextColor3 = Color3.new(0,0,0)
    TotalText.TextStrokeColor3 = Color3.new(1,1,1)
    TotalText.TextStrokeTransparency = 0
    TotalText.TextScaled = true
    TotalText.Text = "0"
    TotalText.Parent = Icon.Module3DFrame.AdornFrame

    table.insert(WeaponIcons,{
        Name = Model.Name,
        Icon = Icon,
        Text = TotalText,
    })
end



--[[
Creates a display for a stat.
--]]
local function CreateStatDisplay(Name,Value,Size,Position)
    --Create the display.
    local StatContainer = Instance.new("Frame")
    StatContainer.BackgroundTransparency = 1
    StatContainer.Size = Size
    StatContainer.Position = Position
    StatContainer.Parent = IndividualStatsContainer

    local ValueText = Instance.new("TextLabel")
    ValueText.BackgroundTransparency = 1
    ValueText.Size = UDim2.new(0.9,0,0.7,0)
    ValueText.Position = UDim2.new(0.05,0,0,0)
    ValueText.Font = Enum.Font.SourceSansBold
    ValueText.TextColor3 = Color3.new(0,0,0)
    ValueText.TextStrokeColor3 = Color3.new(1,1,1)
    ValueText.TextStrokeTransparency = 0
    ValueText.TextScaled = true
    ValueText.Text = tostring(Value.Value)
    ValueText.Parent = StatContainer

    local NameText = Instance.new("TextLabel")
    NameText.BackgroundTransparency = 1
    NameText.Size = UDim2.new(0.9,0,0.3,0)
    NameText.Position = UDim2.new(0.05,0,0.6,0)
    NameText.Font = Enum.Font.SourceSansBold
    NameText.TextColor3 = Color3.new(0,0,0)
    NameText.TextStrokeColor3 = Color3.new(1,1,1)
    NameText.TextStrokeTransparency = 0
    NameText.TextScaled = true
    NameText.Text = Name
    NameText.Parent = StatContainer

    --Connect the value changing.
    Value:GetPropertyChangedSignal("Value"):Connect(function()
        ValueText.Text = tostring(Value.Value)
    end)
end

--[[
Updates the rank stats.
--]]
local function UpdateRankStats()
    --Determine the current rank.
    local CurrentRankId = 1
    local RankScore = RankScoreValue.Value
    for i,RankData in pairs(RankIcons.Normal) do
        if RankScore >= RankData.RankScore then
            CurrentRankId = i
        end
    end
    local CurrentRankData = RankIcons.Normal[CurrentRankId]

    --Update the current rank.
    CurrentRankImage.Image = CurrentRankData.Image
    CurrentRankImage.ImageRectSize = CurrentRankData.Size
    CurrentRankImage.ImageRectOffset = CurrentRankData.Position
    CurrentRankImage.ImageColor3 = CurrentRankData.Color
    CurrentRankText.Text = "RANK "..tostring(CurrentRankId)
    CurrentRankText.TextColor3 = CurrentRankData.Color
end

--[[
Updates the weapon stats.
--]]
local function UpdateWeaponStats()
    --Get the values of the stats.
    local StatValues = {}
    for _,Icon in pairs(WeaponIcons) do
        local Stat = PersistentStats:FindFirstChild("TotalKOs_"..Icon.Name)
        StatValues[Icon.Name] = (Stat and Stat.Value or 0)
    end

    --Sort the icons.
    table.sort(WeaponIcons,function(a,b)
        local ValueA,ValueB = StatValues[a.Name],StatValues[b.Name]
        if ValueA ~= ValueB then
            return ValueA > ValueB
        end
        return (WEAPON_ORDER[a.Name] or 0) < (WEAPON_ORDER[b.Name] or 0)
    end)

    --Update the icons.
    for i,Icon in pairs(WeaponIcons) do
        Icon.Icon.Position = UDim2.new((i - 1)/#WeaponIconModels,0,0,0)
        Icon.Text.Text = tostring(StatValues[Icon.Name])
    end
end

--[[
Handles a stat value being added.
--]]
local function StatAdded(StatValue)
    if IGNORED_STATS[StatValue.Name] then return end
    StatValue:GetPropertyChangedSignal("Value"):Connect(UpdateWeaponStats)
    UpdateWeaponStats()
end



--Create the stat displays.
CreateStatDisplay("Knockouts",PersistentStats:WaitForChild("TotalKOs"),UDim2.new(0.4,0,0.4,0),UDim2.new(0.1,0,0,0))
CreateStatDisplay("Wipeouts",PersistentStats:WaitForChild("TotalWOs"),UDim2.new(0.4,0,0.4,0),UDim2.new(0.5,0,0,0))
CreateStatDisplay("Longest Streak",PersistentStats:WaitForChild("LongestKOStreak"),UDim2.new(1/3,0,0.3,0),UDim2.new(0,0,0.4,0))
CreateStatDisplay("Most Knockouts",PersistentStats:WaitForChild("MostKOs"),UDim2.new(1/3,0,0.3,0),UDim2.new(1/3,0,0.4,0))
CreateStatDisplay("Most Wipeouts",PersistentStats:WaitForChild("MostWOs"),UDim2.new(1/3,0,0.3,0),UDim2.new(2/3,0,0.4,0))
CreateStatDisplay("Collected Coins",PersistentStats:WaitForChild("TotalCoins"),UDim2.new(1/3,0,0.3,0),UDim2.new(0,0,0.7,0))
CreateStatDisplay("MVPs",PersistentStats:WaitForChild("TimesMVP"),UDim2.new(1/3,0,0.3,0),UDim2.new(1/3,0,0.7,0))
CreateStatDisplay("Captured Flags",PersistentStats:WaitForChild("CapturedFlags"),UDim2.new(1/3,0,0.3,0),UDim2.new(2/3,0,0.7,0))

--Connect the stats changing.
RankScoreValue:GetPropertyChangedSignal("Value"):Connect(UpdateRankStats)
UpdateRankStats()

PersistentStats.ChildAdded:Connect(StatAdded)
for _,StatValue in pairs(PersistentStats:GetChildren()) do
    StatAdded(StatValue)
end