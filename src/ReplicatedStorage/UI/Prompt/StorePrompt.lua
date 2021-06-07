--[[
TheNexusAvenger

Prompt for the armor store.
--]]

local SLOTS_TO_ORDER = {
    Head = 1,
    Body = 2,
    Legs = 3,
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CoinsValue = Players.LocalPlayer:WaitForChild("PersistentStats"):WaitForChild("Coins")
local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local CutFrame = ReplicatedStorageProject:GetResource("External.NexusButton.Gui.CutFrame")
local PurchaseItem = ReplicatedStorageProject:GetResource("Replication.Shop.PurchaseItem")
local ArmorIcon = ReplicatedStorageProject:GetResource("UI.Icon.ArmorIcon")
local CoinPurchasePrompt = ReplicatedStorageProject:GetResource("UI.Prompt.CoinPurchasePrompt").GetPrompt()
local WhiteTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(255/255,255/255,255/255))
local GreenTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))
local BlueTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,255/255))
local RedTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(170/255,0,0))

local StorePrompt = ReplicatedStorageProject:GetResource("UI.Prompt.BasePrompt"):Extend()
StorePrompt:SetClassName("StorePrompt")



--[[
Creates the base prompt.
--]]
function StorePrompt:__new()
    self:InitializeSuper("StorePrompt")

    --Get and sort the armor.
    local ArmorItems = {}
    local ArmorIdToName = {}
    for ArmorName,ArmorData in pairs(Armor) do
        ArmorIdToName[ArmorData.Id] = ArmorName
        if ArmorData.Slot and ArmorData.Cost then
            table.insert(ArmorItems,ArmorData)
        end
    end
    table.sort(ArmorItems,function(a,b)
        if a.Slot ~= b.Slot then return SLOTS_TO_ORDER[a.Slot] < SLOTS_TO_ORDER[b.Slot] end
        return a.Id < b.Id
    end)

    --Create the prompt.
    local GridSize = math.ceil(math.sqrt(#ArmorItems))
    local StoreAdorn = Instance.new("Frame")
    StoreAdorn.BackgroundTransparency = 1
    StoreAdorn.AnchorPoint = Vector2.new(0.5,0.5)
    StoreAdorn.Position = UDim2.new(0.5,0,0.5,0)
    StoreAdorn.Size = UDim2.new(0.8 * (3/2),0,0.8,0)
    StoreAdorn.SizeConstraint = Enum.SizeConstraint.RelativeYY
    StoreAdorn.Parent = self.AdornFrame

    local ItemGridAdorn = Instance.new("Frame")
    ItemGridAdorn.BackgroundTransparency = 1
    ItemGridAdorn.Size = UDim2.new(2/3,0,1,0)
    ItemGridAdorn.Parent = StoreAdorn

    local ItemInfoAdorn = Instance.new("Frame")
    ItemInfoAdorn.BackgroundTransparency = 1
    ItemInfoAdorn.Position = UDim2.new(2/3,0,0,0)
    ItemInfoAdorn.Size = UDim2.new(1/3,0,1,0)
    ItemInfoAdorn.Parent = StoreAdorn

    local ItemInfoBackground = CutFrame.new(ItemInfoAdorn)
    ItemInfoBackground.BackgroundColor3 = Color3.new(0,0,0)
    ItemInfoBackground.BackgroundTransparency = 0.5
    ItemInfoBackground:CutCorner("Top","Left",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeXX)
    ItemInfoBackground:CutCorner("Bottom","Right",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeXX)

    local GridItemSize = 1/GridSize
    local ItemButtons = {}
    local ItemButtonsGrid = {}
    local ItemButtonsToId = {}
    local CurrentItem = nil
    local DisplayedArmorIcon = nil
    local CurrentTextUpdateTime = nil
    local CurrentlyPurchasing = false
    for i,ArmorItem in pairs(ArmorItems) do
        local GridX,GridY = (i - 1) % GridSize,math.floor((i - 1)/GridSize)
        local ItemButton,ItemText = WhiteTextButtonFactory:Create()
        ItemButton.BackgroundTransparency = 0.25
        ItemButton.BorderTransparency = 1
        ItemButton.BorderSizeScale = 0
        ItemButton.AnchorPoint = Vector2.new(0.5,0.5)
        ItemButton.Position = UDim2.new(GridItemSize * (GridX + 0.5),0,GridItemSize * (GridY + 0.5),0)
        ItemButton.Size = UDim2.new(GridItemSize * 0.95,0,GridItemSize * 0.95,0)
        ItemButton.Parent = ItemGridAdorn
        ItemText:Destroy()
        table.insert(ItemButtons,ItemButton)
        if not ItemButtonsGrid[GridX] then ItemButtonsGrid[GridX] = {} end
        ItemButtonsGrid[GridX][GridY] = ItemButton.AdornFrame
        ItemButtonsToId[ItemButton.AdornFrame] = i

        local Icon = ArmorIcon.new(ArmorIdToName[ArmorItem.Id])
        Icon.Size = UDim2.new(0.9,0,0.9,0)
        Icon.Position = UDim2.new(0.05,0,0.05,0)
        Icon.ZIndex = 5
        Icon.Parent = ItemButton.AdornFrame

        local ItemCost = Instance.new("TextLabel")
        ItemCost.BackgroundTransparency = 1
        ItemCost.Size = UDim2.new(0.5,0,0.3,0)
        ItemCost.Position = UDim2.new(0.45,0,0.7,0)
        ItemCost.Font = Enum.Font.SourceSansBold
        ItemCost.Text = tostring(ArmorItem.Cost)
        ItemCost.TextScaled = true
        ItemCost.TextColor3 = Color3.new(0,0,0)
        ItemCost.TextStrokeColor3 = Color3.new(1,1,1)
        ItemCost.TextStrokeTransparency = 0
        ItemCost.ZIndex = 5
        ItemCost.Parent = ItemButton.AdornFrame
    end

    local ItemNameText = Instance.new("TextLabel")
    ItemNameText.BackgroundTransparency = 1
    ItemNameText.Size = UDim2.new(0.9,0,0.06,0)
    ItemNameText.Position = UDim2.new(0.05,0,0.42,0)
    ItemNameText.Font = Enum.Font.SourceSansBold
    ItemNameText.TextScaled = true
    ItemNameText.TextColor3 = Color3.new(1,1,1)
    ItemNameText.TextStrokeColor3 = Color3.new(0,0,0)
    ItemNameText.TextStrokeTransparency = 0
    ItemNameText.ZIndex = 5
    ItemNameText.Parent = ItemInfoAdorn

    local ItemDescriptionText = Instance.new("TextLabel")
    ItemDescriptionText.BackgroundTransparency = 1
    ItemDescriptionText.Size = UDim2.new(0.9,0,0.2,0)
    ItemDescriptionText.Position = UDim2.new(0.05,0,0.48,0)
    ItemDescriptionText.Font = Enum.Font.SourceSansBold
    ItemDescriptionText.TextScaled = true
    ItemDescriptionText.TextColor3 = Color3.new(1,1,1)
    ItemDescriptionText.TextStrokeColor3 = Color3.new(0,0,0)
    ItemDescriptionText.TextStrokeTransparency = 0
    ItemDescriptionText.ZIndex = 5
    ItemDescriptionText.TextYAlignment = Enum.TextYAlignment.Top
    ItemDescriptionText.Parent = ItemInfoAdorn

    local ItemCostText = Instance.new("TextLabel")
    ItemCostText.BackgroundTransparency = 1
    ItemCostText.Size = UDim2.new(0.9,0,0.08,0)
    ItemCostText.Position = UDim2.new(0.05,0,0.7,0)
    ItemCostText.Font = Enum.Font.SourceSansBold
    ItemCostText.TextScaled = true
    ItemCostText.TextColor3 = Color3.new(1,1,1)
    ItemCostText.TextStrokeColor3 = Color3.new(0,0,0)
    ItemCostText.TextStrokeTransparency = 0
    ItemCostText.ZIndex = 5
    ItemCostText.Parent = ItemInfoAdorn

    local BuyButtonOverrideText = Instance.new("TextLabel")
    BuyButtonOverrideText.BackgroundTransparency = 1
    BuyButtonOverrideText.Size = UDim2.new(0.9,0,0.06,0)
    BuyButtonOverrideText.Position = UDim2.new(0.05,0,0.82,0)
    BuyButtonOverrideText.Font = Enum.Font.SourceSansBold
    BuyButtonOverrideText.Text = "[ERROR]"
    BuyButtonOverrideText.TextScaled = true
    BuyButtonOverrideText.TextColor3 = Color3.new(1,1,1)
    BuyButtonOverrideText.TextStrokeColor3 = Color3.new(0,0,0)
    BuyButtonOverrideText.TextStrokeTransparency = 0
    BuyButtonOverrideText.ZIndex = 5
    BuyButtonOverrideText.Visible = false
    BuyButtonOverrideText.Parent = ItemInfoAdorn

    local BuyButton,BuyText = GreenTextButtonFactory:Create()
    BuyButton.Size = UDim2.new(0.7,0,0.06,0)
    BuyButton.Position = UDim2.new(0.15,0,0.82,0)
    BuyButton.ZIndex = 5
    BuyButton:SetControllerIcon(Enum.KeyCode.ButtonX)
    BuyButton:MapKey(Enum.KeyCode.ButtonX,Enum.UserInputType.MouseButton1)
    BuyButton.Parent = ItemInfoAdorn
    BuyText.Text = "BUY"

    local GetCoinsButton,GetCoinsText = BlueTextButtonFactory:Create()
    GetCoinsButton.Size = UDim2.new(0.7,0,0.06,0)
    GetCoinsButton.Position = UDim2.new(0.15,0,0.9,0)
    GetCoinsButton.ZIndex = 5
    GetCoinsButton:SetControllerIcon(Enum.KeyCode.ButtonY)
    GetCoinsButton:MapKey(Enum.KeyCode.ButtonY,Enum.UserInputType.MouseButton1)
    GetCoinsButton.Parent = ItemInfoAdorn
    GetCoinsText.Text = "GET COINS"

    local CloseButton,CloseText = RedTextButtonFactory:Create()
    CloseButton.AnchorPoint = Vector2.new(0.5,0.5)
    CloseButton.Size = UDim2.new(0.1,0,0.1,0)
    CloseButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    CloseButton.Position = UDim2.new(1,0,0,0)
    CloseButton.ZIndex = 5
    CloseButton:MapKey(Enum.KeyCode.ButtonB,Enum.UserInputType.MouseButton1)
    CloseButton.Parent = ItemInfoAdorn
    CloseText.Text = "X"

    --[[
    Updates the size of the store.
    --]]
    local function UpdateSize()
        local ScreenSize = self.AdornFrame.AbsoluteSize
        if ScreenSize.Y * 0.8 * (3/2) > ScreenSize.X * 0.9 then
            StoreAdorn.Size = UDim2.new(0.9,0,0.9 * (2/3),0)
            StoreAdorn.SizeConstraint = Enum.SizeConstraint.RelativeXX
        else
            StoreAdorn.Size = UDim2.new(0.8 * (3/2),0,0.8,0)
            StoreAdorn.SizeConstraint = Enum.SizeConstraint.RelativeYY
        end
    end

    --[[
    Updates the displayed armor.
    --]]
    local function OpenArmor(Id)
        Id = Id or CurrentItem
        local ArmorData = ArmorItems[Id]

        if CurrentItem ~= Id then
            CurrentlyPurchasing = false

            --Update the highlighted grid button.
            for i,Button in pairs(ItemButtons) do
                Button.BackgroundColor3 = (i == Id and Color3.new(0,170/255,0) or Color3.new(1,1,1))
            end

            --Update the icon.
            if DisplayedArmorIcon then
                DisplayedArmorIcon:Destroy()
            end
            DisplayedArmorIcon = ArmorIcon.new(ArmorIdToName[ArmorData.Id])
            DisplayedArmorIcon.Size = UDim2.new(0.9,0,0.9 * 0.5,0)
            DisplayedArmorIcon.Position = UDim2.new(0.05,0,0.05 * 0.5,0)
            DisplayedArmorIcon.ZIndex = 5
            DisplayedArmorIcon.Parent = ItemInfoAdorn

            --Update the armor text.
            ItemNameText.Text = ArmorData.Name
            ItemDescriptionText.Text = ArmorData.Description or ""
            ItemCostText.Text = tostring(ArmorData.Cost).." Coins"
        end
        CurrentItem = Id

        --Update the visible button.
        if CurrentlyPurchasing then return end
        CurrentTextUpdateTime = tick()
        if CoinsValue.Value >= ArmorData.Cost then
            BuyButton.Visible = true
            BuyButtonOverrideText.Visible = false
        else
            BuyButton.Visible = false
            BuyButtonOverrideText.Visible = true
            BuyButtonOverrideText.Text = "NOT ENOUGH COINS"
        end
    end

    --[[
    Buys the current item.
    --]]
    local function BuyCurrentItem()
        local CurrentTime = tick()
        local ArmorItem = ArmorItems[CurrentItem]
        CurrentTextUpdateTime = CurrentTime
        CurrentlyPurchasing = true

        --Start the purchase.
        BuyButton.Visible = false
        BuyButtonOverrideText.Visible = true
        BuyButtonOverrideText.Text = "PLEASE WAIT"
        local Success = PurchaseItem:InvokeServer(ArmorItem.Id)

        --Update the text.
        if CurrentTime ~= CurrentTextUpdateTime then return end
        if Success then
            BuyButtonOverrideText.Text = "SUCCESS"
        else
            BuyButtonOverrideText.Text = "NOPE"
        end
        wait(2)

        --Reset the buttton.
        if CurrentTime ~= CurrentTextUpdateTime then return end
        CurrentlyPurchasing = false
        OpenArmor()
    end

    --Connect the buttons.
    for i,Button in pairs(ItemButtons) do
        Button.MouseButton1Down:Connect(function()
            OpenArmor(i)
        end)
    end
    CoinsValue:GetPropertyChangedSignal("Value"):Connect(OpenArmor)
    BuyButton.MouseButton1Down:Connect(function()
        if not self:IsOpen() then return end
        BuyCurrentItem()
    end)
    GetCoinsButton.MouseButton1Down:Connect(function()
        if not self:IsOpen() then return end
        if not CoinPurchasePrompt:IsOpen() then
            CoinPurchasePrompt:Open()
        end
    end)
    CloseButton.MouseButton1Down:Connect(function()
        if not self:IsOpen() then return end
        self:Close()
    end)
    OpenArmor(1)
    self.AdornFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    UpdateSize()

    --Set up the selection.
    for X,Row in pairs(ItemButtonsGrid) do
        for Y,Frame in pairs(Row) do
            Frame.Selectable = true
            Frame.NextSelectionUp = Row[Y - 1] or Frame
            Frame.NextSelectionDown = Row[Y + 1] or Frame
            Frame.NextSelectionLeft = ItemButtonsGrid[X - 1] and ItemButtonsGrid[X - 1][Y] or Frame
            Frame.NextSelectionRight = ItemButtonsGrid[X + 1] and ItemButtonsGrid[X + 1][Y] or Frame
            self.SelectionGroup:AddFrame(Frame)
        end
    end
    self.SelectionGroup:SetFirstFrame(ItemButtons[1].AdornFrame)
    GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
        if GuiService.SelectedObject and ItemButtonsToId[GuiService.SelectedObject] then
            OpenArmor(ItemButtonsToId[GuiService.SelectedObject])
        end
    end)
end



return StorePrompt