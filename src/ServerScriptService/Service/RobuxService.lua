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
local StatService = ServerScriptServiceProject:GetResource("Service.StatService")

local RobuxService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
RobuxService:SetClassName("RobuxService")



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
    local PurchaseHistoryStat = StatService:GetPersistentStats(Player):Get("PurchaseHistory")
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
            CoinService:GiveCoins(Player,math.floor(RobuxItem.Coins/TOTAL_COINS_TO_ANIMATE))
            wait()
        end
        CoinService:GiveCoins(Player,RobuxItem.Coins - ((TOTAL_COINS_TO_ANIMATE - 1) * math.floor(RobuxItem.Coins/TOTAL_COINS_TO_ANIMATE)))
    end

    --Return processed.
    return Enum.ProductPurchaseDecision.PurchaseGranted
end



return RobuxService