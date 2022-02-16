--[[
TheNexusAvenger

Entry for a player in the player list.
--]]

local SAME_PLAYER_COLOR_TEXT = Color3.new(1,1,1)
local DIFFERENT_PLAYER_COLOR_TEXT = Color3.new(0.8,0.8,0.8)



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local NexusEvent = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEvent")
local BaseEntry = ReplicatedStorageProject:GetResource("UI.PlayerList.BaseEntry")

local PlayerEntry = BaseEntry:Extend()
PlayerEntry:SetClassName("PlayerEntry")



--[[
Creates the player entry.
--]]
function PlayerEntry:__new()
    self:InitializeSuper()

    --Connect the events.
    self.StatChanged = NexusEvent.new()
    self:AddPropertyFinalizer("Player",function(_,Player)
        if Player then
            self.MainText.Text = Player.DisplayName
        else
            self.MainText.Text = ""
        end
        self.PlayerRankIcon.Player = Player
        self.TextColor3 = (Player == Players.LocalPlayer and SAME_PLAYER_COLOR_TEXT or DIFFERENT_PLAYER_COLOR_TEXT)
        self:UpdateStatEvents()
    end)
    self:AddPropertyFinalizer("Stats",function(_,Stats)
        self.TotalStats = #Stats
        self:UpdateStatEvents()
    end)

    --Set the defaults.
    self.MainText.AutoLocalize = false
    self.Player = nil
    self.Stats = {}
end

--[[
Returns the values of the stats.
--]]
function PlayerEntry:GetStatValues()
    local Values = {}
    local TemporaryStats = self.Player and self.Player:FindFirstChild("TemporaryStats")
    for _,StatData in pairs(self.Stats) do
        table.insert(Values,TemporaryStats and TemporaryStats:WaitForChild(StatData.Name).Value or 0)
    end
    return Values
end

--[[
Updates the connected stat events.
--]]
function PlayerEntry:UpdateStatEvents()
    --Disconnect the existing events.
    if self.StatEvents then
        for _,Connection in pairs(self.StatEvents) do
            Connection:Disconnect()
        end
        self.StatEvents = nil
    end

    --Connect the new events if the player is defined.
    if self.Player then
        self.StatEvents = {}

        --Connect the team colors.
        self.BorderColor3 = (self.Player.Neutral and Color3.new(1,1,1) or self.Player.TeamColor.Color)
        table.insert(self.StatEvents,self.Player:GetPropertyChangedSignal("Neutral"):Connect(function()
            self.BorderColor3 = (self.Player.Neutral and Color3.new(1,1,1) or self.Player.TeamColor.Color)
        end))
        table.insert(self.StatEvents,self.Player:GetPropertyChangedSignal("TeamColor"):Connect(function()
            self.BorderColor3 = (self.Player.Neutral and Color3.new(1,1,1) or self.Player.TeamColor.Color)
        end))

        --Connect the stat events.
        local TemporaryStats = self.Player:WaitForChild("TemporaryStats")
        for i,StatData in pairs(self.Stats) do
            local StatValue = TemporaryStats:WaitForChild(StatData.Name)
            local StatLabel = self.StatLabels[i]
            StatLabel.Text = StatValue.Value
            table.insert(self.StatEvents,StatValue:GetPropertyChangedSignal("Value"):Connect(function()
                StatLabel.Text = StatValue.Value
                self.StatChanged:Fire()
            end))
        end
    end
end

--[[
Destroys the player entry.
--]]
function PlayerEntry:Destroy()
    self.super:Destroy()

    --Disconnect the existing events.
    self.StatChanged:Disconnect()
    if self.StatEvents then
        for _,Connection in pairs(self.StatEvents) do
            Connection:Disconnect()
        end
        self.StatEvents = nil
    end
end



return PlayerEntry