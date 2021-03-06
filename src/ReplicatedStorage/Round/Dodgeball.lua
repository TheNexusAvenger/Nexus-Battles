--[[
TheNexusAvenger

Class for a Dodgeball round.
--]]

local SCORE_TO_END = 3
local INTERMISSION_TIME_SECONDS = 5
local TEAM_END_DELAY_SECONDS = 5
local TEAM_COLOR_NAME_TO_NAME = {
    ["Bright red"] = "Red team",
    ["Bright blue"] = "Blue team",
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local Dodgeball = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseTeamRound")):Extend()
Dodgeball:SetClassName("Dodgeball")
NexusReplication:RegisterType("Dodgeball",Dodgeball)



--[[
Creates the round object.
--]]
function Dodgeball:__new()
    self:InitializeSuper()
    self.Name = "Dodgeball"

    --Set up the scores.
    if NexusReplication:IsServer() then
        self.TeamScores = NexusReplication:CreateObject("ReplicatedTable")
        self.TeamScores:Set("Bright blue",0)
        self.TeamScores:Set("Bright red",0)
    end
    self:AddToSerialization("TeamScores")
end

--[[
Starts the round.
--]]
function Dodgeball:RoundStarted()
    --Spawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)
    end

    --Run matches until the round ends.
    coroutine.wrap(function()
        while self.Timer.State ~= "COMPLETE" do
            --Run a match.
            wait(INTERMISSION_TIME_SECONDS)
            self:RunDoggeballMatch()

            --Stop the match if a team has enough points.
            if self.Timer.State ~= "COMPLETE" then
                for _,Score in pairs(self.TeamScores:GetAll()) do
                    if Score >= SCORE_TO_END then
                        self.Timer:Complete()
                        break
                    end
                end
            end
        end
    end)()

    --Wait for the timer to complete.
    while self.Timer.State ~= "COMPLETE" do
        self.Timer:GetPropertyChangedSignal("State"):Wait()
    end

    --End the round.
    self:End()
end

--[[
Runs a dodgeball match.
--]]
function Dodgeball:RunDoggeballMatch()
    local DamageService = self:GetService("DamageService")
    local LocalEffectService = self:GetService("LocalEffectService")

    --Determine the players.
    local ActiveMatchPlayers = {}
    for _,Player in pairs(self.Players:GetAll()) do
        local Character = Player.Character
        local TeamColorName = Player.TeamColor.Name
        if not ActiveMatchPlayers[TeamColorName] then
            ActiveMatchPlayers[TeamColorName] = {}
        end
        if Character then
            local Humanoid = Character:FindFirstChild("Humanoid")
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            local Backpack = Player:FindFirstChild("Backpack")
            if Humanoid and Humanoid.Health >= 0 and HumanoidRootPart and Backpack then
                table.insert(ActiveMatchPlayers[TeamColorName],Player)
            end
        end
    end

    --[[
    Removes a player from the match.
    --]]
    local function RemovePlayer(Player)
        for _,TeamPlayers in pairs(ActiveMatchPlayers) do
            for i,OtherPlayer in pairs(TeamPlayers) do
                if Player == OtherPlayer then
                    table.remove(TeamPlayers,i)
                    break
                end
            end
        end
    end

    --Connect players leaving the match.
    local MatchEvents = {}
    table.insert(MatchEvents,self.Players.ItemRemoved:Connect(RemovePlayer))

    --Move the players.
    local MatchActive = true
    local Zones = {
        ["Bright red"] = self.Map:WaitForChild("Arena"):WaitForChild("RedZone"),
        ["Bright blue"] = self.Map:WaitForChild("Arena"):WaitForChild("BlueZone"),
    }
    for TeamColorName,TeamPlayers in pairs(ActiveMatchPlayers) do
        local TeamZone = Zones[TeamColorName]
        local ZoneSize2 = TeamZone.Size/2
        if TeamZone then
            for _,Player in pairs(TeamPlayers) do
                local Character = Player.Character
                if Character then
                    local Humanoid = Character:FindFirstChild("Humanoid")
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    local Backpack = Player:FindFirstChild("Backpack")
                    if Humanoid and Humanoid.Health >= 0 and HumanoidRootPart and Backpack then
                        --Move the player and give a superball.
                        HumanoidRootPart.CFrame = TeamZone.CFrame * CFrame.new(TeamZone.Size.X * ((math.random() * 0.8) - 0.4),3,TeamZone.Size.Z * (0.25 + (0.2 * math.random())))
                        self:SetTools(Player,{"Superball"})

                        coroutine.wrap(function()
                            --Connect the character dieing.
                            table.insert(MatchEvents,DamageService:GetWOEvent(Player):Connect(function()
                                RemovePlayer(Player)
                            end))

                            --Equip the superball.
                            Humanoid:EquipTool(Backpack:WaitForChild("Superball"))

                            --Kill the player if the exit the zone.
                            while MatchActive and Humanoid.Health > 0 do
                                local LocalCharacterPosition = TeamZone.CFrame:Inverse() * HumanoidRootPart.CFrame
                                if LocalCharacterPosition.X < -ZoneSize2.X or LocalCharacterPosition.X > ZoneSize2.X or LocalCharacterPosition.Z < -ZoneSize2.Z or LocalCharacterPosition.Z > ZoneSize2.Z then
                                    Humanoid.Health = 0
                                    LocalEffectService:PlayLocalEffect(Player,"DisplayAlert","Don't cross the line!")
                                end
                                wait()
                            end
                        end)()
                    end
                end
            end
        end
    end

    --Wait for only 1 team to remain.
    while self.Timer.State ~= "COMPLETE" do
        --Get the teams with players.
        local TeamsWithPlayers = {}
        for TeamColorName,TeamPlayers in pairs(ActiveMatchPlayers) do
            if #TeamPlayers > 0 then
                table.insert(TeamsWithPlayers,TeamColorName)
            end
        end

        --Award the point to the team and stop the loop if there is 1 team.
        if #TeamsWithPlayers == 0 then
            --Display the message.
            self:BroadcastLocalEffect("DisplayAlert","No team wins!")

            --Break the match loop.
            break
        elseif #TeamsWithPlayers == 1 then
            --Display the message.
            local WinningTeamColorName = TeamsWithPlayers[1]
            if TEAM_COLOR_NAME_TO_NAME[WinningTeamColorName] then
                self:BroadcastLocalEffect("DisplayAlert",tostring(TEAM_COLOR_NAME_TO_NAME[WinningTeamColorName]).." wins!")
            end

            --Award a point.
            self.TeamScores:Set(WinningTeamColorName,self.TeamScores:Get(WinningTeamColorName) + 1)

            --Break the match loop.
            break
        end

        --Wait to continue.
        wait()
    end
    MatchActive = false

    --Respawn the remaining players.
    wait(TEAM_END_DELAY_SECONDS)
    for _,TeamPlayers in pairs(ActiveMatchPlayers) do
        for _,Player in pairs(TeamPlayers) do
            self:SpawnPlayer(Player)
        end
    end

    --Disconnect the events.
    for _,Event in pairs(MatchEvents) do
        Event:Disconnect()
    end
end

--[[
Disposes of the object.
--]]
function Dodgeball:Dispose()
    self.super:Dispose()

    --Destroy the objects.
    self.TeamScores:Destroy()
end



return Dodgeball