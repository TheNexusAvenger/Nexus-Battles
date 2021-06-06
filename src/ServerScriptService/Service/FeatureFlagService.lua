--[[
TheNexusAvenger

Service for managing feature flags with Nexus Admin.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local GameTypes = ReplicatedStorageProject:GetResource("Data.GameTypes")
local MapTypes = ReplicatedStorageProject:GetResource("Data.MapTypes")
local RobuxItems = ReplicatedStorageProject:GetResource("Data.RobuxItems")
local NexusEventCreator = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEventCreator")
local NexusAdminFeatureFlags

local FeatureFlagService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
FeatureFlagService:SetClassName("FeatureFlagService")
FeatureFlagService.RoundFeatureFlagChanged = NexusEventCreator:CreateEvent()
FeatureFlagService.MeshDeformationFeatureFlagChanged = NexusEventCreator:CreateEvent()



coroutine.wrap(function()
    --Get Nexus Admin's Feature Flag service.
    local NexusAdmin = ServerScriptServiceProject:GetResource("NexusAdmin")
    while not NexusAdmin:GetAdminLoaded() do wait() end
    NexusAdminFeatureFlags = NexusAdmin.FeatureFlags

    --Add the feature flags for the rounds and maps.
    for RoundTypeName,_ in pairs(GameTypes) do
        NexusAdminFeatureFlags:AddFeatureFlag("Round"..tostring(RoundTypeName).."Enabled",true)
        NexusAdminFeatureFlags:GetFeatureFlagChangedEvent("Round"..tostring(RoundTypeName).."Enabled"):Connect(function()
            FeatureFlagService.RoundFeatureFlagChanged:Fire()
        end)
    end
    for MapTypeName,_ in pairs(MapTypes) do
        NexusAdminFeatureFlags:AddFeatureFlag("Map"..tostring(MapTypeName).."Enabled",true)
        NexusAdminFeatureFlags:GetFeatureFlagChangedEvent("Map"..tostring(MapTypeName).."Enabled"):Connect(function()
            FeatureFlagService.RoundFeatureFlagChanged:Fire()
        end)
    end
    FeatureFlagService.RoundFeatureFlagChanged:Fire()

    --Add the feature flags for the shop items.
    NexusAdminFeatureFlags:AddFeatureFlag("ShopEnabled",true)
    for ArmorName,_ in pairs(Armor) do
        NexusAdminFeatureFlags:AddFeatureFlag("Armor"..tostring(ArmorName).."PurchaseEnabled",true)
    end

    --Add the feature flags for Robux items.
    NexusAdminFeatureFlags:AddFeatureFlag("RobuxPurchasesEnabled",true)
    for _,RobuxData in pairs(RobuxItems) do
        NexusAdminFeatureFlags:AddFeatureFlag("RobuxPurchase"..tostring(RobuxData.Name).."Enabled",true)
    end

    --Add the feature flag for mesh deformation.
    NexusAdminFeatureFlags:AddFeatureFlag("UseMeshDeformation",true)
    NexusAdminFeatureFlags:GetFeatureFlagChangedEvent("UseMeshDeformation"):Connect(function()
        FeatureFlagService.MeshDeformationFeatureFlagChanged:Fire()
    end)
    FeatureFlagService.MeshDeformationFeatureFlagChanged:Fire()
end)()



--[[
Returns the value of a feature flag.
--]]
function FeatureFlagService:GetFeatureFlag(Name)
    if NexusAdminFeatureFlags then
        return NexusAdminFeatureFlags:GetFeatureFlag(Name)
    end
    return true
end

--[[
Returns if a round type and map type are enabled.
--]]
function FeatureFlagService:RoundEnabled(RoundType,MapType)
    return self:GetFeatureFlag("Round"..tostring(RoundType).."Enabled") and self:GetFeatureFlag("Map"..tostring(MapType).."Enabled")
end

--[[
Returns if an item purchase is enabled.
--]]
function FeatureFlagService:ItemPurchaseEnabled(ItemName)
    return self:GetFeatureFlag("ShopEnabled") and self:GetFeatureFlag("Armor"..tostring(ItemName).."PurchaseEnabled")
end

--[[
Returns if a Robux purchase is enabled.
--]]
function FeatureFlagService:RobuxPurchaseEnabled(RobuxItemName)
    return self:GetFeatureFlag("RobuxPurchasesEnabled") and self:GetFeatureFlag("RobuxPurchase"..tostring(RobuxItemName).."Enabled")
end



return FeatureFlagService