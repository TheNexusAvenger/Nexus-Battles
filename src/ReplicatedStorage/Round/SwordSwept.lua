--[[
TheNexusAvenger

Class for a Sword Swept round.
--]]

local TEAM_TOOLS = {
    ["Bright blue"] = {
        "Sword",
    },
    ["Bright red"] = {
        "Broom",
    },
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local SwordSwept = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseTeamRound")):Extend()
SwordSwept:SetClassName("SwordSwept")
NexusReplication:GetObjectReplicator():RegisterType("SwordSwept",SwordSwept)



--[[
Creates the round object.
--]]
function SwordSwept:__new()
    self:InitializeSuper()
    self.Name = "SwordSwept"
end

--[[
Starts the round.
--]]
function SwordSwept:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        local PlayerTeam = Player.TeamColor.Name
        if TEAM_TOOLS[PlayerTeam] then
            self:SetStarterTools(Player,TEAM_TOOLS[PlayerTeam])
        end
    end

    --Spawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)
    end

    --Wait for the timer to complete.
    while self.Timer.State ~= "COMPLETE" do
        self.Timer:GetPropertyChangedSignal("State"):Wait()
    end

    --End the round.
    self:End()
end



return SwordSwept