--[[
TheNexusAvenger

Manages inventories for players.
--]]

local CHARACTER_ARMOR_SLOTS = {
    "Head",
    "Body",
    "Legs",
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local Inventory = ReplicatedStorageProject:GetResource("State.Inventory.Inventory")

local InventoryService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
InventoryService:SetClassName("InventoryService")
InventoryService.PlayerInventories = {}



--[[
Returns the persistent stat container for the player.
--]]
function InventoryService:GetInventory(Player)
    --Create the inventory if it doesn't exist.
    if not InventoryService.PlayerInventories[Player] then
        InventoryService.PlayerInventories[Player] = Inventory.new(Player:WaitForChild("PersistentStats"):WaitForChild("Inventory"))
    end

    --Return the inventory.
    return InventoryService.PlayerInventories[Player]
end

--[[
Awards an armor item to the given player.
Attempts to equip the armor if the slot is empty.
--]]
function InventoryService:AwardItem(Player,Id)
    --Get the armor data.
    local ArmorData = nil
    for _,ArmorItem in pairs(Armor) do
        if ArmorItem.Id == Id and ArmorItem.Cost then
            ArmorData = ArmorItem
            break
        end
    end
    if not ArmorData then return end

    --Add the item and equip it if the player's slot is empty.
    local PlayerInventory = self:GetInventory(Player)
    local Slot = ArmorData.Slot
    local NewSlot = PlayerInventory:AddItem(Id)
    if Slot and PlayerInventory:GetItemAtSlot(Slot) == nil then
        PlayerInventory:SwapItems(Slot,NewSlot)
    end
end

--[[
Damages the equipped armor with the given tag.
--]]
function InventoryService:DamageArmor(Player,Tag,Multiplier)
    Multiplier = Multiplier or 1

    --Damage the armor in the slots.
    local PlayerInventory = self:GetInventory(Player)
    for _,Slot in pairs(CHARACTER_ARMOR_SLOTS) do
        local Item = PlayerInventory:GetItemAtSlot(Slot)
        if Item then
            --Get the item data.
            local ItemData
            for _,ArmorData in pairs(Armor) do
                if ArmorData.Id == Item.Id then
                    ItemData = ArmorData
                    break
                end
            end

            --Damage the armor for the modifiers.
            if ItemData and ItemData.Modifiers then
                local ModifierValue = ItemData.Modifiers[Tag]
                if ModifierValue then
                    PlayerInventory:DamageItem(Slot,ModifierValue * Multiplier)
                end
            end
        end
    end
end



--Connect players leaving.
Players.PlayerRemoving:Connect(function(Player)
    if InventoryService.PlayerInventories[Player] then
        InventoryService.PlayerInventories[Player]:Destroy()
        InventoryService.PlayerInventories[Player] = nil
    end
end)



return InventoryService