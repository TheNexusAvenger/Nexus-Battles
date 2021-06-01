--[[
TheNexusAvenger

Prompt for purchasing coins.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local DataLoadSuccessfulValue = Players.LocalPlayer:WaitForChild("DataLoadSuccessful")
local RobuxItems = ReplicatedStorageProject:GetResource("Data.RobuxItems")
local CutFrame = ReplicatedStorageProject:GetResource("External.NexusButton.Gui.CutFrame")
local GreenTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))
local RedTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(170/255,0,0))

local CoinPurchasePrompt = ReplicatedStorageProject:GetResource("UI.Prompt.BasePrompt"):Extend()
CoinPurchasePrompt:SetClassName("CoinPurchasePrompt")



--[[
Creates the base prompt.
--]]
function CoinPurchasePrompt:__new()
    self:InitializeSuper("CoinPurchasePrompt")

    --Determine the coin purchase items.
    local CoinPurchaseOptions = {}
    for _,PurchaseOption in pairs(RobuxItems) do
        if PurchaseOption.DisplayInCoinPurchase then
            table.insert(CoinPurchaseOptions,PurchaseOption)
        end
    end

    --Create the main container for the purchase options.
    local CoinPurchaseContainer = Instance.new("Frame")
    CoinPurchaseContainer.BackgroundTransparency = 1
    CoinPurchaseContainer.AnchorPoint = Vector2.new(0.5,0.5)
    CoinPurchaseContainer.Position = UDim2.new(0.5,0,0.5,0)
    CoinPurchaseContainer.Size = UDim2.new((1/1.2) * 0.3,0,0.3,0)
    CoinPurchaseContainer.SizeConstraint = Enum.SizeConstraint.RelativeYY
    CoinPurchaseContainer.Parent = self.AdornFrame

    local CloseButton,CloseText = RedTextButtonFactory:Create()
    CloseButton.Size = UDim2.new(0.8,0,0.2,0)
    CloseButton.Position = UDim2.new(0.5,0,1.1,0)
    CloseButton.AnchorPoint = Vector2.new(0.5,0)
    CloseButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    CloseButton:SetControllerIcon(Enum.KeyCode.ButtonB)
    CloseButton:MapKey(Enum.KeyCode.ButtonB,Enum.UserInputType.MouseButton1)
    CloseButton.Parent = CoinPurchaseContainer
    CloseText.Text = "CLOSE"

    --Connect closing.
    CloseButton.MouseButton1Down:Connect(function()
        self:Close()
    end)

    --Create the purchase options.
    for i,PurchaseOption in pairs(CoinPurchaseOptions) do
        local PurchaseBackgroundAdorn = Instance.new("Frame")
        PurchaseBackgroundAdorn.BackgroundTransparency = 1
        PurchaseBackgroundAdorn.SizeConstraint = Enum.SizeConstraint.RelativeYY
        PurchaseBackgroundAdorn.Size = UDim2.new(1/1.2,0,1,0)
        PurchaseBackgroundAdorn.Position = UDim2.new(((-#CoinPurchaseOptions/2) + i - 0.5) * 1.1,0,0,0)
        PurchaseBackgroundAdorn.Parent = CoinPurchaseContainer

        local PurchaseBackground = CutFrame.new(PurchaseBackgroundAdorn)
        PurchaseBackground.BackgroundTransparency = 0.5
        PurchaseBackground.BackgroundColor3 = Color3.new(1,1,1)
        PurchaseBackground:CutCorner("Top","Left",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeYY)
        PurchaseBackground:CutCorner("Bottom","Right",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeYY)

        local CoinImage = Instance.new("ImageLabel")
        CoinImage.BackgroundTransparency = 1
        CoinImage.SizeConstraint = Enum.SizeConstraint.RelativeXX
        CoinImage.Size = UDim2.new(0.8,0,0.8,0)
        CoinImage.Position = UDim2.new(0.1,0,0.05 * (1/1.2),0)
        CoinImage.Image = "rbxassetid://121148238"
        CoinImage.ZIndex = 5
        CoinImage.Parent = PurchaseBackgroundAdorn

        local CoinCount = Instance.new("TextLabel")
        CoinCount.BackgroundTransparency = 1
        CoinCount.AnchorPoint = Vector2.new(0.5,0.5)
        CoinCount.Position = UDim2.new(0.5,0,0.5,0)
        CoinCount.Size = UDim2.new(0.95,0,0.5,0)
        CoinCount.ZIndex = 5
        CoinCount.Font = Enum.Font.ArialBold
        CoinCount.Text = tostring(PurchaseOption.Coins)
        CoinCount.TextScaled = true
        CoinCount.TextColor3 = Color3.new(231/255,193/255,0)
        CoinCount.TextStrokeColor3 = Color3.new(0,0,0)
        CoinCount.TextStrokeTransparency = 0
        CoinCount.ZIndex = 5
        CoinCount.Parent = CoinImage

        local BuyButton,BuyText = GreenTextButtonFactory:Create()
        BuyButton.Size = UDim2.new(0.8,0,0.175,0)
        BuyButton.Position = UDim2.new(0.1,0,0.75,0)
        BuyButton.ZIndex = 5
        BuyButton.Visible = false
        BuyText.Text = "0"
        BuyButton.Parent = PurchaseBackgroundAdorn

        local RobuxIcon = Instance.new("ImageLabel")
        RobuxIcon.BackgroundTransparency = 1
        RobuxIcon.AnchorPoint = Vector2.new(1,0)
        RobuxIcon.Position = UDim2.new(0.95,0,0.05,0)
        RobuxIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
        RobuxIcon.Size = UDim2.new(0.9,0,0.9,0)
        RobuxIcon.Image = "rbxasset://textures/ui/common/robux@3x.png"
        RobuxIcon.ZIndex = 5
        RobuxIcon.Parent = BuyButton:GetAdornFrame()

        local OffsaleText = Instance.new("TextLabel")
        OffsaleText.BackgroundTransparency = 1
        OffsaleText.Size = UDim2.new(0.9,0,0.15,0)
        OffsaleText.Position = UDim2.new(0.05,0,0.75,0)
        OffsaleText.Font = Enum.Font.SourceSansBold
        OffsaleText.Text = "OFFSALE"
        OffsaleText.TextScaled = true
        OffsaleText.TextColor3 = Color3.new(1,1,1)
        OffsaleText.TextStrokeColor3 = Color3.new(0,0,0)
        OffsaleText.TextStrokeTransparency = 0
        OffsaleText.Parent = PurchaseBackgroundAdorn

        --[[
        Updates the state of the button.
        --]]
        local NexusAdminFeatureFlags
        local PurchaseEnabled = false
        local function UpdateButton()
            --Get the Robux cost.
            local RobuxCost = nil
            if PurchaseOption.ProductId ~= 0 and DataLoadSuccessfulValue.Value and NexusAdminFeatureFlags and NexusAdminFeatureFlags:GetFeatureFlag("RobuxPurchasesEnabled") and NexusAdminFeatureFlags:GetFeatureFlag("RobuxPurchase"..tostring(PurchaseOption.Name).."Enabled") then
                local Worked,Return = pcall(function()
                    return MarketplaceService:GetProductInfo(PurchaseOption.ProductId,Enum.InfoType.Product).PriceInRobux
                end)
                if Worked then
                    RobuxCost = Return
                else
                    warn("Get product info failed because "..tostring(Return))
                end
            end

            --Update the button.
            PurchaseEnabled = (RobuxCost ~= nil)
            BuyButton.Visible = PurchaseEnabled
            OffsaleText.Visible = not PurchaseEnabled
            if RobuxCost then
                BuyText.Text = tostring(RobuxCost)
            end
        end

        --Start updating the button.
        coroutine.wrap(function()
            --Load Nexus Admin Feature Flags.
            NexusAdminFeatureFlags = ReplicatedStorageProject:GetResource("NexusAdminClient").FeatureFlags
            NexusAdminFeatureFlags:GetFeatureFlagChangedEvent("RobuxPurchase"..tostring(PurchaseOption.Name).."Enabled"):Connect(UpdateButton)
            NexusAdminFeatureFlags:GetFeatureFlagChangedEvent("RobuxPurchasesEnabled"):Connect(UpdateButton)

            --Run the loop.
            while true do
                UpdateButton()
                wait(10)
            end
        end)()

        --Set up purchasing.
        BuyButton.MouseButton1Down:Connect(function()
            if PurchaseEnabled then
                MarketplaceService:PromptProductPurchase(Players.LocalPlayer,PurchaseOption.ProductId)
            end
        end)
    end

    --[[
    Updates the size of the prompt.
    --]]
    local function UpdateSize()
        local ScreenSize = self.AdornFrame.AbsoluteSize
        local RequiredWidthRelative = ((1/1.2) * #CoinPurchaseOptions) + ((#CoinPurchaseOptions - 1) * 0.1)

        if 0.3 * (1/0.9) * RequiredWidthRelative * ScreenSize.Y > ScreenSize.X then
            local RelativeWidth = (1/RequiredWidthRelative) * 0.9
            CoinPurchaseContainer.Size = UDim2.new(RelativeWidth * (1/1.2),0,RelativeWidth,0)
            CoinPurchaseContainer.SizeConstraint = Enum.SizeConstraint.RelativeXX
        else
            CoinPurchaseContainer.Size = UDim2.new((1/1.2) * 0.3,0,0.3,0)
            CoinPurchaseContainer.SizeConstraint = Enum.SizeConstraint.RelativeYY
        end
    end

    --Connect updating the size.
    self.AdornFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    UpdateSize()
end

--[[
Returns a stack coin purchase prompt.
Used by the inventory and coin wallet.
--]]
function CoinPurchasePrompt.GetPrompt()
    if not CoinPurchasePrompt.StaticPrompt then
        CoinPurchasePrompt.StaticPrompt = CoinPurchasePrompt.new()
    end
    return CoinPurchasePrompt.StaticPrompt
end



return CoinPurchasePrompt