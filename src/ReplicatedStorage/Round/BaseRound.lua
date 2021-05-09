--[[
TheNexusAvenger

Base round class used by the game.
--]]

local DEFAULT_ROUND_TIME = 5 * 60
local LOAD_TIME = 5
local DEFAULT_RESPAWN_TIME = 3



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))
local CharacterService
local StatService

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))
local ObjectReplication = NexusRoundSystem:GetObjectReplicator()

local BaseRound = NexusRoundSystem:GetResource("Common.Object.Base.ReplicatedContainer"):Extend()
BaseRound:SetClassName("BaseRound")
BaseRound:AddFromSerializeData("BaseRound")
NexusRoundSystem:GetObjectReplicator():RegisterType("BaseRound",BaseRound)



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
    if NexusRoundSystem:IsServer() then
        self.Players = ObjectReplication:CreateObject("ReplicatedTable")
        self.Timer = ObjectReplication:CreateObject("Timer")
    end
    self:AddToSerialization("State")
    self:AddToSerialization("TimerText")
    self:AddToSerialization("Map")
    self:AddToSerialization("RoundContainer")
    self:AddToSerialization("Players","ObjectReference")
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
    }
    self:GetPropertyChangedSignal("Map"):Connect(function()
        --Get the spawn point models.
        self.SpawnPoints = {
            Normal = {
                CurrentSpawn = 1,
                Parts = {},
            },
            Team = {},
        }
        local SpawnPoints = self.Map:FindFirstChild("SpawnPoints")
        if not SpawnPoints then return end
        local TeamSpawnPoints = SpawnPoints:FindFirstChild("TeamSpawnPoints")

        --Add the base spawn parts.
        for _,Part in pairs(SpawnPoints:GetChildren()) do
            if Part:IsA("BasePart") then
                table.insert(self.SpawnPoints.Normal.Parts,Part)
            end
        end

        --Add the team spawn parts.
        if not TeamSpawnPoints then return end
        for _,Part in pairs(TeamSpawnPoints:GetChildren()) do
            if Part:IsA("BasePart") then
                if not self.SpawnPoints.Team[Part.BrickColor.Name] then
                    self.SpawnPoints.Team[Part.BrickColor.Name] = {
                        CurrentSpawn = 1,
                        Parts = {},
                    }
                end
                table.insert(self.SpawnPoints.Team[Part.BrickColor.Name].Parts,Part)
            end
        end
    end)
end

--[[
Starts the round.
--]]
function BaseRound:Start(RoundPlayers,LoadTimeElapsedCallback)
    --Create the temporary stats.
    self:LoadServices()
    for _,Player in pairs(RoundPlayers) do
        local Stats = StatService:GetTemporaryStats(Player)
        for _,StatData in pairs(self.RoundStats) do
            Stats:Create(StatData.Name,StatData.ValueType,StatData.DefaultValue)
        end
    end

    --Add the players.
    for _,Player in pairs(RoundPlayers) do
        self.Players:Add(Player)
    end
    Players.PlayerRemoving:Connect(function(Player)
        if self.Players:Contains(Player) then
            self.Players:Remove(Player)
        end
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
    --Stop the round.
    self.Timer:Stop()
    self.State = "ENDED"

    --Despawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,false)
        self:DespawnPlayer(Player)
    end
end

--[[
Loads the services if it wasn't done so already.
Can't be loaded the beginning due to a cyclic dependency,
and they can only be loaded on the server.
--]]
function BaseRound:LoadServices()
    if not CharacterService then
        CharacterService = ServerScriptServiceProject:GetResource("Service.CharacterService")
    end
    if not StatService then
        StatService = ServerScriptServiceProject:GetResource("Service.StatService")
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
Spawns a player.
--]]
function BaseRound:SpawnPlayer(Player)
    if not Player or not Player.Parent or not self.Players:Contains(Player) then return end
    coroutine.wrap(function()
        --Get a spawn location part.
        local SpawnParts = (not Player.Neutral and self.SpawnPoints.Team[Player.TeamColor.Name] or self.SpawnPoints.Normal)
        if #SpawnParts.Parts == 0 then return end
        local SpawnPart = SpawnParts.Parts[SpawnParts.CurrentSpawn]
        SpawnParts.CurrentSpawn = (SpawnParts.CurrentSpawn % #SpawnParts.Parts) + 1

        --Teleport the player.
        self:LoadServices()
        local Character = CharacterService:SpawnCharacter(Player)
        CharacterService:AddForceField(Player)
        if not Character then return end
        local Humanoid = Character:WaitForChild("Humanoid")
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        local BaseSpawnCFrame = SpawnPart.CFrame * CFrame.new(SpawnPart.Size.X * (math.random() - 0.5),(SpawnPart.Size.Y/2) + Humanoid.HipHeight + (HumanoidRootPart.Size.Y/2),SpawnPart.Size.Z * (math.random() - 0.5))
        HumanoidRootPart.CFrame = CFrame.new(BaseSpawnCFrame.Position) * CFrame.Angles(0,math.pi + math.atan2(BaseSpawnCFrame.LookVector.X,BaseSpawnCFrame.LookVector.Z),0)

        --Connect the character dieing.
        Humanoid.Died:Connect(function()
            wait(DEFAULT_RESPAWN_TIME)
            if self.DisabledSpawningPlayers[Player] then return end
            if not self.Players:Contains(Player) then return end
            self:SpawnPlayer(Player)
        end)

        --Set the tools.
        self:SetTools(Player,self.PlayerStarterTools[Player] or {})
    end)()
end

--[[
Despawns a player.
--]]
function BaseRound:DespawnPlayer(Player)
    if not Player or not Player.Parent or not self.Players:Contains(Player) then return end
    if not Player.Character then return end
    self:LoadServices()
    CharacterService:DespawnCharacter(Player)
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
        Humanoid:UnequipAllTools()
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
        self:LoadServices()
        StatService:ClearTemporaryStats(Player)
    end
end

--[[
Disposes of the object.
--]]
function BaseRound:Dispose()
    self.super:Dispose()

    --Destroy the objects.
    self.Players:Destroy()
    self.Timer:Destroy()
end



return BaseRound