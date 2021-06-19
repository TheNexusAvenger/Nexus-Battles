--[[
TheNexusAvenger

Loads types and commands on the client for Nexus Admin.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusAdminAPI = require(ReplicatedStorage:WaitForChild("NexusAdminClient"))
local NexusAdminTypes = ReplicatedStorage:WaitForChild("NexusAdmin"):WaitForChild("Types")
local NexusAdminCommands = ReplicatedStorage:WaitForChild("NexusAdmin"):WaitForChild("Commands"):WaitForChild("Client")



--[[
Loads a type.
--]]
local function LoadType(Module)
    if Module:IsA("ModuleScript") then
        require(Module)(NexusAdminAPI)
    end
end

--[[
Loads a command.
--]]
local function LoadCommand(Module)
    if Module:IsA("ModuleScript") then
        local CommandData = require(Module)
        CommandData.Prefix = NexusAdminAPI.Configuration.CommandPrefix
        CommandData.Category = "GameCommands"
        CommandData.AdminLevel = 2
        NexusAdminAPI.Registry:LoadCommand(CommandData)
    end
end



--Load the types.
NexusAdminTypes.ChildAdded:Connect(LoadType)
for _,Module in pairs(NexusAdminTypes:GetChildren()) do
    LoadType(Module)
end

--Load the commands.
NexusAdminCommands.ChildAdded:Connect(LoadType)
for _,Module in pairs(NexusAdminCommands:GetChildren()) do
    LoadCommand(Module)
end