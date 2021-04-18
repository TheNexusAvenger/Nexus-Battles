--[[
TheNexusAvenger

Static class for managing rounds.
--]]

local DEFAULT_LOBBY_RESPAWN_DELAY = 3
local MAP_POSITION_MULTIPLIER = 1000



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local ObjectReplicator = NexusRoundSystem:GetObjectReplicator()
local Maps = ServerStorage:WaitForChild("Maps")
local CharacterService = ServerScriptServiceProject:GetResource("Service.CharacterService")
local Tools = ServerStorage:WaitForChild("Tools")
local BaseTools = Tools:WaitForChild("BaseTools")
local ToolScripts = Tools:WaitForChild("ToolScripts")

local RoundService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
RoundService:SetClassName("RoundService")
RoundService.AllocatedPositions = {}



--Set up the replicaiton.
local RoundReplication = Instance.new("Folder")
RoundReplication.Name = "Round"
RoundReplication.Parent = ReplicatedStorageProject:GetResource("Replication")

local LeaveRound = Instance.new("RemoteEvent")
LeaveRound.Name = "LeaveRound"
LeaveRound.Parent = RoundReplication

local JoinTeam = Instance.new("RemoteEvent")
JoinTeam.Name = "JoinTeam"
JoinTeam.Parent = RoundReplication

local ActiveRounds = ObjectReplicator:CreateObject("ReplicatedContainer")
ActiveRounds.Name = "ActiveRounds"
ActiveRounds.Parent = ObjectReplicator:GetGlobalContainer()

--Set up the map containers and physics groups so only the player's map is visible.
local ActiveMaps = Instance.new("Folder")
ActiveMaps.Name = "ActiveMaps"
ActiveMaps.Parent = Workspace

local ActiveHiddenMaps = Instance.new("Folder")
ActiveHiddenMaps.Name = "ActiveHiddenMaps"
ActiveHiddenMaps.Parent = ReplicatedStorage

PhysicsService:CreateCollisionGroup("SameRoundPlayers")
PhysicsService:CreateCollisionGroup("OtherRoundPlayers")
PhysicsService:CollisionGroupSetCollidable("SameRoundPlayers","OtherRoundPlayers",false)



--[[
Sets up a player.
--]]
local function InitializePlayer(Player)
    --Connect the characters being added.
    Player.CharacterAdded:Connect(function(Character)
        --Return if the player is in a round.
        for _,Round in pairs(ActiveRounds:GetChildren()) do
            if Round.Players:Contains(Player) then
                return
            end
        end

        --Connect the character dieing.
        local Humanoid = Character:WaitForChild("Humanoid")
        Humanoid.Died:Connect(function()
            wait(DEFAULT_LOBBY_RESPAWN_DELAY)

            --Respawn the player if they aren't in a round.
            for _,Round in pairs(ActiveRounds:GetChildren()) do
                if Round.Players:Contains(Player) then
                    return
                end
            end
            CharacterService:SpawnCharacter(Player)
        end)
    end)

    --Load thee character.
    CharacterService:SpawnCharacter(Player)
end

--[[
Initializes a container for the round.
This allows the client to hide it before
creating the map. If the map isn't
under Workspace on the server, no explosions
are functional.
--]]
local function AllocateRoundContainer()
    local RoundContainer = Instance.new("Folder")
    RoundContainer.Name = "UnallocatedRoundContainer"
    RoundContainer.Parent = ActiveMaps
end
AllocateRoundContainer()

--[[
Returns a folder to use for a round.
--]]
local function GetAllocatedRoundContainer()
    local Folder = ActiveMaps:WaitForChild("UnallocatedRoundContainer")
    AllocateRoundContainer()
    return Folder
end



--[[
Starts a round.
--]]
function RoundService:StartRound(RoundType,MapType,Players)
    --Despawn the players.
    for _,Player in pairs(Players) do
        if Player.Character then
            CharacterService:DespawnCharacter(Player)
        end
    end

    --Allocate a position.
    local AllocatedPosition = 1
    while self.AllocatedPositions[AllocatedPosition] do
        AllocatedPosition = AllocatedPosition + 1
    end
    self.AllocatedPositions[AllocatedPosition] = true

    --Load the map.
    local RoundContainer = GetAllocatedRoundContainer()
    local Map = Maps:WaitForChild(MapType):Clone()
    Map.Name = "Map"
    Map:TranslateBy(Vector3.new(0,0,AllocatedPosition * MAP_POSITION_MULTIPLIER))
    Map.Parent = RoundContainer

    --Load the round.
    local Round = ObjectReplicator:CreateObject(RoundType)
    Round.RoundContainer = RoundContainer
    Round.Map = Map
    Round.Parent = ActiveRounds
    RoundContainer.Name = tostring(Round.Id)

    --Start the round.
    coroutine.wrap(function()
        Round:Start(Players)
    end)()

    --Connect clearing when all players leave the round.
    Round.Players.ItemRemoved:Connect(function()
        if #Round.Players:GetAll() == 0 then
            --Clear the map and map.
            RoundContainer:Destroy()
            Round:Destroy()

            --De-allocate the position.
            self.AllocatedPositions[AllocatedPosition] = nil
        end
    end)
end

--[[
Returns the players in the round of the
reference player. Returns an empty list
if the player is not in a round.
--]]
function RoundService:GetPlayersInRound(ReferencePlayer)
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(ReferencePlayer) then
            return Round.Players:GetAll()
        end
    end
    return {}
end

--[[
Returns the round container of the reference player.
--]]
function RoundService:GetPlayerRoundContainer(ReferencePlayer)
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(ReferencePlayer) then
            return Round.RoundContainer
        end
    end
end




--Connect the remote events.
LeaveRound.OnServerEvent:Connect(function(Player)
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(Player) then
            --Remove the player.
            Round:RemoveCurrentPlayer(Player)

            --Remove the player team.
            Player.Team = nil
            Player.Neutral = true

            --Respawn the player.
            CharacterService:SpawnCharacter(Player)
            break
        end
    end
end)

--Connect players being added.
Players.PlayerAdded:Connect(InitializePlayer)
for _,Player in pairs(Players:GetPlayers()) do
    coroutine.wrap(function()
        InitializePlayer(Player)
    end)()
end

--Package the tools.
for _,Tool in pairs(BaseTools:GetChildren()) do
    --Copy the common scripts.
    for _,Script in pairs(ToolScripts:WaitForChild("Common"):GetChildren()) do
        Script:Clone().Parent = Tool
    end

    --Copy the tool scripts.
    local ToolSpecificScripts = ToolScripts:FindFirstChild(Tool.Name)
    if ToolSpecificScripts then
        for _,Script in pairs(ToolSpecificScripts:GetChildren()) do
            Script:Clone().Parent = Tool
        end
    end

    --Move the tool.
    Tool.Parent = Tools
end
BaseTools:Destroy()
ToolScripts:Destroy()



return RoundService