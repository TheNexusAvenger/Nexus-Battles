--[[
TheNexusAvenger

Opens the shop for the player in the lobby.
--]]

local SHOP_OPEN_RADIUS = 10
local SHOP_CLOSE_RADIUS = 15



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local ShopOpenZone = Workspace:WaitForChild("Lobby"):WaitForChild("ArmorShop"):WaitForChild("ShopOpenZone")
local StorePrompt = ReplicatedStorageProject:GetResource("UI.Prompt.StorePrompt").new()



--[[
Opens the shop.
--]]
local function OpenShop()
    if not StorePrompt:IsOpen() then
        StorePrompt:Open()
    end
end

--[[
Closes the shop.
--]]
local function CloseShop()
    if StorePrompt:IsOpen() then
        StorePrompt:Close()
    end
end



--Create the proximity prompt for opening the store.
local OpenProximityPrompt = Instance.new("ProximityPrompt")
OpenProximityPrompt.MaxActivationDistance = SHOP_OPEN_RADIUS
OpenProximityPrompt.ObjectText = "Open Shop"
OpenProximityPrompt.Parent = ShopOpenZone

--Connect the prompt opening.
StorePrompt:GetPropertyChangedSignal("OpenState"):Connect(function()
    OpenProximityPrompt.Enabled = (StorePrompt.OpenState == "BELOW")
end)

--Connect opening the shop.
OpenProximityPrompt.Triggered:Connect(function()
    OpenShop()
end)

--Update opening and closing based on the character.
local ShopOpened = false
while true do
    local Character = Players.LocalPlayer.Character
    if Character then
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            --Open the shop if the player is inside the shop zone.
            local LocalHumanoidPosition = ShopOpenZone.CFrame:Inverse() * HumanoidRootPart.CFrame
            if not ShopOpened and math.abs(LocalHumanoidPosition.X) <= ShopOpenZone.Size.X/2 and math.abs(LocalHumanoidPosition.Y) <= ShopOpenZone.Size.Y/2 and math.abs(LocalHumanoidPosition.Z) <= ShopOpenZone.Size.Z/2 then
                ShopOpened = true
                OpenShop()
            end

            --Close the shop if the player is far away.
            if (HumanoidRootPart.Position - ShopOpenZone.Position).Magnitude > SHOP_CLOSE_RADIUS then
                ShopOpened = false
                CloseShop()
            end
        end
    end
    wait()
end