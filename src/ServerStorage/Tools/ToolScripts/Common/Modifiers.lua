--[[
TheNexusAvenger

Centralizes applying character modifiers.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))
local ModifierService = ServerScriptServiceProject:GetResource("Service.ModifierService")

local Modifiers = {}
Modifiers.PlayerKeys = {}



--[[
Returns the player of the tool.
--]]
local function GetToolCharacter()
    --Get the character.
    local Character = script.Parent.Parent
    if not Character then return end

    --Return the player.
    local Player = Players:GetPlayerFromCharacter(Character)
    return Player
end



--[[
Adds a modifier to the character.
--]]
function Modifiers:Add(Key,Type,Value)
    --Get the player.
    local Player = GetToolCharacter()
    if not Player then return end

    --Remove the key if one exists.
    if self.PlayerKeys[Key] then
        ModifierService:GetModifiers(self.PlayerKeys[Key]):Remove(Key)
    end

    --Add the key.
    local CharacterModifiers = ModifierService:GetModifiers(Player)
    if not CharacterModifiers then return end
    self.PlayerKeys[Key] = Player
    CharacterModifiers:Add(Key,Type,Value)
end

--[[
Removes a modifier from the character.
--]]
function Modifiers:Remove(Key)
    if self.PlayerKeys[Key] then
        local Player = self.PlayerKeys[Key]
        self.PlayerKeys[Key] = nil
        local CharacterModifiers = ModifierService:GetModifiers(Player)
        if not CharacterModifiers then return end
        CharacterModifiers:Remove(Key)
    end
end



return Modifiers
