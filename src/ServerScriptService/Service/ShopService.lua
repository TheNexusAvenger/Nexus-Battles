--[[
TheNexusAvenger

Service for managing player coins.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local FeatureFlagService = ServerScriptServiceProject:GetResource("Service.FeatureFlagService")
local InventoryService = ServerScriptServiceProject:GetResource("Service.InventoryService")
local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")
local StatService = ServerScriptServiceProject:GetResource("Service.StatService")

local ShopService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
ShopService:SetClassName("ShopService")



--Set up the replicaiton.
local ShopReplication = Instance.new("Folder")
ShopReplication.Name = "Shop"
ShopReplication.Parent = ReplicatedStorageProject:GetResource("Replication")

local PurchaseItem = Instance.new("RemoteFunction")
PurchaseItem.Name = "PurchaseItem"
PurchaseItem.Parent = ShopReplication



--[[
Attempts to purchase an item.
--]]
function ShopService:PurchaseItem(Player,Id)
    --Get the item and return if the item doesn't exist or isn't for sale.
    local ArmorData
    local Name
    for ArmorName,ArmorItem in pairs(Armor) do
        if ArmorItem.Id == Id and ArmorItem.Cost then
            Name = ArmorName
            ArmorData = ArmorItem
            break
        end
    end
    if not ArmorData then return false end
    if not FeatureFlagService:ItemPurchaseEnabled(Name) then return false end

    --Return if the player doesn't have enough coins.
    local Stats = StatService:GetPersistentStats(Player)
    local CoinsStat = Stats:Get("Coins")
    local CurrentCoins = CoinsStat:Get()
    if CurrentCoins < ArmorData.Cost then return false end

    --Add the item to the inventory, subtract the coins, and return.
    local Inventory = InventoryService:GetInventory(Player)
    Inventory:AddItem(Id)
    CoinsStat:Increment(-ArmorData.Cost)
    LocalEffectService:PlayLocalEffect(Player,"UpdateCoins")
    return true
end



--Connect the client purchasing items.
function PurchaseItem.OnServerInvoke(Player,Id)
    return ShopService:PurchaseItem(Player,Id)
end



return ShopService