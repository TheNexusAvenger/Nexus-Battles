--[[
TheNexusAvenger

Manages the inventory for the player.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local NexusEventCreator = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEventCreator")

local Inventory = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
Inventory:SetClassName("Inventory")



--[[
Returns the armor data for the given id.
--]]
local function GetArmorData(Id)
    for _,ArmorData in pairs(Armor) do
        if Id == ArmorData.Id then
            return ArmorData
        end
    end
end



--[[
Creates the inventory.
--]]
function Inventory:__new(InventoryStringValue)
    self:InitializeSuper()

    --Create the container.
    self.InventoryChanged = NexusEventCreator:CreateEvent()
    self.InventoryStringValue = InventoryStringValue
    self.LastInventoryString = InventoryStringValue.Value
    self:Reload()

    --Connect the inventory value changing.
    self.Events = {}
    table.insert(self.Events,InventoryStringValue.Changed:Connect(function()
        self:Reload()
    end))
end

--[[
Reloads the inventory from the string value.
--]]
function Inventory:Reload()
    self.Inventory = HttpService:JSONDecode(self.InventoryStringValue.Value)
    if self.InventoryStringValue.Value ~= self.LastInventoryString  then
        self.LastInventoryString = self.InventoryStringValue.Value
        self.InventoryChanged:Fire()
    end
end

--[[
Saves the inventory.
--]]
function Inventory:Save()
    self.LastInventoryString = HttpService:JSONEncode(self.Inventory)
    self.InventoryStringValue.Value = self.LastInventoryString
    self.InventoryChanged:Fire()
end

--[[
Returns the inventory item for the given slot.
--]]
function Inventory:GetItemAtSlot(Slot)
    for _,Item in pairs(self.Inventory) do
        if Item.Slot == Slot then
            return Item
        end
    end
end

--[[
Returns the next open slot.
--]]
function Inventory:GetNextSlot()
    local Slot = 1
    while self:GetItemAtSlot(Slot) do
        Slot = Slot + 1
    end
    return Slot
end

--[[
Returns if an item at a given slot can
be moved to a given slot.
--]]
function Inventory:CanMoveToSlot(InitialSlot,NewSlot)
    --Return true if there is no item.
    local Item = self:GetItemAtSlot(InitialSlot)
    if not Item then
        return true
    end

    --Return if the new slot is a valid number.
    if typeof(NewSlot) == "number" then
        return NewSlot > 0 and math.floor(NewSlot) == NewSlot
    end

    --Return based on the armor data of the id.
    local ArmorData = GetArmorData(Item.Id)
    return (ArmorData ~= nil and ArmorData.Slot == NewSlot)
end

--[[
Adds an item to the inventory.
--]]
function Inventory:AddItem(Id)
    local ArmorData = GetArmorData(Id)
    if ArmorData then
        local Slot = self:GetNextSlot()
        table.insert(self.Inventory,{
            Id = Id,
            Slot = Slot,
            Health = ArmorData.MaxHealth,
        })
        self:Save()
        return Slot
    end
end

--[[
Removes an item from the inventory.
--]]
function Inventory:RemoveItem(Slot)
    --Get the index to remove.
    local IndexToRemove
    for i,Item in pairs(self.Inventory) do
        if Item.Slot == Slot then
            IndexToRemove = i
            break
        end
    end

    --Remove the index.
    if IndexToRemove then
        table.remove(self.Inventory,IndexToRemove)
        self:Save()
    end
end

--[[
Damages an item at a given slot.
--]]
function Inventory:DamageItem(Slot,Damage)
    Damage = math.max(0,Damage)
    if Damage == 0 then return end

    --Get the item.
    local Item = self:GetItemAtSlot(Slot)
    if not Item or not Item.Health then return end

    --Damage the item and remove it if the health is below 0.
    Item.Health = Item.Health - Damage
    if Item.Health > 0 then
        self:Save()
    else
        self:RemoveItem(Slot)
    end
end

--[[
Swaps two slots in the inventory.
--]]
function Inventory:SwapItems(Slot1,Slot2)
    --Return if the slots can't be swapped.
    if not self:CanMoveToSlot(Slot1,Slot2) or not self:CanMoveToSlot(Slot2,Slot1) then
        return
    end

    --Swap the items.
    local Item1,Item2 = self:GetItemAtSlot(Slot1),self:GetItemAtSlot(Slot2)
    if not Item1 and not Item2 then return end
    if Item1 then
        Item1.Slot = Slot2
    end
    if Item2 then
        Item2.Slot = Slot1
    end
    self:Save()
end

--[[
Destroys the inventory.
--]]
function Inventory:Destroy()
    for _,Connection in pairs(self.Events) do
        Connection:Disconnect()
    end
    self.Events = {}
end



return Inventory