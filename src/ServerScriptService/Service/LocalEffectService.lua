--[[
TheNexusAvenger

Performs local effects for players.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local RoundService = ServerScriptServiceProject:GetResource("Service.RoundService")

local LocalEffectService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
LocalEffectService:SetClassName("LocalEffectService")



--Set up the replicaiton.
local LocalEffectReplication = Instance.new("Folder")
LocalEffectReplication.Name = "LocalEffect"
LocalEffectReplication.Parent = ReplicatedStorageProject:GetResource("Replication")

local PlayLocalEffect = Instance.new("RemoteEvent")
PlayLocalEffect.Name = "PlayLocalEffect"
PlayLocalEffect.Parent = LocalEffectReplication



--[[
Plays a local effect for a player.
--]]
function LocalEffectService:PlayLocalEffect(Player,Name,...)
    PlayLocalEffect:FireClient(Player,Name,...)
end

--[[
Plays a local effect for all players in the
zone of the given player.
--]]
function LocalEffectService:BroadcastLocalEffect(ReferencePlayer,Name,...)
    for _,Player in pairs(RoundService:GetPlayersInRound(ReferencePlayer)) do
        self:PlayLocalEffect(Player,Name,...)
    end
end



return LocalEffectService