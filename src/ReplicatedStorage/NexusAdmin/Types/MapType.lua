--[[
TheNexusAvenger

Enum type for a map type.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))




return function(NexusAdminAPI)
    --Compile the list of round types.
    local MapTypes = {}
	for MapType,_ in pairs(ReplicatedStorageProject:GetResource("Data.MapTypes")) do
        table.insert(MapTypes,MapType)
    end

    --Create the item type.
    local MapType = {
        --[[
        Transforms the string to a list of items.
        --]]
        Transform = function(Text,Executor)
            return NexusAdminAPI.Cmdr.Util.MakeFuzzyFinder(MapTypes)(Text)
        end,

        --[[
        Returns if the input is valid and an error message
        for when it is invalid.
        --]]
        Validate = function(Items)
            return #Items > 0,"No round types were found matching that query."
        end,

        --[[
        Returns the results for auto completing.
        --]]
        Autocomplete = function(Items)
            return Items
        end,

        --[[
        Returns the value to use.
        --]]
        Parse = function(Items)
            return Items[1]
        end,
    }

    --Register the types.
    NexusAdminAPI.Cmdr.Registry:RegisterType("mapType",MapType)
end