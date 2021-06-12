--[[
TheNexusAvenger

Displays the rank icon of a player.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local RankIcons = ReplicatedStorageProject:GetResource("Data.RankIcons")

local RankIcon = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
RankIcon:SetClassName("RankIcon")



--[[
Creates the rank icon.
--]]
function RankIcon:__new(ImageLabel)
    self:InitializeSuper()

    --Store the image label.
    self.ImageLabel = ImageLabel

    --Load Nexus Admin if it wasn't loaded already.
    --Not done at the beginning for testing.
    if not self.NexusAdmin then
        RankIcon.NexusAdmin = ReplicatedStorageProject:GetResource("NexusAdminClient")
    end

    --Connect the events.
    self.Events = {}
    self.PlayerEvents = {}
    self:AddPropertyFinalizer("Player",function(_,Player)
        --Disconnect the existing player events.
        for _,Event in pairs(self.PlayerEvents) do
            Event:Disconnect()
        end
        self.PlayerEvents = {}

        --Update the icon.
        coroutine.wrap(function()
            self:Update()

            --Connect updating based on stat changes.
            if Player then
                local RankScoreValue = Player:WaitForChild("PersistentStats"):WaitForChild("RankScore")
                table.insert(self.PlayerEvents,RankScoreValue.Changed:Connect(function()
                    self:Update()
                end))
            end
        end)()
    end)
    table.insert(self.Events,self.NexusAdmin.Authorization.AdminLevelChanged:Connect(function(Player)
        if Player == self.Player then
            coroutine.wrap(function()
                self:Update()
            end)()
        end
    end))
end

--[[
Resets the icon.
--]]
function RankIcon:Reset()
    self.ImageLabel.Image = ""
    self.ImageLabel.ImageColor3 = Color3.new(1,1,1)
    self.ImageLabel.ImageRectSize = Vector2.new()
    self.ImageLabel.ImageRectOffset = Vector2.new()
end

--[[
Updates the icon.
--]]
function RankIcon:Update()
    --Clear the image if there is no player.
    if not self.Player then
        self:Reset()
        return
    end

    --Determine the icon to use.
    local Icon
    local AdminLevel = self.NexusAdmin.Authorization:GetAdminLevel(self.Player)
    for _,AdminIconData in pairs(RankIcons.Admin) do
        if AdminLevel >= AdminIconData.NexusAdminLevel and (not Icon or AdminIconData.NexusAdminLevel > Icon.NexusAdminLevel) then
            Icon = AdminIconData
        end
    end
    if not Icon then
        local RankScore = self.Player:WaitForChild("PersistentStats"):WaitForChild("RankScore").Value
        for _,RegularIconData in pairs(RankIcons.Normal) do
            if RankScore >= RegularIconData.RankScore and (not Icon or RegularIconData.RankScore > Icon.RankScore) then
                Icon = RegularIconData
            end
        end
    end

    --Set the icon.
    if Icon then
        self.ImageLabel.Image = Icon.Image or ""
        self.ImageLabel.ImageColor3 = Icon.Color or Color3.new(1,1,1)
        self.ImageLabel.ImageRectSize = Icon.Size or Vector2.new()
        self.ImageLabel.ImageRectOffset = Icon.Position or Vector2.new()
    else
        self:Reset()
    end
end

--[[
Destroys the rank icon.
--]]
function RankIcon:Destroy()
    self.super:Destroy()

    --Disconnect the events.
    for _,Event in pairs(self.Events) do
        Event:Disconnect()
    end
    self.Events = {}
    for _,Event in pairs(self.PlayerEvents) do
        Event:Disconnect()
    end
    self.PlayerEvents = {}

    --Reset the image.
    self:Reset()
end



return RankIcon