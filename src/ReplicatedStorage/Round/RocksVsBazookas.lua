--[[
TheNexusAvenger

Class for a Rocks Vs Bazookas round.
--]]

local TEAM_TOOLS = {
    ["Bright blue"] = {
        "RocketLauncher",
    },
    ["Bright red"] = {
        "DualRocks",
    },
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local RocksVsBazookas = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseTeamRound")):Extend()
RocksVsBazookas:SetClassName("RocksVsBazookas")
NexusReplication:RegisterType("RocksVsBazookas",RocksVsBazookas)



--[[
Creates the round object.
--]]
function RocksVsBazookas:__new()
    self:InitializeSuper()
    self.Name = "RocksVsBazookas"
end

--[[
Starts the round.
--]]
function RocksVsBazookas:RoundStarted()
    --At this point, Pegboard Nerds - Swamp Thing would start playing since it
    --was the background music used as part of the initial game jam this game
    --mode came from. However, this audio is not available to video creators to
    --safely use in videos, and I can't get permission to use the audio for free.
    --This is because it is a cover of The Grid - Swamp Thing.

    --Award the badges to the players.
    local BadgeService = self:GetService("BadgeService")
    for _,Player in pairs(self.Players:GetAll()) do
        coroutine.wrap(function()
            BadgeService:AwardBadge(Player,"PlayedRocksVsBazookasRound")
        end)()
    end

    --Set the starter inventories of the players for find the Easter Egg.
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



return RocksVsBazookas