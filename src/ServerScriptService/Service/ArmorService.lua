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
local MeshDeformationArmorModels = ReplicatedStorageProject:GetResource("Model.MeshDeformationArmorModels")
local ModifierService = ServerScriptServiceProject:GetResource("Service.ModifierService")

local ArmorService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
ArmorService:SetClassName("StatService")
ArmorService.PlayerToCharacter = {}
ArmorService.CharacterArmor = {}

local IdToType = {}
for Name,ItemData in pairs(ArmorData) do
    IdToType[ItemData.Id] = Name
end



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
    ArmorType = IdToType[ArmorType] or ArmorType

    --Get the character armor data.
    local CharacterData = GetCharacterAmorData(Player)
    if not CharacterData then return end

    --Get the data for the armor.
    local ArmorTypeData = ArmorData[ArmorType]
    if not ArmorTypeData then return end
    local Slot = ArmorTypeData.Slot
    if not Slot then return end

    --Return if the slot didn't change.
    if CharacterData[Slot] and CharacterData[Slot].Type == ArmorType then
        return
    end

    --Unequip the armor in the existing slot.
    self:Unequip(Player,Slot)

    --Determine if the character uses the mesh deformation rig.
    local IsMeshDeformation = false
    local IsMeshDeformationValue = Player.Character:FindFirstChild("IsMeshDeformation")
    if IsMeshDeformationValue then
        IsMeshDeformation = IsMeshDeformationValue.Value
    end

    --Add the armor model to the player.
    local EquippedArmorData = {
        Type = ArmorType,
        Parts = {},
        ModifierKeys = {},
    }
    CharacterData[Slot] = EquippedArmorData
    local ArmorModel = (IsMeshDeformation and MeshDeformationArmorModels or ArmorModels):WaitForChild(ArmorType):Clone()
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