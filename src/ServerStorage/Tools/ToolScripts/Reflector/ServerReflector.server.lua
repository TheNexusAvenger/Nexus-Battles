--[[
TheNexusAvenger

Runs the server-side reflector.
--]]

local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local ProjectileReflector = require(Tool:WaitForChild("ProjectileReflector"))

local ActivateReflectorEvent = RemoteEventCreator:CreateRemoteEvent("ActivateReflector")

local CurrentPlayer,CurrentCharacter
local Equipped = false
local ToolEnabled = true

--[[
Activates the reflector.
--]]
local function ActivateWeapon()
    if ToolEnabled then
        ToolEnabled = false
        Tool.Enabled = false

        spawn(function()
            ProjectileReflector:ReflectProjectiles(Handle)
        end)
        wait(2)

        ToolEnabled = true
        Tool.Enabled = true
    end
end



--Set up the activate event.
ActivateReflectorEvent.OnServerEvent:Connect(function(Player)
    if Player == CurrentPlayer then
        ActivateWeapon()
    end
end)

--Set up equip and unequip events.
Tool.Equipped:Connect(function()
    if not Equipped then
        Equipped = true

        --Set the current player.
        CurrentCharacter = Tool.Parent
        CurrentPlayer = Players:GetPlayerFromCharacter(CurrentCharacter)

        --Activate the weapon on equipped if possible.
        if ToolEnabled then
            ActivateWeapon()
        end
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Reset the current player.
        CurrentCharacter = nil
        CurrentPlayer = nil
    end
end)