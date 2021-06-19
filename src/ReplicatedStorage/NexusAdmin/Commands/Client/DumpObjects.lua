--[[
TheNexusAvenger

Data for a command for displaying the replicated objects.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScrollingTextWindow = require(ReplicatedStorage:WaitForChild("NexusAdminClient"):WaitForChild("IncludedCommands"):WaitForChild("Resources"):WaitForChild("ScrollingTextWindow"))
local GetObjectDump = ReplicatedStorage:WaitForChild("Replication"):WaitForChild("GetObjectDump")



--Return the command data.
return {
    Keyword = "dumpobjects",
    Description = "Dumps the replicated objects of Nexus Round System in the server output.",
    Run = function(self,CommandContext)
         --Display the text window.
        local Window = ScrollingTextWindow.new()
        Window.Title = "Logs"
        Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
            local Lines = {}
            for _,Line in pairs(GetObjectDump:InvokeServer()) do
                table.insert(Lines,{Text=Line.Text,TextColor3 = ((Line.Type == "Warn" and Color3.new(1,0.6,0)) or (Line.Type == "Ignore" and Color3.new(0.7,0.7,0.7)) or Color3.new(1,1,1))})
            end
            return Lines
        end
        Window:Show()
    end
}