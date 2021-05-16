--[[
TheNexusAvenger

Displays the player list during the active round.
Does not handle the end of rounds.
--]]

local STAT_TEXT_ASPECT_RATIO = 1.8
local USERNAME_SIZE_ASPECT_RATIO = 8
local LEADERBOARD_ENTRY_HEIGHT_RELATIVE = 0.035
local MAX_SCREEN_WIDTH_RELATIVE = 0.2
local TRIANGLE_ASPECT_RATIO = 0.2



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local RoundPlayerlist = ReplicatedStorageProject:GetResource("UI.PlayerList.RoundPlayerlist")

local CurrentPlayerlist



local PlayerListContainer = Instance.new("ScreenGui")
PlayerListContainer.Name = "PlayerList"
PlayerListContainer.ResetOnSpawn = false
PlayerListContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)

local PlayerListAdorn = Instance.new("Frame")
PlayerListAdorn.Size = UDim2.new(0.3,0,0.075,0)
PlayerListAdorn.Position = UDim2.new(1,0,0,0)
PlayerListAdorn.BackgroundTransparency = 1
PlayerListAdorn.Parent = PlayerListContainer



--[[
Invoked when the round changes.
--]]
local function CurrentRoundChanged(CurrentRound)
    --Return if there is no current round.
    if not CurrentRound then
        if CurrentPlayerlist then
            CurrentPlayerlist:Destroy()
            CurrentPlayerlist = nil
        end
        return
    end

    --Wait for the round to start.
    while CurrentRound.State == "LOADING" do
        CurrentRound:GetPropertyChangedSignal("State"):Wait()
    end
    if CurrentRoundState.CurrentRound ~= CurrentRound then return end

    --Get the visible stats.
    local Stats = {}
    for _,StatData in pairs(CurrentRound.RoundStats) do
        if StatData.ShowInLeaderstats then
            table.insert(Stats,StatData)
        end
    end

    --Create the playerlist.
    CurrentPlayerlist = RoundPlayerlist.new(CurrentRound.Players,CurrentRound.EliminatedPlayerStats)
    CurrentPlayerlist.Stats = Stats
    CurrentPlayerlist.TeamColors = CurrentRound.TeamColors
    CurrentPlayerlist.Parent = PlayerListAdorn

    --[[
    Updates the size of the adorn.
    --]]
    local function UpdateAdornSize()
        --Determine the sizes of the leaderstats.
        local ScreenSize = PlayerListContainer.AbsoluteSize
        local LeaderstatsEntrySizeY = ScreenSize.Y * LEADERBOARD_ENTRY_HEIGHT_RELATIVE
        local StatsWidth,UsernameWidth = LeaderstatsEntrySizeY * CurrentPlayerlist.TotalStats * STAT_TEXT_ASPECT_RATIO,LeaderstatsEntrySizeY * USERNAME_SIZE_ASPECT_RATIO
        local TotalWidth = StatsWidth + UsernameWidth
        local MaxWidth = ScreenSize.X * MAX_SCREEN_WIDTH_RELATIVE
        local SizeMultiplier = math.min(MaxWidth/TotalWidth,1)
        PlayerListAdorn.Size = UDim2.new(0,TotalWidth * SizeMultiplier,0,LeaderstatsEntrySizeY * SizeMultiplier)
        PlayerListAdorn.AnchorPoint = Vector2.new(1 - ((TRIANGLE_ASPECT_RATIO * LeaderstatsEntrySizeY)/TotalWidth),0)
    end

    --Connect the size-related events.
    CurrentPlayerlist:GetPropertyChangedSignal("TotalStats"):Connect(UpdateAdornSize)
    PlayerListAdorn:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateAdornSize)
    UpdateAdornSize()

    --Connect the round events.
    CurrentRound:GetPropertyChangedSignal("TeamColors"):Connect(function()
        CurrentPlayerlist.TeamColors = CurrentRound.TeamColors
    end)

    --Wait for the round to end and destroy the player list.
    while CurrentRoundState.CurrentRound == CurrentRound and CurrentRound.State ~= "ENDED" do
        CurrentRound:GetPropertyChangedSignal("State"):Wait()
    end
    if CurrentRoundState.CurrentRound ~= CurrentRound then return end
    CurrentPlayerlist:Destroy()
    CurrentPlayerlist = nil
end



--Connect the current round changing.
CurrentRoundState.CurrentRoundChanged:Connect(CurrentRoundChanged)
CurrentRoundChanged(CurrentRoundState.CurrentRound)