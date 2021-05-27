--[[
TheNexusAvenger

Manages armor for players.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local ArmorData = ReplicatedStorageProject:GetResource("Data.Armor")
local ArmorModels = ReplicatedStorageProject:GetResource("Model.ArmorModels")
local ModifierService = ServerScriptServiceProject:GetResource("Service.ModifierService")

local ArmorService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
ArmorService:SetClassName("StatService")
ArmorService.PlayerToCharacter = {}
ArmorService.CharacterArmor = {}



--[[
Returns the armor data store for the given player.
--]]
local function GetCharacterAmorData(Player)
    --Clear the old data if the player has a different character.
    local NewCharacter = Player.Character
    if not NewCharacter then return end
    local OldCharacter = ArmorService.PlayerToCharacter[Player]
    if OldCharacter and OldCharacter ~= NewCharacter then
        ArmorService.CharacterArmor[OldCharacter] = nil
    end

    --Add the new data if none exists.
    if not ArmorService.CharacterArmor[NewCharacter] then
        ArmorService.CharacterArmor[NewCharacter] = {}
    end

    --Return the data.
    return ArmorService.CharacterArmor[NewCharacter]
end



--[[
Equips an armor item of a given type.
--]]
function ArmorService:Equip(Player,ArmorType)
    --Get the character armor data.
    local CharacterData = GetCharacterAmorData(Player)
    if not CharacterData then return end

    --Get the data for the armor.
    local ArmorTypeData = ArmorData[ArmorType]
    if not ArmorTypeData then return end
    local Slot = ArmorTypeData.Slot
    if not Slot then return end

    --Unequip the armor in the existing slot.
    self:Unequip(Player,Slot)

    --Add the armor model to the player.
    local EquippedArmorData = {
        Parts = {},
        ModifierKeys = {},
    }
    CharacterData[Slot] = EquippedArmorData
    local ArmorModel = ArmorModels:WaitForChild(ArmorType):Clone()
    for _,CharacterPart in pairs(Player.Character:GetChildren()) do
        if CharacterPart:IsA("BasePart") then
            local ArmorBasePart = ArmorModel:FindFirstChild(CharacterPart.Name)
            if ArmorBasePart then
                for _,Weld in pairs(ArmorBasePart:GetChildren()) do
                    if Weld:IsA("JointInstance") then
                        --Weld the armor part to the character.
                        if Weld.Part1 == ArmorBasePart then
                            Weld.Part0,Weld.Part1 = Weld.Part1,Weld.Part0
                        end
                        if Weld.Part1 then
                            Weld.Part0 = CharacterPart
                            Weld.Part1.Parent = CharacterPart
                            Weld.Parent = Weld.Part1
                            table.insert(EquippedArmorData.Parts,Weld.Part1)
                        end
                    end
                end
            end
        end
    end

    --Add the armor modifiers.
    if ArmorTypeData.Modifiers then
        local Modifiers = ModifierService:GetModifiers(Player)
        if Modifiers then
            for Type,Value in pairs(ArmorTypeData.Modifiers) do
                local Key = Slot.."_"..Type
                Modifiers:Add(Key,Type,Value)
                table.insert(EquippedArmorData.ModifierKeys,Key)
            end
        end
    end
end

--[[
Unequips the armor of the given slot.
--]]
function ArmorService:Unequip(Player,Slot)
    --Get the character armor data.
    local CharacterData = GetCharacterAmorData(Player)
    if not CharacterData then return end

    --Remove the armor parts.
    local ExistingArmor = CharacterData[Slot]
    if not ExistingArmor then return end
    CharacterData[Slot] = nil
    for _,Part in pairs(ExistingArmor.Parts) do
        Part:Destroy()
    end

    --Remove the modifiers.
    if #ExistingArmor.ModifierKeys > 0 then
        local Modifiers = ModifierService:GetModifiers(Player)
        if Modifiers then
            for _,Key in pairs(ExistingArmor.ModifierKeys) do
                Modifiers:Remove(Key)
            end
        end
    end
end


--[[
Returns the modifiers for the given player.
--]]
--[[
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
end]]



--Connect players leaving.
Players.PlayerRemoving:Connect(function(Player)
    local Character = ArmorService.PlayerToCharacter[Player]
    if Character then
        ArmorService.CharacterArmor[Character]:Destroy()
        ArmorService.CharacterArmor[Character] = nil
        ArmorService.PlayerToCharacter[Player] = nil
    end
end)



return ArmorService