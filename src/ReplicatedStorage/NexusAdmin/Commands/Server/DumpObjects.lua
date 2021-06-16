--[[
TheNexusAvenger

Data for a command for displaying the replicated
objects on the server.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusReplication = ReplicatedStorageProject:GetResource("External.NexusReplication")
local ObjectReplicator = NexusReplication:GetObjectReplicator()



--[[
Dumps an object's information.
--]]
local function DumpObject(Object)
    --Output the name.
    print("|    Object "..tostring(Object.Id).." ("..tostring(Object.Type)..")")

    --Output the properties.
    for PropertyName,PropertyType in pairs(Object.SerializedProperties) do
        local Value = Object[PropertyName]
        if PropertyType == "ObjectReference" then
            if not Value then
                print("|        "..tostring(PropertyName).." (ObjectReference): nil")
            else
                local Id = Value.Id
                if ObjectReplicator.ObjectRegistry[Id] then
                    print("|        "..tostring(PropertyName).." (ObjectReference): "..tostring(Id))
                elseif ObjectReplicator.DisposeObjectRegistry[Id] then
                    warn("|        "..tostring(PropertyName).." (ObjectReference): "..tostring(Id).." (Disposed but not garbage collected)")
                else
                    warn("|        "..tostring(PropertyName).." (ObjectReference): "..tostring(Id).." (Garbage collected)")
                end
            end
        elseif PropertyType == "ObjectTableReference" then
            if not Value then
                print("|        "..tostring(PropertyName).." (ObjectTableReference): nil")
            else
                print("|        "..tostring(PropertyName).." (ObjectTableReference):")
                for Index,SubObject in pairs(Value) do
                    local Id = SubObject.Id
                    if ObjectReplicator.ObjectRegistry[Id] then
                        print("|            "..tostring(Index)..": "..tostring(Id))
                    elseif ObjectReplicator.DisposeObjectRegistry[Id] then
                        warn("|            "..tostring(Index)..": "..tostring(Id).." (Disposed but not garbage collected)")
                    else
                        warn("|            "..tostring(Index)..": "..tostring(Id).." (Garbage collected)")
                    end
                end
            end
        else
            print("|        "..tostring(PropertyName).." ("..tostring(PropertyType).."): "..tostring(Value or "nil"))
        end
    end
end

--[[
Dumps a table of objects.
--]]
local function DumpObjectTable(Objects)
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
        DumpObject(Object)
    end
end



--Return the command data.
return {
    Keyword = "dumpobjects",
    Description = "Dumps the replicated objects of Nexus Round System in the server output.",
    Run = function(self,CommandContext)
        --Dump the main objects.
        print("OBJECT DUMP")
        print("|  Object Registry (kept until manually destroyed):")
        DumpObjectTable(ObjectReplicator.ObjectRegistry)

        --Dump the disposed objects.
        local DisposedObjectsExist = false
        for _,_ in pairs(ObjectReplicator.DisposeObjectRegistry) do
            DisposedObjectsExist = true
            break
        end
        if DisposedObjectsExist then
            warn("|  Disposed Object Registry (kept until de-referenced):")
            DumpObjectTable(ObjectReplicator.DisposeObjectRegistry)
        end

        --Return the generic response.
        return "Objects dumped in the server output."
    end
}