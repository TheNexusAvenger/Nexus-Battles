--[[
TheNexusAvenger

Header for a team in the player list.
--]]

local TEAM_COLOR_BACKGROUND_MULTIPLIER = 0.5



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local BaseEntry = ReplicatedStorageProject:GetResource("UI.PlayerList.BaseEntry")

local TeamHeader = BaseEntry:Extend()
TeamHeader:SetClassName("TeamHeader")



--[[
Creates the team header.
--]]
function TeamHeader:__new()
    self:InitializeSuper()

    --Connect the events.
    self.MainText.Text = ""
    self.PlayersEntries = {}
    self:AddPropertyFinalizer("Stats",function(_,Stats)
        self.TotalStats = #Stats
        self:UpdateTotals()
    end)
    self:AddPropertyFinalizer("TeamColor",function(_,TeamColor)
        self.BorderColor3 = TeamColor.Color
        self.BackgroundColor3 = Color3.new(TEAM_COLOR_BACKGROUND_MULTIPLIER * self.TeamColor.Color.R,TEAM_COLOR_BACKGROUND_MULTIPLIER * self.TeamColor.Color.G,TEAM_COLOR_BACKGROUND_MULTIPLIER * self.TeamColor.Color.B)
    end)

    --Set the defaults.
    self.Stats = {}
    self.TeamColor = BrickColor.new("Institutional white")
end

--[[
Adds a player entry to track.
--]]
function TeamHeader:AddPlayerEntry(PlayerEntry)
    if self.PlayersEntries[PlayerEntry] then return end
    self.PlayersEntries[PlayerEntry] = PlayerEntry.StatChanged:Connect(function()
        self:UpdateTotals()
    end)
    self:UpdateTotals()
end

--[[
Removes a player entry to track.
--]]
function TeamHeader:RemovePlayerEntry(PlayerEntry)
    if not self.PlayersEntries[PlayerEntry] then return end
    self.PlayersEntries[PlayerEntry]:Disconnect()
    self.PlayersEntries[PlayerEntry] = nil
    self:UpdateTotals()
end

--[[
Updates the total stats.
--]]
function TeamHeader:UpdateTotals()
    --Get the totals for the stats.
    local StatsTotals = {}
    for PlayerEntry,_ in pairs(self.PlayersEntries) do
        local PlayerStats = PlayerEntry:GetStatValues()
        for i,_ in pairs(self.Stats) do
            StatsTotals[i] = (StatsTotals[i] or 0) + (PlayerStats[i] or 0)
        end
    end

    --Set the values.
    for i,_ in pairs(self.Stats) do
        self.StatLabels[i].Text = tostring(StatsTotals[i] or 0)
    end
end

--[[
Destroys the player entry.
--]]
function TeamHeader:Destroy()
    self.super:Destroy()

    --Disconnect the existing events.
    for _,Connection in pairs(self.PlayersEntries) do
        Connection:Disconnect()
    end
    self.StatEvents = {}
    self:UpdateTotals()
end



return TeamHeader