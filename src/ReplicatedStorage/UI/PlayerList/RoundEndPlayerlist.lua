--[[
TheNexusAvenger

Playerlist for the end of a round.
--]]

local ENTRY_SPACING = 0.075
local HEADER_SPACING_HEIGHT_RELATIVE = 0.75



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local StatsSorter = ReplicatedStorageProject:GetResource("State.Stats.StatsSorter")
local BaseEntry = ReplicatedStorageProject:GetResource("UI.PlayerList.BaseEntry")

local RoundEndPlayerlist = BaseEntry:Extend()
RoundEndPlayerlist:SetClassName("RoundEndPlayerlist")



--[[
Creates the round end playerlist.
--]]
function RoundEndPlayerlist:__new(RoundPlayers,EliminatedPlayerStats)
    self:InitializeSuper()

    --Create the adorn frame.
    local EntryAdorn = Instance.new("Frame")
    EntryAdorn.AnchorPoint = Vector2.new(1,0)
    EntryAdorn.Position = UDim2.new(1,0,1,0)
    EntryAdorn.BackgroundTransparency = 1
    EntryAdorn.Parent = self.AdornFrame
    self.EntryAdorn = EntryAdorn

    --Store the initial state.
    self.PlayerEntries = {}
    self.Players = RoundPlayers:GetAll()
    self.EliminatedPlayersMap = {}
    self.StaticStatValues = {}
    self.StaticTeamColors = {}
    self.MainText.Text = ""
    for _,Player in pairs(RoundPlayers:GetAll()) do
        local TemporaryStats = Player:FindFirstChild("TemporaryStats")
        if TemporaryStats then
            local StatValues = {}
            self.StaticStatValues[Player] = StatValues
            for _,StatValue in pairs(TemporaryStats:GetChildren()) do
                StatValues[StatValue.Name] = StatValue.Value
            end
        end
        if not Player.Neutral then
            self.StaticTeamColors[Player] = Player.TeamColor
        end
    end
    for _,PlayerData in pairs(EliminatedPlayerStats:GetAll()) do
        table.insert(self.Players,PlayerData.Player)
        self.StaticTeamColors[PlayerData.Player] = PlayerData.TeamColor
        self.StaticStatValues[PlayerData.Player] = PlayerData.Stats
        self.EliminatedPlayersMap[PlayerData.Player] = true
    end

    --Connect the events.
    self:GetPropertyChangedSignal("Stats"):Connect(function()
        --Update the total stats of the existing entries.
        for _,Entry in pairs(self.PlayerEntries) do
            Entry.TotalStats = #self.Stats
        end

        --Update the main header.
        self.TotalStats = #self.Stats
        for i,StatData in pairs(self.Stats) do
            self.StatLabels[i].Text = StatData.Name
        end

        --Update the players.
        self.StatsSorter = StatsSorter.new(self.Stats)
        self:UpdatePlayers()
    end)
    self:GetPropertyChangedSignal("MVPs"):Connect(function()
        self:UpdatePlayers()
    end)
    self:GetPropertyChangedSignal("MaxEntries"):Connect(function()
        self:UpdatePlayers()
    end)
    self.AdornFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local AdornSize = self.AdornFrame.AbsoluteSize
        local WidthSpace = (AdornSize.Y * HEADER_SPACING_HEIGHT_RELATIVE)/AdornSize.X
        EntryAdorn.Size = UDim2.new(1 - WidthSpace,0,1,0)
    end)

    --Set the defaults.
    self.Stats = {}
    self.MVPs = {}
    self.MaxEntries = 10
end

--[[
Updates the displayed players.
--]]
function RoundEndPlayerlist:UpdatePlayers()
    --Add additional player entries.
    local TotalPlayerEntries = math.min(self.MaxEntries or 10,#self.Players)
    for i = #self.PlayerEntries + 1,TotalPlayerEntries do
        local NewEntry = BaseEntry.new()
        NewEntry.TotalStats = #self.Stats
        NewEntry.AdornFrame.Position = UDim2.new(0,0,(i - 1) + (i * ENTRY_SPACING))
        NewEntry.Parent = self.EntryAdorn
        table.insert(self.PlayerEntries,NewEntry)
    end

    --Remove additional player entries.
    for i = #self.PlayerEntries,TotalPlayerEntries + 1,-1 do
        self.PlayerEntries[i]:Destroy()
        self.PlayerEntries[i] = nil
    end

    --Get the order to display the players.
    local SortedPlayers = self.StatsSorter:GetSortedPlayers(self.Players,self.StaticStatValues,self.MVPs)

    --Update the player list.
    for i,PlayerEntry in pairs(self.PlayerEntries) do
        local Player = SortedPlayers[i]
        PlayerEntry.PlayerRankIcon.Player = Player
        PlayerEntry.MainText.Text = Player.DisplayName
        PlayerEntry.MainText.TextColor3 = (self.EliminatedPlayersMap[Player] and Color3.new(0.6,0.6,0.6) or Color3.new(1,1,1))
        PlayerEntry.BorderColor3 = (self.StaticTeamColors[Player] and self.StaticTeamColors[Player].Color or Color3.new(1,1,1))

        --Update the player stats.
        local Stats = self.StaticStatValues[Player]
        for j,StatData in pairs(self.Stats) do
            PlayerEntry.StatLabels[j].Text = tostring(Stats[StatData.Name] or StatData.DefaultValue or 0)
            PlayerEntry.StatLabels[j].TextColor3 = (self.EliminatedPlayersMap[Player] and Color3.new(0.6,0.6,0.6) or Color3.new(1,1,1))
        end
    end
end

--[[
Destroys the playerlist.
--]]
function RoundEndPlayerlist:Destroy()
    self.super:Destroy()

    --Destroy the headers and entries.
    for _,Entry in pairs(self.PlayerEntries) do
        Entry:Destroy()
    end
    self.PlayerEntries = {}
end



return RoundEndPlayerlist