--[[
TheNexusAvenger

Manages inventories for players.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

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





--Connect players leaving.
Players.PlayerRemoving:Connect(function(Player)
    if InventoryService.PlayerInventories[Player] then
        InventoryService.PlayerInventories[Player]:Destroy()
        InventoryService.PlayerInventories[Player] = nil
    end
end)



return InventoryService