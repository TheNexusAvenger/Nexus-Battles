--[[
TheNexusAvenger

Shows the inventory for the player.
--]]

local PLAYER_INVENTORY_SLOTS = {
    "Head",
    "Body",
    "Legs",
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local LoadingScreenCompleteValue = Players.LocalPlayer:WaitForChild("LoadingScreenComplete")
local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local PlayerInventoryIcon = ReplicatedStorageProject:GetResource("UI.Icon.PlayerInventoryIcon")
while not LoadingScreenCompleteValue.Value do LoadingScreenCompleteValue:GetPropertyChangedSignal("Value"):Wait() end



--Create a dictionary of the armor ids and max health.
local ArmorMaxHealth = {}
for _,ArmorData in pairs(Armor) do
    ArmorMaxHealth[ArmorData.Id] = ArmorData.MaxHealth
end

--Create the button for the inventory.
local InventoryButtonContainer = Instance.new("ScreenGui")
InventoryButtonContainer.Name = "InventoryButton"
InventoryButtonContainer.ResetOnSpawn = false
InventoryButtonContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local InventoryIcon = PlayerInventoryIcon.new(Players.LocalPlayer)
InventoryIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
InventoryIcon.Size = UDim2.new(0.1,0,0.1,0)
InventoryIcon.Position = UDim2.new(0.005,0,0.38,0)
InventoryIcon.Parent = InventoryButtonContainer
InventoryIcon:ClearAppearance()
InventoryIcon:PlayAnimation("rbxassetid://507766388")

--TODO: Create button.

--Create the health bars.
local Inventory = InventoryIcon.Inventory
for i,SlotName in pairs(PLAYER_INVENTORY_SLOTS) do
    --Create the health bar for the slot.
    local HealthBackground = Instance.new("Frame")
    HealthBackground.BorderSizePixel = 0
    HealthBackground.BackgroundColor3 = Color3.new(170/255,0,0)
    HealthBackground.AnchorPoint = Vector2.new(0.5,0.5)
    HealthBackground.Size = UDim2.new(0.9,0,0.05,0)
    HealthBackground.Position = UDim2.new(0.5,0,i / (#PLAYER_INVENTORY_SLOTS + 1),0)
    HealthBackground.ClipsDescendants = true
    HealthBackground.Parent = InventoryIcon.ViewportFrame

    local HealthBackgroundUICorner = Instance.new("UICorner")
    HealthBackgroundUICorner.CornerRadius = UDim.new(0.5,0)
    HealthBackgroundUICorner.Parent = HealthBackground

    local HealthFill = Instance.new("Frame")
    HealthFill.BorderSizePixel = 0
    HealthFill.BackgroundColor3 = Color3.new(0,170/255,0)
    HealthFill.Parent = HealthBackground

    local HealthFillUICorner = Instance.new("UICorner")
    HealthFillUICorner.CornerRadius = UDim.new(0.5,0)
    HealthFillUICorner.Parent = HealthFill

    --[[
    Updates the health bar.
    --]]
    local function UpdateHealthBar()
        local Item = Inventory:GetItemAtSlot(SlotName)
        if not Item or not Item.Health or not ArmorMaxHealth[Item.Id] then
            HealthBackground.Visible = false
        else
            HealthBackground.Visible = true
            HealthFill.Size = UDim2.new(Item.Health/ArmorMaxHealth[Item.Id],0,1,0)
        end
    end

    --Update the health bar.
    Inventory.InventoryChanged:Connect(UpdateHealthBar)
    UpdateHealthBar()
end

--TODO: Connect button