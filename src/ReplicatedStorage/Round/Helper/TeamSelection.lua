--[[[
TheNexusAvenger

Manages selecting teams before round start.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))
local TeamService

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))
local ObjectReplication = NexusRoundSystem:GetObjectReplicator()
local JoinTeamEvent

local TeamSelection = NexusRoundSystem:GetResource("Common.Object.Base.ReplicatedContainer"):Extend()
TeamSelection:SetClassName("TeamSelection")
TeamSelection:AddFromSerializeData("TeamSelection")
ObjectReplication:RegisterType("TeamSelection",TeamSelection)



--[[
Creates the team container object.
--]]
function TeamSelection:__new()
    self:InitializeSuper()

    --Get the event.
    --Can't be done above due to a cyclic dependency.
    if not JoinTeamEvent then
        JoinTeamEvent = ReplicatedStorage:WaitForChild("Replication"):WaitForChild("Round"):WaitForChild("JoinTeam")
    end

    --Prepare the data.
    self.Finalized = false
    self.TotalTeams = 0
    self.TeamColors = {}
    if NexusRoundSystem:IsServer() then
        self.PlayerTeams = ObjectReplication:CreateObject("ReplicatedTable")
    end
    self:AddToSerialization("Finalized")
    self:AddToSerialization("PlayerTeams","ObjectReference")
    self:AddToSerialization("ParentRound","ObjectReference")

    if NexusRoundSystem:IsServer() then
        --Connect players leaving the round.
        self:GetPropertyChangedSignal("ParentRound"):Connect(function()
            if self.ParentRound then
                self.ParentRound.Players.ItemRemoved:Connect(function(Player)
                    self.PlayerTeams:Set(Player,nil)
                end)
            end
        end)

        --Connect joining teams.
        --Checks for if the team can be sent (player is in the round) are handled internally.
        JoinTeamEvent.OnServerEvent:Connect(function(Player,TeamColor)
            self:SetPlayerTeam(Player,TeamColor)
        end)
    end
end

--[[
Sets the team colors valid for the team selection.
--]]
function TeamSelection:SetTeamColors(Colors)
    self.TotalTeams = #Colors
    self.TeamColors = Colors
end

--[[
Returns if a team color exists.
--]]
function TeamSelection:TeamColorExists(TeamColor)
    for _,Color in pairs(self.TeamColors) do
        if Color == TeamColor then
            return true
        end
    end
    return false
end

--[[
Returns if a team is full.
--]]
function TeamSelection:IsFull(Color)
    --Determine the players in the team.
    local PlayersInTeam = 0
    for _,TeamColor in pairs(self.PlayerTeams:GetAll()) do
        if TeamColor == Color then
            PlayersInTeam = PlayersInTeam + 1
        end
    end

    --Return if the total players is too high.
    return PlayersInTeam >= math.ceil(#self.ParentRound.Players:GetAll()/self.TotalTeams)
end

--[[
Sets the team color of the player.
--]]
function TeamSelection:SetPlayerTeam(Player,TeamColor)
    --Return if the color is invalid, the team is full, the selection is finalized, or the player is not in the round.
    if self.Finalized then
        return
    end
    if not self:TeamColorExists(TeamColor) then
        return
    end
    if self:IsFull(TeamColor) then
        return
    end
    if not self.ParentRound.Players:Contains(Player) then
        return
    end

    --Join the team.
    if NexusRoundSystem:IsServer() then
        --Set the player team.
        self.PlayerTeams:Set(Player,TeamColor)
        if not TeamService then
            TeamService = ServerScriptServiceProject:GetResource("Service.TeamService")
        end
        Player.Neutral = false
        Player.Team = TeamService:GetTeam(TeamColor)
    else
        --Message the server to send the team.
        JoinTeamEvent:FireServer(TeamColor)
    end
end

--[[
Finalizes the teams before starting a round.
--]]
function TeamSelection:Finalize()
    --Move the unassigned players to a non-full team.
    for _,Player in pairs(self.ParentRound.Players:GetAll()) do
        if not self.PlayerTeams:Get(Player) then
            for _,TeamColor in pairs(self.TeamColors) do
                if not self:IsFull(TeamColor) then
                    self:SetPlayerTeam(Player,TeamColor)
                    break
                end
            end
        end
    end

    --Mark the team selection as finalized.
    self.Finalized = true
end



return TeamSelection