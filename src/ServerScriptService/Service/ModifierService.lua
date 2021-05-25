--[[
TheNexusAvenger

Service for managing character modifiers.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CharacterModifiers = ReplicatedStorageProject:GetResource("State.CharacterModifiers")
local Modifiers = ReplicatedStorageProject:GetResource("State.Modifiers")

local ModifierService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
ModifierService:SetClassName("StatService")
ModifierService.PlayerToCharacter = {}
ModifierService.CharacterModifiers = {}



--[[
Returns the modifiers for the given player.
--]]
function ModifierService:GetModifiers(Player)
    --Destroy the old modifiers if the player has a different character.
    local NewCharacter = Player.Character
    if not NewCharacter then return end
    local OldCharacter = self.PlayerToCharacter[Player]
    if OldCharacter and OldCharacter ~= NewCharacter then
        self.CharacterModifiers[OldCharacter]:Destroy()
        self.CharacterModifiers[OldCharacter] = nil
    end

    --Create the new modifiers if they don't exist.
    if not self.CharacterModifiers[NewCharacter] then
        --Create and store the modifiers.
        local NewModifiers = CharacterModifiers.new(NewCharacter)
        self.CharacterModifiers[NewCharacter] = NewModifiers
        self.PlayerToCharacter[Player] = NewCharacter

        --Connect the modifiers changing.
        NewModifiers.ModifierChanged:Connect(function(Name,Value)
            if not NewCharacter.Parent then return end
            local UpdateModule = Modifiers:FindFirstChild(Name)
            if not UpdateModule then return end
            require(UpdateModule)(NewCharacter,Value)
        end)
    end

    --Return the modifiers.
    return self.CharacterModifiers[NewCharacter]
end



--Connect players leaving.
Players.PlayerRemoving:Connect(function(Player)
    local Character = ModifierService.PlayerToCharacter[Player]
    if Character then
        ModifierService.CharacterModifiers[Character]:Destroy()
        ModifierService.CharacterModifiers[Character] = nil
        ModifierService.PlayerToCharacter[Player] = nil
    end
end)



return ModifierService