--[[
TheNexusAvenger

Base round class used by the game that includes
a team selection at the beginning.
--]]

local TEAM_SELECTION_TIME = 10
local DEFAULT_TEAMS = {
    BrickColor.new("Bright blue"),
    BrickColor.new("Bright red"),
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))
local ObjectReplication = NexusReplication:GetObjectReplicator()
require(ReplicatedStorage:WaitForChild("State"):WaitForChild("TeamSelection"))

local BaseTeamRound = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
BaseTeamRound:SetClassName("BaseTeamRound")
BaseTeamRound:AddFromSerializeData("BaseTeamRound")
ObjectReplication:RegisterType("BaseTeamRound",BaseTeamRound)



--[[
Creates the round object.
--]]
function BaseTeamRound:__new()
    self:InitializeSuper()

    --Store the teams.
    if NexusReplication:IsServer() then
        self.LoadTime = TEAM_SELECTION_TIME
        self.TeamColors = self.TeamColors or DEFAULT_TEAMS
        self.TeamSelection = ObjectReplication:CreateObject("TeamSelection")
    end
    self:AddToSerialization("TeamColors")
    self:AddToSerialization("TeamSelection")
    if self.TeamSelection then
        self.TeamSelection:SetTeamColors(self.TeamColors)
    end

    --Connect the team colors changing.
    self:AddPropertyFinalizer("TeamColors",function()
        coroutine.wrap(function()
            if not self.TeamSelection then
                self:GetPropertyChangedSignal("TeamSelection"):Wait()
            end
            self.TeamSelection:SetTeamColors(self.TeamColors)
        end)()
    end)
end

--[[
Starts the round.
--]]
function BaseTeamRound:Start(RoundPlayers)
    self.TeamSelection.ParentRound = self
    self.super:Start(RoundPlayers,function()
        self.TeamSelection:Finalize()
    end)
end

--[[
Disposes of the object.
--]]
function BaseTeamRound:Dispose()
    self.super:Dispose()

    --Destroy the objects.
    self.TeamSelection:Destroy()
end



return BaseTeamRound