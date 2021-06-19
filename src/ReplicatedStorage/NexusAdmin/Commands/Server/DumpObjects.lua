--[[
TheNexusAvenger

Data for a command for displaying the replicated objects.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusAdmin = require(ServerScriptService:WaitForChild("NexusAdmin"))
local NexusReplication = ReplicatedStorageProject:GetResource("External.NexusReplication")
local ObjectReplicator = NexusReplication:GetObjectReplicator()



--[[
Dumps an object's information.
--]]
local function DumpObject(Object,AddPrint,AddWarning,AddIgnore)
    --Output the name.
    AddPrint("     Object "..tostring(Object.Id).." ("..tostring(Object.Type)..")")

    --Output the properties.
    for _,PropertyName in pairs(Object.SerializedProperties) do
        local Value = Object[PropertyName]
        if typeof(Value) == "table" and Value.Id and Value.IsA and Value:IsA("ReplicatedContainer") then
            local Id = Value.Id
            if ObjectReplicator.ObjectRegistry[Id] then
                AddPrint("         "..tostring(PropertyName).." (ReplicatedContainer): "..tostring(Id))
            elseif ObjectReplicator.DisposeObjectRegistry[Id] then
                AddWarning("         "..tostring(PropertyName).." (ReplicatedContainer): "..tostring(Id).." (Disposed but not garbage collected)")
            else
                AddWarning("         "..tostring(PropertyName).." (ReplicatedContainer): "..tostring(Id).." (Garbage collected)")
            end
        else
            if typeof(Value) == "table" then
                AddPrint("         "..tostring(PropertyName).." (Table):")
                for Index,SubObject in pairs(Value) do
                    if typeof(SubObject) == "table" and SubObject.Id and SubObject.IsA and SubObject:IsA("ReplicatedContainer") then
                        local Id = SubObject.Id
                        if ObjectReplicator.ObjectRegistry[Id] then
                            AddPrint("           "..tostring(Index).." (ReplicatedContainer): "..tostring(Id))
                        elseif ObjectReplicator.DisposeObjectRegistry[Id] then
                            AddWarning("           "..tostring(Index).." (ReplicatedContainer): "..tostring(Id).." (Disposed but not garbage collected)")
                        else
                            AddWarning("           "..tostring(Index).." (ReplicatedContainer): "..tostring(Id).." (Garbage collected)")
                        end
                    else
                        AddIgnore("           "..tostring(Index).." (Other): "..tostring(SubObject or "nil"))
                    end
                end
            else
                AddIgnore("         "..tostring(PropertyName).." (Other): "..tostring(Value or "nil"))
            end
        end
    end
end

--[[
Dumps a table of objects.
--]]
local function DumpObjectTable(Objects,AddPrint,AddWarning,AddIgnore)
    --Sort the objects by id.
    local SortedObjects = {}
    for _,Object in pairs(Objects) do
        table.insert(SortedObjects,Object)
    end
    table.sort(SortedObjects,function(a,b)
        return a.Id < b.Id
    end)

    --Dump the objects.
    for _,Object in pairs(SortedObjects) do
        DumpObject(Object,AddPrint,AddWarning,AddIgnore)
    end
end



--Set up the replication.
local GetObjectDump = Instance.new("RemoteFunction")
GetObjectDump.Name = "GetObjectDump"
GetObjectDump.Parent = ReplicatedStorage:WaitForChild("Replication")

GetObjectDump.OnServerInvoke = function(Player)
    --Return if the player is unauthorized.
    if not NexusAdmin.Authorization:IsPlayerAuthorized(Player,2) then
        return {Text="Unauthorized",Type="Warn"}
    end

    --Build and return the object dump.
    local Lines = {}
    local function AddPrint(Line)
        table.insert(Lines,{Text=Line,Type="Print"})
    end
    local function WarnPrint(Line)
        table.insert(Lines,{Text=Line,Type="Warn"})
    end
    local function AddIgnore(Line)
        table.insert(Lines,{Text=Line,Type="Ignore"})
    end
    AddPrint("OBJECT DUMP")
    AddPrint("   Object Registry (kept until manually destroyed):")
    DumpObjectTable(ObjectReplicator.ObjectRegistry,AddPrint,WarnPrint,AddIgnore)

    --Dump the disposed objects.
    local DisposedObjectsExist = false
    for _,_ in pairs(ObjectReplicator.DisposeObjectRegistry) do
        DisposedObjectsExist = true
        break
    end
    if DisposedObjectsExist then
        WarnPrint("   Disposed Object Registry (kept until de-referenced):")
        DumpObjectTable(ObjectReplicator.DisposeObjectRegistry,AddPrint,WarnPrint,AddIgnore)
    end
    return Lines
end


--Return the command data.
return {
    Keyword = "dumpobjects",
    Description = "Dumps the replicated objects of Nexus Round System in the server output.",
    Run = function(self,CommandContext)

    end
}