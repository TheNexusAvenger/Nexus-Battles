--[[
TheNexusAvenger

Static class for managing rounds.
--]]

local DEFAULT_LOBBY_RESPAWN_DELAY = 3
local MAP_POSITION_MULTIPLIER = -1000
local DEFAULT_MAP_LOBBY_OFFSET = CFrame.new(0,300,-800) * CFrame.Angles(0,math.rad(-185),0)



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local LobbySpawnLocation = Workspace:WaitForChild("Lobby"):WaitForChild("LobbySpawnLocation")
local NexusRoundSystem = ReplicatedStorageProject:GetResource("NexusRoundSystem")
local ObjectReplicator = NexusRoundSystem:GetObjectReplicator()
local MapTypes = ReplicatedStorageProject:GetResource("Data.MapTypes")
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
            CharacterService:SpawnCharacter(Player,LobbySpawnLocation)
        end)
    end)

    --Load the character.
    CharacterService:SpawnCharacter(Player,LobbySpawnLocation)
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

    --Load the round.
    local RoundContainer = GetAllocatedRoundContainer()
    local Round = ObjectReplicator:CreateObject(RoundType)
    Round.RoundContainer = RoundContainer
    RoundContainer.Name = tostring(Round.Id)

    --Load the map.
    local BaseMap = Maps:WaitForChild(MapType)
    local Map
    if BaseMap:IsA("ModuleScript") then
        Map = Instance.new("Model")
        require(BaseMap)(Map,Vector3.new(0,0,AllocatedPosition * MAP_POSITION_MULTIPLIER),Round)
    else
        Map = Maps:WaitForChild(MapType):Clone()
        Map:TranslateBy(Vector3.new(0,0,AllocatedPosition * MAP_POSITION_MULTIPLIER))
    end
    Map.Name = "Map"
    Map.Parent = RoundContainer
    Round.MapName = MapType
    Round.Map = Map
    Round.Parent = ActiveRounds

    --Create the lobby location.
    if MapTypes[MapType].ShowLobby ~= false and not Map:FindFirstChild("LobbyLocation") then
        local LobbyLocationPart = Instance.new("Part")
        LobbyLocationPart.Transparency = 1
        LobbyLocationPart.Name = "LobbyLocation"
        LobbyLocationPart.Size = Vector3.new(1,1,1)
        LobbyLocationPart.CFrame = CFrame.new(0,0,AllocatedPosition * MAP_POSITION_MULTIPLIER) * DEFAULT_MAP_LOBBY_OFFSET
        LobbyLocationPart.Anchored = true
        LobbyLocationPart.CanCollide = false
        LobbyLocationPart.Parent = Map
    end

    --Start the round.
    coroutine.wrap(function()
        Round:Start(Players)
    end)()

    --Connect clearing when all players leave the round.
    for _,Table in pairs({Round.Players,Round.Spectators}) do
        Table.ItemRemoved:Connect(function()
            if #Round.Players:GetAll() == 0 and #Round.Spectators:GetAll() == 0 then
                --Clear the map and map.
                RoundContainer:Destroy()
                Round:Destroy()

                --De-allocate the position.
                self.AllocatedPositions[AllocatedPosition] = nil
            end
        end)
    end
end

--[[
Returns the players in the round of the
reference player. Returns an empty list
if the player is not in a round.
--]]
function RoundService:GetPlayersInRound(ReferencePlayer)
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(ReferencePlayer) then
            local RoundPlayers,RoundPlayersMap = {},{}
            for _,Table in pairs({Round.Players,Round.Spectators}) do
                for _,Player in pairs(Table:GetAll()) do
                    if not RoundPlayersMap[Player] then
                        table.insert(RoundPlayers,Player)
                        RoundPlayersMap[Player] = true
                    end
                end
            end
            return RoundPlayers
        end
    end
    return {}
end

--[[
Returns the round container of the reference player.
--]]
function RoundService:GetPlayerRoundContainer(ReferencePlayer)
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(ReferencePlayer) or Round.Spectators:Contains(ReferencePlayer) then
            return Round.RoundContainer
        end
    end
end

--[[
Starts allowing a player to spectate.
--]]
function RoundService:StartSpectating(Player,RoundId)
    --Return if the round doesn't exist or has ended.
    local Round = ActiveRounds:FindFirstChildBy("Id",RoundId)
    if not Round or Round.State == "ENDED" then
        return
    end

    --Return if the player is in a round or spectating.
    for _,OtherRound in pairs(ActiveRounds:GetChildren()) do
        if OtherRound.Players:Contains(Player) or OtherRound.Spectators:Contains(Player) then
            return
        end
    end

    --Despawn the player.
    CharacterService:StoreCharacterCFramne(Player)
    CharacterService:DespawnCharacter(Player)

    --Add the player to the spectating players.
    Round.Spectators:Add(Player)
end



--Connect the remote events.
LeaveRound.OnServerEvent:Connect(function(Player)
    for _,Round in pairs(ActiveRounds:GetChildren()) do
        if Round.Players:Contains(Player) or Round.Spectators:Contains(Player) then
            --Remove the player.
            Round:RemoveCurrentPlayer(Player)
            Round.Spectators:Remove(Player)

            --Remove the player team.
            Player.Team = nil
            Player.Neutral = true

            --Respawn the player.
            CharacterService:SpawnCharacter(Player,LobbySpawnLocation)
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