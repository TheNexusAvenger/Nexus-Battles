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
function RoundEndPlayerlist:__new(RoundPlayers)
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
    self.MainText.Text = ""

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
    local SortedPlayers = self.StatsSorter:GetSortedPlayers(self.Players,self.MVPs)

    --Update the player list.
    for i,PlayerEntry in pairs(self.PlayerEntries) do
        local Player = SortedPlayers[i]
        PlayerEntry.MainText.Text = Player.DisplayName
        PlayerEntry.BorderColor3 = (Player.Neutral and Color3.new(1,1,1) or Player.TeamColor.Color)

        --Update the player stats.
        local TemporaryStats = Player:FindFirstChild("TemporaryStats")
        for j,StatData in pairs(self.Stats) do
            local StatValue = (TemporaryStats and TemporaryStats:FindFirstChild(StatData.Name))
            PlayerEntry.StatLabels[j].Text = tostring(StatValue and StatValue.Value or StatData.DefaultValue or 0)
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