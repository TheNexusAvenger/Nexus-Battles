--[[
TheNexusAvenger

Loads the game commands.
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusAdminAPI = require(ServerScriptService:WaitForChild("NexusAdmin"))
local Commands = ReplicatedStorage:WaitForChild("NexusAdmin"):WaitForChild("Commands"):WaitForChild("Server")



--Loads the commands.
for _,Module in pairs(Commands:GetChildren()) do
    if Module:IsA("ModuleScript") then
        local CommandData = require(Module)
        CommandData.Prefix = NexusAdminAPI.Configuration.CommandPrefix
        CommandData.Category = "GameCommands"
        CommandData.AdminLevel = 2
        NexusAdminAPI.Registry:LoadCommand(CommandData)
    end
end



--Return true so that it doesn't error.
return true