--[[
TheNexusAvenger

Adds client to server replication to the inventory class.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local SwapItems = ReplicatedStorageProject:GetResource("Replication.Inventory.SwapItems")

local ClientInventory = ReplicatedStorageProject:GetResource("State.Inventory.Inventory"):Extend()
ClientInventory:SetClassName("ClientInventory")



--[[
Creates the client inventory.
--]]
function ClientInventory:__new(InventoryStringValue)
    self:InitializeSuper(InventoryStringValue)
end

--[[
Swaps two slots in the inventory.
--]]
function ClientInventory:SwapItems(Slot1,Slot2)
    SwapItems:FireServer(Slot1,Slot2)
    self.super:SwapItems(Slot1,Slot2)
end



return ClientInventory