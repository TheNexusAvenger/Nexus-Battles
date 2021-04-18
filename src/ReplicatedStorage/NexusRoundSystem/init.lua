--[[
TheNexusAvenger

Initializes Nexus Round System.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NexusProject = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusProject"))
local NexusRoundSystem = NexusProject.new(script)
NexusRoundSystem.SingletonInstances = {}
NexusRoundSystem:SetResource("NexusInstance.NexusInstance",require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusInstance"):WaitForChild("NexusInstance")))
NexusRoundSystem:SetResource("NexusInstance.NexusObject",require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusInstance"):WaitForChild("NexusObject")))
NexusRoundSystem:SetResource("NexusInstance.Event.NexusEventCreator",require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEventCreator")))



--Set up the replication.
local NexusRoundSystemReplication
if RunService:IsServer() and not ReplicatedStorage:FindFirstChild("NexusRoundSystemReplication") then
    NexusRoundSystemReplication = Instance.new("Folder")
    NexusRoundSystemReplication.Name = "NexusRoundSystemReplication"
    NexusRoundSystemReplication.Parent = ReplicatedStorage

    local ObjectCreated = Instance.new("RemoteEvent")
    ObjectCreated.Name = "ObjectCreated"
    ObjectCreated.Parent = NexusRoundSystemReplication

    local SendSignal = Instance.new("RemoteEvent")
    SendSignal.Name = "SendSignal"
    SendSignal.Parent = NexusRoundSystemReplication

    local GetObjects = Instance.new("RemoteFunction")
    GetObjects.Name = "GetObjects"
    GetObjects.Parent = NexusRoundSystemReplication

    local GetServerTime = Instance.new("RemoteFunction")
    GetServerTime.Name = "GetServerTime"
    GetServerTime.Parent = NexusRoundSystemReplication

    function GetServerTime.OnServerInvoke()
        return tick()
    end
else
    NexusRoundSystemReplication = ReplicatedStorage:WaitForChild("NexusRoundSystemReplication")
end
NexusRoundSystem:SetResource("NexusRoundSystemReplication",NexusRoundSystemReplication)
NexusRoundSystem:SetResource("NexusRoundSystemReplication.ObjectCreated",NexusRoundSystemReplication:WaitForChild("ObjectCreated"))
NexusRoundSystem:SetResource("NexusRoundSystemReplication.SendSignal",NexusRoundSystemReplication:WaitForChild("SendSignal"))
NexusRoundSystem:SetResource("NexusRoundSystemReplication.GetObjects",NexusRoundSystemReplication:WaitForChild("GetObjects"))
NexusRoundSystem:SetResource("NexusRoundSystemReplication.GetServerTime",NexusRoundSystemReplication:WaitForChild("GetServerTime"))



--[[
Returns if the round system is on the server.
--]]
function NexusRoundSystem:IsServer()
    return RunService:IsServer()
end

--[[
Returns a static instance of a class.
Intended for objects that can only have
1 instance.
--]]
function NexusRoundSystem:GetInstance(Path)
    --Create the singleton instance if non exists.
    if not NexusRoundSystem.SingletonInstances[Path] then
        NexusRoundSystem.SingletonInstances[Path] = NexusRoundSystem:GetResource(Path).new()
    end

    --Return the singleton instance.
    return NexusRoundSystem.SingletonInstances[Path]
end

--[[
Clears the static instances. Only
intended for use at the end of tests.
--]]
function NexusRoundSystem:ClearInstances()
    for _,Ins in pairs(NexusRoundSystem.SingletonInstances) do
        if Ins.Destroy then
            Ins:Destroy()
        end
    end
    NexusRoundSystem.SingletonInstances = {}
    delay(1,function()
        NexusRoundSystemReplication:Destroy()
    end)
end

--[[
Returns the static object replicator.
--]]
function NexusRoundSystem:GetObjectReplicator()
    if self:IsServer() then
        return self:GetInstance("Server.ServerObjectReplication")
    else
        if not NexusRoundSystem.SingletonInstances["Client.ClientObjectReplication"] then
            local ClientObjectReplication = self:GetInstance("Client.ClientObjectReplication")
            ClientObjectReplication:LoadServerObjects()
        end
        return self:GetInstance("Client.ClientObjectReplication")
    end
end



return NexusRoundSystem