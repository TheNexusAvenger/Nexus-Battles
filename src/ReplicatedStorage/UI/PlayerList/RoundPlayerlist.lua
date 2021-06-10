--[[
TheNexusAvenger

Playerlist for the current round.
--]]

local ENTRY_SPACING = 0.075
local ENTRY_TWEEN_TIME = 0.25
local HEADER_SPACING_HEIGHT_RELATIVE = 0.75



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local StatsSorter = ReplicatedStorageProject:GetResource("State.Stats.StatsSorter")
local BaseEntry = ReplicatedStorageProject:GetResource("UI.PlayerList.BaseEntry")
local TeamHeader = ReplicatedStorageProject:GetResource("UI.PlayerList.TeamHeader")
local PlayerEntry = ReplicatedStorageProject:GetResource("UI.PlayerList.PlayerEntry")

local RoundPlayerlist = BaseEntry:Extend()
RoundPlayerlist:SetClassName("RoundPlayerlist")



--[[
Creates the round playerlist.
--]]
function RoundPlayerlist:__new(RoundPlayers,EliminatedPlayerStats)
    self:InitializeSuper()

    --Create the adorn frame.
    local EntryAdorn = Instance.new("Frame")
    EntryAdorn.AnchorPoint = Vector2.new(1,0)
    EntryAdorn.Position = UDim2.new(1,0,1,0)
    EntryAdorn.BackgroundTransparency = 1
    EntryAdorn.Parent = self.AdornFrame
    self.EntryAdorn = EntryAdorn

    --Set up the initial state.
    self.DataPlayerEntries = {}
    self.PlayerEntries = {}
    self.TeamHeaders = {}
    self.MainText.Text = ""

    --Connect the events.
    self:AddPropertyFinalizer("Stats",function(_,Stats)
        --Update the labels.
        self.TotalStats = #Stats
        for i,StatData in pairs(Stats) do
            self.StatLabels[i].Text = StatData.Name
        end

        --Update the stats of the player entries.
        self.StatsSorter = StatsSorter.new(Stats)
        for _,Entry in pairs(self.PlayerEntries) do
            Entry.Stats = Stats
        end
        for _,Entry in pairs(self.TeamHeaders) do
            Entry.Stats = Stats
        end

        --Update the order.
        self:UpdateEntries()
    end)
    self:AddPropertyFinalizer("TeamColors",function(_,TeamColors)
        --Create the missing team labels.
        TeamColors = TeamColors or {}
        for _,Color in pairs(TeamColors) do
            if not self.TeamHeaders[Color.Name] then
                local Header = TeamHeader.new()
                Header.TeamColor = Color
                Header.Stats = self.Stats
                Header.Parent = self.EntryAdorn
                self.TeamHeaders[Color.Name] = Header
            end
        end

        --Remove the old headers.
        local ColorsNameMap = {}
        for _,Color in pairs(TeamColors) do
            ColorsNameMap[Color.Name] = true
        end
        local ColorsToRemove = {}
        for ColorName,Header in pairs(self.TeamHeaders) do
            if not ColorsNameMap[ColorName] then
                ColorsToRemove[ColorName] = Header
            end
        end
        for ColorName,Header in pairs(ColorsToRemove) do
            Header:Destroy()
            self.TeamHeaders[ColorName] = nil
        end

        --Update the order.
        self:UpdateEntries()
    end)
    self.AdornFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local AdornSize = self.AdornFrame.AbsoluteSize
        local WidthSpace = (AdornSize.Y * HEADER_SPACING_HEIGHT_RELATIVE)/AdornSize.X
        EntryAdorn.Size = UDim2.new(1 - WidthSpace,0,1,0)
    end)

    --Set the defaults.
    self.TweenPositions = true
    self.Stats = {}
    self.TeamColors = nil

    --Connect the round players.
    if RoundPlayers then
        RoundPlayers.ItemAdded:Connect(function(Player)
            self:AddPlayer(Player)
        end)
        RoundPlayers.ItemRemoved:Connect(function(Player)
            self:RemovePlayer(Player)
        end)
        for _,Player in pairs(RoundPlayers:GetAll()) do
            self:AddPlayer(Player)
        end
    end
    if EliminatedPlayerStats then
        EliminatedPlayerStats.ItemAdded:Connect(function(PlayerData)
            self:AddPlayerFromData(PlayerData)
        end)
        for _,PlayerData in pairs(EliminatedPlayerStats:GetAll()) do
            self:AddPlayerFromData(PlayerData)
        end
    end
end

--[[
Returns the groups of entries to display in order.
--]]
function RoundPlayerlist:GetEntryGroups()
    --Create the initial groups.
    local UngroupedEntriesMap = {}
    local TeamEntries = {}
    local TeamEntriesMap = {}
    for _,TeamColor in pairs(self.TeamColors or {}) do
        local NewEntry = {
            ColorName = TeamColor.Name,
            TeamHeader = self.TeamHeaders[TeamColor.Name],
            Entries = {},
            EntriesMap = {},
        }
        table.insert(TeamEntries,NewEntry)
        TeamEntriesMap[TeamColor.Name] = NewEntry
    end

    --Sort the team entries by group name.
    table.sort(TeamEntries,function(a,b)
        return string.lower(a.ColorName) < string.lower(b.ColorName)
    end)

    --Add the ungrouped players map.
    table.insert(TeamEntries,{
        Entries = {},
        EntriesMap = UngroupedEntriesMap,
    })

    --Add the player entries.
    local StaticStatValues = {}
    for Player,Entry in pairs(self.PlayerEntries) do
        if Player.Neutral or not TeamEntriesMap[Player.TeamColor.Name] then
            UngroupedEntriesMap[Player] = Entry
        else
            TeamEntriesMap[Player.TeamColor.Name].EntriesMap[Player] = Entry
        end
    end
    for Player,Entry in pairs(self.DataPlayerEntries) do
        StaticStatValues[Player] = Entry.StatValues
        if not Entry.TeamColor or not TeamEntriesMap[Entry.TeamColor.Name] then
            UngroupedEntriesMap[Player] = Entry
        else
            TeamEntriesMap[Entry.TeamColor.Name].EntriesMap[Player] = Entry
        end
    end

    --Sort the player entries.
    for _,TeamGroup in pairs(TeamEntries) do
        --Create the list of players.
        local PlayersToSort = {}
        for Player,_ in pairs(TeamGroup.EntriesMap) do
            table.insert(PlayersToSort,Player)
        end

        --Get the sorted players and add them to the entries.
        local SortedPlayers = self.StatsSorter:GetSortedPlayers(PlayersToSort,StaticStatValues,nil)
        for _,Player in pairs(SortedPlayers) do
            table.insert(TeamGroup.Entries,TeamGroup.EntriesMap[Player])
        end
    end

    --Return the team entries.
    return TeamEntries
end

--[[
Moves an entry to a given position.
--]]
function RoundPlayerlist:MoveEntry(Entry,HeightOffset)
    local NewPosition = UDim2.new(0,0,HeightOffset,0)
    if self.TweenPositions and Entry.AdornFrame:IsDescendantOf(game) then
        Entry.AdornFrame:TweenPosition(NewPosition,"InOut","Quad",ENTRY_TWEEN_TIME,true)
    else
        Entry.AdornFrame.Position = NewPosition
    end
end

--[[
Updates the positions of the labels.
--]]
function RoundPlayerlist:UpdateEntries()
    --Update the team headers and player entries.
    local CurrentSpot = 0
    local GroupEntries = self:GetEntryGroups()
    for _,Group in pairs(GroupEntries) do
        --Move the team header.
        if Group.TeamHeader then
            self:MoveEntry(Group.TeamHeader,CurrentSpot + ((CurrentSpot + 1) * ENTRY_SPACING))
            CurrentSpot = CurrentSpot + 1
        end

        --Move the player entries.
        for _,Entry in pairs(Group.Entries) do
            self:MoveEntry(Entry,CurrentSpot + ((CurrentSpot + 1) * ENTRY_SPACING))
            CurrentSpot = CurrentSpot + 1
            if Entry.CurrentTeamHeader then
                Entry.CurrentTeamHeader:RemovePlayerEntry(Entry)
            end
            Entry.CurrentTeamHeader = Group.TeamHeader
            if Group.TeamHeader then
                Group.TeamHeader:AddPlayerEntry(Entry)
            end
        end
    end
end

--[[
Adds a player to the playerlist.
--]]
function RoundPlayerlist:AddPlayer(Player)
    --Return if the player already exists.
    if self.PlayerEntries[Player] then return end

    --Create the player entry.
    local Entry = PlayerEntry.new()
    Entry.Stats = self.Stats
    Entry.Player = Player
    Entry.Parent = self.EntryAdorn
    self.PlayerEntries[Player] = Entry

    --Connect the events.
    Entry:GetPropertyChangedSignal("BorderColor3"):Connect(function()
        self:UpdateEntries()
    end)
    Entry.StatChanged:Connect(function()
        self:UpdateEntries()
    end)

    --Update the order.
    self:UpdateEntries()
end

--[[
Removes a player from the playerlist.
--]]
function RoundPlayerlist:RemovePlayer(Player)
    --Return if the player doesn't exist.
    if not self.PlayerEntries[Player] then return end

    --Remove the player entry.
    local Entry = self.PlayerEntries[Player]
    if Entry.CurrentTeamHeader then
        Entry.CurrentTeamHeader:RemovePlayerEntry(Entry)
    end
    Entry:Destroy()
    self.PlayerEntries[Player] = nil

    --Update the order.
    self:UpdateEntries()
end

--[[
Adds a player to the playerlist with fixed data.
--]]
function RoundPlayerlist:AddPlayerFromData(PlayerData)
    --Return if the player already exists.
    if self.DataPlayerEntries[PlayerData.Player] then return end

    --Create the player entry.
    local Entry = PlayerEntry.new()
    Entry.StatValues = PlayerData.Stats
    Entry.TeamColor = PlayerData.TeamColor
    Entry.TotalStats = #self.Stats
    Entry.PlayerRankIcon.Player = PlayerData.Player
    Entry.Parent = self.EntryAdorn
    self.DataPlayerEntries[PlayerData.Player] = Entry

    --Set the colors.
    Entry.MainText.Text = PlayerData.Player.DisplayName
    Entry.MainText.TextColor3 = Color3.new(0.6,0.6,0.6)
    Entry.BorderColor3 = (PlayerData.TeamColor and PlayerData.TeamColor.Color or Color3.new(1,1,1))

    --Set the stat values.
    for i,StatData in pairs(self.Stats) do
        local StatLabel = Entry.StatLabels[i]
        StatLabel.Text = PlayerData.Stats[StatData.Name]
        StatLabel.TextColor3 = Color3.new(0.6,0.6,0.6)
    end

    --Update the order.
    self:UpdateEntries()
end

--[[
Destroys the playerlist.
--]]
function RoundPlayerlist:Destroy()
    self.super:Destroy()

    --Destroy the headers and entries.
    for _,Entry in pairs(self.DataPlayerEntries) do
        Entry:Destroy()
    end
    for _,Entry in pairs(self.PlayerEntries) do
        Entry:Destroy()
    end
    self.PlayerEntries = {}
    for _,Entry in pairs(self.TeamHeaders) do
        Entry:Destroy()
    end
    self.TeamHeaders = {}
end



return RoundPlayerlist