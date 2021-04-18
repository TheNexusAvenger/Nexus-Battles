--[[
TheNexusAvenger

Creates and manages teams.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local TeamService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
TeamService:SetClassName("TeamService")



--[[
Returns the team for the given color. Creates
the team color if it already exists.
--]]
function TeamService:GetTeam(Color)
    --Return if the team color already exists.
    for _,Team in pairs(Teams:GetChildren()) do
        if Team:IsA("Team") and Team.TeamColor == Color then
            return Team
        end
    end

    --Create the team if it doesn't exist.
    local NewTeam = Instance.new("Team")
    NewTeam.Name = tostring(Color).." Team"
    NewTeam.TeamColor = Color
    NewTeam.Parent = Teams
    return NewTeam
end



return TeamService