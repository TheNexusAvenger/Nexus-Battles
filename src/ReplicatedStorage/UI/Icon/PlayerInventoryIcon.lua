--[[
TheNexusAvenger

Player icon that connects to the inventory of a player.
--]]

local PLAYER_INVENTORY_SLOTS = {
    "Head",
    "Body",
    "Legs",
}



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Inventory = ReplicatedStorageProject:GetResource("State.Inventory.Inventory")

local PlayerInventoryIcon = ReplicatedStorageProject:GetResource("UI.Icon.PlayerIcon"):Extend()
PlayerInventoryIcon:SetClassName("PlayerInventoryIcon")



--[[
Creates the player inventory icon.
--]]
function PlayerInventoryIcon:__new(Player)
    self:InitializeSuper()

    --Set up the inventory.
    self.Inventory = Inventory.new(Player:WaitForChild("PersistentStats"):WaitForChild("Inventory"))
    self.Inventory.InventoryChanged:Connect(function()
        self:UpdatePlayerArmor()
    end)
    self:UpdatePlayerArmor()
end

--[[
Updates the armor of the player.
--]]
function PlayerInventoryIcon:UpdatePlayerArmor()
    for _,SlotName in pairs(PLAYER_INVENTORY_SLOTS) do
        local Item = self.Inventory:GetItemAtSlot(SlotName)
        self:SetArmor(SlotName,Item and Item.Id)
    end
end



return PlayerInventoryIcon