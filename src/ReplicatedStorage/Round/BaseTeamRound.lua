--[[
TheNexusAvenger

Base round class used by the game that includes
a team selection at the beginning.
--]]

local TEAM_SELECTION_TIME = 20
local DEFAULT_TEAMS = {
    BrickColor.new("Bright blue"),
    BrickColor.new("Bright red"),
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))
local ObjectReplication = NexusRoundSystem:GetObjectReplicator()
require(script.Parent:WaitForChild("Helper"):WaitForChild("TeamSelection"))

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
    if NexusRoundSystem:IsServer() then
        self.LoadTime = TEAM_SELECTION_TIME
        self.TeamColors = self.TeamColors or DEFAULT_TEAMS
        self.TeamSelection = ObjectReplication:CreateObject("TeamSelection")
    end
    self:AddToSerialization("TeamColors")
    self:AddToSerialization("TeamSelection","ObjectReference")
    if self.TeamSelection then
        self.TeamSelection:SetTeamColors(self.TeamColors)
    end

    --Connect the team colors changing.
    self:GetPropertyChangedSignal("TeamColors"):Connect(function()
        if not self.TeamSelection then
            self:GetPropertyChangedSignal("TeamSelection"):Wait()
        end
        self.TeamSelection:SetTeamColors(self.TeamColors)
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



return BaseTeamRound