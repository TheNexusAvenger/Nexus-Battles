--[[
TheNexusAvenger

Base round class used by the game.
--]]

local DEFAULT_ROUND_TIME = 5 * 60
local LOAD_TIME = 5
local DEFAULT_RESPAWN_TIME = 3
local MVP_COINS = 20



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))
local StatsSorter
local RankScoreBonuses

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))
local ObjectReplication = NexusReplication:GetObjectReplicator()

local BaseRound = NexusReplication:GetResource("Common.Object.ReplicatedContainer"):Extend()
BaseRound:SetClassName("BaseRound")
BaseRound:AddFromSerializeData("BaseRound")
NexusReplication:GetObjectReplicator():RegisterType("BaseRound",BaseRound)



--[[
Creates the round object.
--]]
function BaseRound:__new()
    self:InitializeSuper()
    self.Name = "BaseRound"

    --Store the round data.
    self.DisabledSpawningPlayers = {}
    self.PlayerStarterTools = {}
    self.State = "LOADING"
    self.TimerText = "TIME REMAINING"
    self.MVPs = {}
    if NexusReplication:IsServer() then
        self.Players = ObjectReplication:CreateObject("ReplicatedTable")
        self.Spectators = ObjectReplication:CreateObject("ReplicatedTable")
        self.EliminatedPlayerStats = ObjectReplication:CreateObject("ReplicatedTable")
        self.Timer = ObjectReplication:CreateObject("Timer")
    end
    self:AddToSerialization("State")
    self:AddToSerialization("TimerText")
    self:AddToSerialization("Map")
    self:AddToSerialization("MapName")
    self:AddToSerialization("RoundContainer")
    self:AddToSerialization("MVPs")
    self:AddToSerialization("Players","ObjectReference")
    self:AddToSerialization("Spectators","ObjectReference")
    self:AddToSerialization("EliminatedPlayerStats","ObjectReference")
    self:AddToSerialization("Timer","ObjectReference")

    --Store the stats.
    self.RoundStats = {
        {
            Name = "KOs",
            ValueType = "IntValue",
            DefaultValue = 0,
            ShowInLeaderstats = true,
            Prefer = "Higher",
        },
        {
            Name = "WOs",
            ValueType = "IntValue",
            DefaultValue = 0,
            ShowInLeaderstats = true,
            Prefer = "Lower",
        },
        {
            Name = "CurrentStreak",
            ValueType = "IntValue",
            DefaultValue = 0,
        },
        {
            Name = "MaxStreak",
            ValueType = "IntValue",
            DefaultValue = 0,
        },
    }

    --Set up the spawn points.
    self.SpawnPoints = {
        Normal = {
            CurrentSpawn = 1,
            Parts = {},
        },
        Team = {},
        Players = {},
    }
    self:AddPropertyFinalizer("Map",function(_,Map)
        --Get the spawn point models.
        local NewSpawnPoints = {
            Normal = {
                CurrentSpawn = 1,
                Parts = {},
            },
            Team = {},
            Players = {},
        }
        self.SpawnPoints = NewSpawnPoints
        local SpawnPoints = Map:FindFirstChild("SpawnPoints")
        if not SpawnPoints then return end
        local TeamSpawnPoints = SpawnPoints:FindFirstChild("TeamSpawnPoints")

        --Add the base spawn parts.
        for _,Part in pairs(SpawnPoints:GetChildren()) do
            if Part:IsA("BasePart") then
                table.insert(NewSpawnPoints.Normal.Parts,Part)
            end
        end
        SpawnPoints.ChildAdded:Connect(function(Part)
            if Part:IsA("BasePart") then
                table.insert(NewSpawnPoints.Normal.Parts,Part)
            end
        end)
        SpawnPoints.ChildRemoved:Connect(function(Part)
            local Index
            for i,OtherPart in pairs(NewSpawnPoints.Normal.Parts) do
                if Part == OtherPart then
                    Index = i
                    break
                end
            end
            if not Index then return end
            table.remove(NewSpawnPoints.Normal.Parts,Index)
            if NewSpawnPoints.Normal.CurrentSpawn > #NewSpawnPoints.Normal.Parts then
                NewSpawnPoints.Normal.CurrentSpawn = #NewSpawnPoints.Normal.Parts
            end
        end)

        --Add the team spawn parts.
        if not TeamSpawnPoints then return end
        for _,Part in pairs(TeamSpawnPoints:GetChildren()) do
            if Part:IsA("BasePart") then
                if not NewSpawnPoints.Team[Part.BrickColor.Name] then
                    NewSpawnPoints.Team[Part.BrickColor.Name] = {
                        CurrentSpawn = 1,
                        Parts = {},
                    }
                end
                table.insert(NewSpawnPoints.Team[Part.BrickColor.Name].Parts,Part)
            end
        end
        TeamSpawnPoints.ChildAdded:Connect(function(Part)
            if Part:IsA("BasePart") then
                if not NewSpawnPoints.Team[Part.BrickColor.Name] then
                    NewSpawnPoints.Team[Part.BrickColor.Name] = {
                        CurrentSpawn = 1,
                        Parts = {},
                    }
                end
                table.insert(NewSpawnPoints.Team[Part.BrickColor.Name].Parts,Part)
            end
        end)
        TeamSpawnPoints.ChildRemoved:Connect(function(Part)
            for _,TeamSpawns in pairs(NewSpawnPoints.Team) do
                local Index
                for i,OtherPart in pairs(TeamSpawns.Parts) do
                    if Part == OtherPart then
                        Index = i
                        break
                    end
                end
                if Index then
                    table.remove(TeamSpawns.Parts,Index)
                    if TeamSpawns.CurrentSpawn > #TeamSpawns.Parts then
                        TeamSpawns.CurrentSpawn = #TeamSpawns.Parts
                    end
                end
            end
        end)
    end)
end

--[[
Returns a service.
--]]
function BaseRound:GetService(ServiceName)
    return ServerScriptServiceProject:GetResource("Service."..tostring(ServiceName))
end

--[[
Starts the round.
--]]
function BaseRound:Start(RoundPlayers,LoadTimeElapsedCallback)
    --Create the temporary stats.
    for _,Player in pairs(RoundPlayers) do
        self:GetService("StatService"):ClearTemporaryStats(Player)
        local Stats = self:GetService("StatService"):GetTemporaryStats(Player)
        for _,StatData in pairs(self.RoundStats) do
            Stats:Create(StatData.Name,StatData.ValueType,StatData.DefaultValue)
        end
    end

    --Add the players.
    for _,Player in pairs(RoundPlayers) do
        self.Players:Add(Player)
    end
    Players.PlayerRemoving:Connect(function(Player)
        self.Players:Remove(Player)
        self.Spectators:Remove(Player)
    end)

    --Run the load timer.
    self.Timer:SetDuration(self.LoadTime or LOAD_TIME)
    self.Timer:Start()
    while self.Timer.State ~= "COMPLETE" do
        self.Timer:GetPropertyChangedSignal("State"):Wait()
    end
    if LoadTimeElapsedCallback then
        LoadTimeElapsedCallback()
    end

    --Start the main timer.
    self.Timer:SetDuration(DEFAULT_ROUND_TIME)
    self.Timer:Start()
    self.State = "ACTIVE"

    --Start the round.
    self.object:RoundStarted()
end

--[[
Ends the round.
--]]
function BaseRound:End()
    if self.State == "ENDED" then return end

    --Set the MVPs if they weren't set.
    if not self.MVPs or #self.MVPs == 0 then
        if not StatsSorter then
            local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
            StatsSorter = ReplicatedStorageProject:GetResource("State.Stats.StatsSorter")
        end
        local Sorter = StatsSorter.new(self.RoundStats)
        self.MVPs = Sorter:GetMVPs(self.Players:GetAll())
    end

    --Increase the rank scores.
    for _,Player in pairs(self.Players:GetAll()) do
        self:AddRankScore(Player)
    end

    --Stop the round.
    self.Timer:Stop()
    self.State = "ENDED"

    --Despawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,false)
        self:DespawnPlayer(Player)
    end

    --Award the MVP coins.
    local MVPCoins = math.ceil(MVP_COINS/#self.MVPs)
    for _,Player in pairs(self.MVPs) do
        self:GetService("StatService"):GetPersistentStats(Player):Get("TimesMVP"):Increment()
        coroutine.wrap(function()
            for _ = 1,MVPCoins do
                if not Player.Parent then return end
                self:GetService("CoinService"):GiveCoins(Player,1)
                wait()
            end
        end)()
    end
end

--[[
Sets if automatic spawning of a player is enabled.
--]]
function BaseRound:SetSpawningEnabled(Player,Enabled)
    if not Player or not Player.Parent or not self.Players:Contains(Player) then return end
    self.DisabledSpawningPlayers[Player] = not Enabled
end

--[[
Sets the spawn location of a player.
--]]
function BaseRound:SetPlayerSpawn(Player,SpawnPart)
    self.SpawnPoints.Players[Player] = SpawnPart
end

--[[
Spawns a player.
--]]
function BaseRound:SpawnPlayer(Player)
    if not Player or not Player.Parent or not self.Players:Contains(Player) then return end
    coroutine.wrap(function()
        --Get a spawn location part.
        local SpawnPart = self.SpawnPoints.Players[Player]
        if not SpawnPart then
            local SpawnParts = (not Player.Neutral and self.SpawnPoints.Team[Player.TeamColor.Name] or self.SpawnPoints.Normal)
            if #SpawnParts.Parts == 0 then return end
            SpawnPart = SpawnParts.Parts[SpawnParts.CurrentSpawn]
            SpawnParts.CurrentSpawn = (SpawnParts.CurrentSpawn % #SpawnParts.Parts) + 1
        end

        --Teleport the player.
        local CharacterService = self:GetService("CharacterService")
        local Character = CharacterService:SpawnCharacter(Player,SpawnPart)
        CharacterService:AddForceField(Player)
        if not Character then return end
        local Humanoid = Character:WaitForChild("Humanoid")

        --Connect the character dieing.
        Humanoid.Died:Connect(function()
            wait(DEFAULT_RESPAWN_TIME)
            if self.DisabledSpawningPlayers[Player] then return end
            if not self.Players:Contains(Player) then return end
            self:SpawnPlayer(Player)
        end)

        --Set the tools.
        if self.PlayerStarterTools[Player] then
            self:SetTools(Player,self.PlayerStarterTools[Player])
        end
    end)()
end

--[[
Despawns a player.
--]]
function BaseRound:DespawnPlayer(Player)
    if not Player or not Player.Parent or not self.Players:Contains(Player) then return end
    if not Player.Character then return end
    self:GetService("CharacterService"):DespawnCharacter(Player)
end

--[[
Sets the tools on spawn for a player.
--]]
function BaseRound:SetStarterTools(Player,PlayerTools)
    if not Player or not Player.Parent or not self.Players:Contains(Player) then return end
    self.PlayerStarterTools[Player] = PlayerTools
end

--[[
Sets the tools for a player.
--]]
function BaseRound:SetTools(Player,PlayerTools)
    --Get the character and backpack.
    local Character = Player.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    local Backpack = Player:FindFirstChild("Backpack")
    if not Backpack then return end

    --Convert the tools to a map.
    local PlayerToolsMap = {}
    for _,ToolName in pairs(PlayerTools) do
        PlayerToolsMap[ToolName] = true
    end

    --Add the new tools.
    local Tools = ServerStorage:WaitForChild("Tools")
    for _,ToolName in pairs(PlayerTools) do
        if not Backpack:FindFirstChild(ToolName) and not Character:FindFirstChild(ToolName) then
            Tools:WaitForChild(ToolName):Clone().Parent = Backpack
        end
    end

    --Remove the old tools.
    for _,Tool in pairs(Backpack:GetChildren()) do
        if not PlayerToolsMap[Tool.Name] then
            Tool:Destroy()
        end
    end
    local EquippedTool = Character:FindFirstChildOfClass("Tool")
    if EquippedTool and not PlayerToolsMap[EquippedTool.Name] then
        Humanoid:UnequipTools()
        EquippedTool:Destroy()
    end
end

--[[
Removes a player currently in the round,
such as when the round ends.
--]]
function BaseRound:RemoveCurrentPlayer(Player)
    if self.Players:Contains(Player) then
        self.Players:Remove(Player)
        self:GetService("StatService"):ClearTemporaryStats(Player)
    end
end

--[[
Awards the rank score to the given player.
--]]
function BaseRound:AddRankScore(Player)
    --Load the bonuses class.
    if not RankScoreBonuses then
        local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
        RankScoreBonuses = ReplicatedStorageProject:GetResource("State.RankScoreBonuses")
    end

    --Calculate the bonuses.
    local Multiplier = 1
    for _,Bonus in pairs(RankScoreBonuses(Player)) do
        Multiplier = Multiplier + Bonus.Multiplier
    end

    --Add the rank bonuses.
    local StatService = self:GetService("StatService")
    local PlayerTemproaryStats = StatService:GetTemporaryStats(Player)
    local PlayerPersistentStats = StatService:GetPersistentStats(Player)
    local KOs = PlayerTemproaryStats:Get("KOs"):Get()
    if KOs > 0 then
        PlayerPersistentStats:Get("RankScore"):Increment(KOs * Multiplier)
    end
end

--[[
Eliminates a player from the existing round
and makes them a spectator.
--]]
function BaseRound:EliminatePlayer(Player)
    if self.Players:Contains(Player) and not self.Spectators:Contains(Player) and self.State ~= "ENDED" then
        --Despawn the player.
        self:DespawnPlayer(Player)
        self:AddRankScore(Player)

        --Store the temporary stats.
        local PlayerData = {
            Player = Player,
            Stats = {},
        }
        if not Player.Neutral then
            PlayerData.TeamColor = Player.TeamColor
        end
        local TemporaryStats = self:GetService("StatService"):GetTemporaryStats(Player)
        for _,RoundStat in pairs(self.RoundStats) do
            PlayerData.Stats[RoundStat.Name] = TemporaryStats:Get(RoundStat.Name):Get()
        end
        self.EliminatedPlayerStats:Add(PlayerData)

        --Add the spectator and remove the player from the round.
        self.Spectators:Add(Player)
        self:RemoveCurrentPlayer(Player)
    end
end

--[[
Broadcasts a local effect to all the
players of the round.
--]]
function BaseRound:BroadcastLocalEffect(...)
    local LocalEffectService = self:GetService("LocalEffectService")
    for _,Player in pairs(self.Players:GetAll()) do
        LocalEffectService:PlayLocalEffect(Player,...)
    end
    for _,Player in pairs(self.Spectators:GetAll()) do
        LocalEffectService:PlayLocalEffect(Player,...)
    end
end

--[[
Disposes of the object.
--]]
function BaseRound:Dispose()
    self.super:Dispose()

    --Destroy the objects.
    self.Players:Destroy()
    self.Spectators:Destroy()
    self.EliminatedPlayerStats:Destroy()
    self.Timer:Destroy()
end



return BaseRound