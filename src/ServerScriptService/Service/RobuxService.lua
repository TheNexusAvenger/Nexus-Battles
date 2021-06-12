--[[
TheNexusAvenger

Service for handling Robux purchases.
--]]

local TOTAL_COINS_TO_ANIMATE = 20



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local RobuxItems = ReplicatedStorageProject:GetResource("Data.RobuxItems")
local CoinService = ServerScriptServiceProject:GetResource("Service.CoinService")
local FeatureFlagService = ServerScriptServiceProject:GetResource("Service.FeatureFlagService")
local InventoryService = ServerScriptServiceProject:GetResource("Service.InventoryService")
local StatService = ServerScriptServiceProject:GetResource("Service.StatService")

local RobuxService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
RobuxService:SetClassName("RobuxService")



--Set up the replicaiton.
local RobuxReplication = Instance.new("Folder")
RobuxReplication.Name = "Robux"
RobuxReplication.Parent = ReplicatedStorageProject:GetResource("Replication")

local RejectArmorBundle = Instance.new("RemoteEvent")
RejectArmorBundle.Name = "RejectArmorBundle"
RejectArmorBundle.Parent = RobuxReplication



--Set up the purchase handling.
function MarketplaceService.ProcessReceipt(ReceiptInfo)
    local ProductId = ReceiptInfo.ProductId
    local Player = Players:GetPlayerByUserId(ReceiptInfo.PlayerId)

    --Return failed if the player isn't in the server.
    if not Player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    --Get the item data.
    local RobuxItem
    for _,OtherRobuxItem in pairs(RobuxItems) do
        if OtherRobuxItem.ProductId == ProductId then
            RobuxItem = OtherRobuxItem
            break
        end
    end

    --Return failed if the item doesn't exist or is disabled.
    if not RobuxItem or not FeatureFlagService:RobuxPurchaseEnabled(RobuxItem.Name) then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    --Add the purchase history record.
    local PersistentStats = StatService:GetPersistentStats(Player)
    local PurchaseHistoryStat = PersistentStats:Get("PurchaseHistory")
    local PurchaseHistory = HttpService:JSONDecode(PurchaseHistoryStat:Get())
    table.insert(PurchaseHistory,{
        Name = RobuxItem.Name,
        ProductId = ReceiptInfo.ProductId,
        PurchaseId = ReceiptInfo.PurchaseId,
        RobuxSpent = ReceiptInfo.CurrencySpent,
    })
    PurchaseHistoryStat:Set(HttpService:JSONEncode(PurchaseHistory))

    --Handle the purchase.
    if RobuxItem.Coins then
        for _ = 1,TOTAL_COINS_TO_ANIMATE - 1 do
            CoinService:GiveCoinsFromRobuxPurchase(Player,math.floor(RobuxItem.Coins/TOTAL_COINS_TO_ANIMATE))
            wait()
        end
        CoinService:GiveCoinsFromRobuxPurchase(Player,RobuxItem.Coins - ((TOTAL_COINS_TO_ANIMATE - 1) * math.floor(RobuxItem.Coins/TOTAL_COINS_TO_ANIMATE)))
    end
    if RobuxItem.Armor then
        for _,Id in pairs(RobuxItem.Armor) do
            InventoryService:AwardItem(Player,Id)
        end
    end
    if RobuxItem.RankScore then
        PersistentStats:Get("RankScore"):Increment(RobuxItem.RankScore)
    end
    if RobuxItem.Name == "FirstArmorBundle" then
        PersistentStats:Get("FirstTimeBundleClosed"):Set(true)
    end

    --Return processed.
    return Enum.ProductPurchaseDecision.PurchaseGranted
end



--Connect the replication.
RejectArmorBundle.OnServerEvent:Connect(function(Player)
    StatService:GetPersistentStats(Player):Get("FirstTimeBundleClosed"):Set(true)
end)



return RobuxService