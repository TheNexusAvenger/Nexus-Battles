--[[
TheNexusAvenger

Displays the player list during the active round.
Does not handle the end of rounds.
--]]

local STAT_TEXT_ASPECT_RATIO = 1.8
local USERNAME_SIZE_ASPECT_RATIO = 8
local LEADERBOARD_ENTRY_HEIGHT_RELATIVE = 0.035
local MINIMUM_LEADERSTAT_HEIGHT = 24
local MAX_SCREEN_WIDTH_RELATIVE = 0.2
local TRIANGLE_ASPECT_RATIO = 0.2



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local RoundPlayerlist = ReplicatedStorageProject:GetResource("UI.PlayerList.RoundPlayerlist")



--Connect creating the uesr interface.
CurrentRoundState:ConnectTo("CurrentRound",{
    Start = function(self,CurrentRound)
        --Wait for the round to start.
        while CurrentRound.State == "LOADING" do
            CurrentRound:GetPropertyChangedSignal("State"):Wait()
        end
        if not self:IsActive() then return end

        --Get the visible stats.
        local Stats = {}
        for _,StatData in pairs(CurrentRound.RoundStats) do
            if StatData.ShowInLeaderstats then
                table.insert(Stats,StatData)
            end
        end

        --Create the playerlist.
        local PlayerListContainer = Instance.new("ScreenGui")
        PlayerListContainer.Name = "PlayerList"
        PlayerListContainer.ResetOnSpawn = false
        PlayerListContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        self.CurrentPlayerListContainer = PlayerListContainer

        local PlayerListAdorn = Instance.new("Frame")
        PlayerListAdorn.Size = UDim2.new(0.3,0,0.075,0)
        PlayerListAdorn.Position = UDim2.new(1,0,0,0)
        PlayerListAdorn.BackgroundTransparency = 1
        PlayerListAdorn.Parent = PlayerListContainer

        local Playerlist = RoundPlayerlist.new(CurrentRound.Players,CurrentRound.EliminatedPlayerStats)
        Playerlist.Stats = Stats
        Playerlist.TeamColors = CurrentRound.TeamColors
        Playerlist.Parent = PlayerListAdorn
        self.CurrentPlayerlist = Playerlist

        --[[
        Updates the size of the adorn.
        --]]
        local function UpdateAdornSize()
            --Determine the sizes of the leaderstats.
            local ScreenSize = PlayerListContainer.AbsoluteSize
            local LeaderstatsEntrySizeY = ScreenSize.Y * LEADERBOARD_ENTRY_HEIGHT_RELATIVE
            local StatsWidth,UsernameWidth = LeaderstatsEntrySizeY * Playerlist.TotalStats * STAT_TEXT_ASPECT_RATIO,LeaderstatsEntrySizeY * USERNAME_SIZE_ASPECT_RATIO
            local TotalWidth = StatsWidth + UsernameWidth
            local MaxWidth = ScreenSize.X * MAX_SCREEN_WIDTH_RELATIVE
            local SizeMultiplier = math.min(MaxWidth/TotalWidth,1)
            if SizeMultiplier * LeaderstatsEntrySizeY < MINIMUM_LEADERSTAT_HEIGHT then
                SizeMultiplier = MINIMUM_LEADERSTAT_HEIGHT/LeaderstatsEntrySizeY
            end
            PlayerListAdorn.Size = UDim2.new(0,TotalWidth * SizeMultiplier,0,LeaderstatsEntrySizeY * SizeMultiplier)
            PlayerListAdorn.AnchorPoint = Vector2.new(1 - ((TRIANGLE_ASPECT_RATIO * LeaderstatsEntrySizeY)/TotalWidth),0)
            PlayerListAdorn.Visible = (TotalWidth * SizeMultiplier <= ScreenSize.X * 2/5)
        end

        --Connect the size-related events.
        Playerlist:GetPropertyChangedSignal("TotalStats"):Connect(UpdateAdornSize)
        PlayerListContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateAdornSize)
        UpdateAdornSize()

        --Connect the round events.
        CurrentRound:GetPropertyChangedSignal("TeamColors"):Connect(function()
            Playerlist.TeamColors = CurrentRound.TeamColors
        end)

        --Wait for the round to end and destroy the player list.
        while CurrentRoundState.CurrentRound == CurrentRound and CurrentRound.State ~= "ENDED" do
            CurrentRound:GetPropertyChangedSignal("State"):Wait()
        end
        if not self:IsActive() then return end
        self:Clear()
    end,
    Clear = function(self)
        if self.CurrentPlayerListContainer then
            self.CurrentPlayerListContainer:Destroy()
            self.CurrentPlayerListContainer = nil
        end
        if self.CurrentPlayerlist then
            self.CurrentPlayerlist:Destroy()
            self.CurrentPlayerlist = nil
        end
    end,
})