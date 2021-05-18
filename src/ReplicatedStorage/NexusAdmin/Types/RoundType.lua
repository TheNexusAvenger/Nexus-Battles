--[[
TheNexusAvenger

Enum type for a round type.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))




return function(NexusAdminAPI)
    --Compile the list of round types.
    local RoundTypes = {}
	for RoundName,_ in pairs(ReplicatedStorageProject:GetResource("Data.GameTypes")) do
        table.insert(RoundTypes,RoundName)
    end

    --Create the item type.
    local RoundType = {
        --[[
        Transforms the string to a list of items.
        --]]
        Transform = function(Text,Executor)
            return NexusAdminAPI.Cmdr.Util.MakeFuzzyFinder(RoundTypes)(Text)
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
    NexusAdminAPI.Cmdr.Registry:RegisterType("roundType",RoundType)
end