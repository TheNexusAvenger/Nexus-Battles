--[[
TheNexusAvenger

Prompt for alerting the player their data didn't load.
--]]

local DEFAULT_BUNDLE_COST = 79



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local FirstTimeBundleClosedValue = Players.LocalPlayer:WaitForChild("PersistentStats"):WaitForChild("FirstTimeBundleClosed")
local RobuxItems = ReplicatedStorageProject:GetResource("Data.RobuxItems")
local CutFrame = ReplicatedStorageProject:GetResource("External.NexusButton.Gui.CutFrame")
local RejectArmorBundle = ReplicatedStorageProject:GetResource("Replication.Robux.RejectArmorBundle")
local PlayerIcon = ReplicatedStorageProject:GetResource("UI.Icon.PlayerIcon")
local GreenTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))
local RedTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(170/255,0,0))

local FirstPlayBundlePrompt = ReplicatedStorageProject:GetResource("UI.Prompt.BasePrompt"):Extend()
FirstPlayBundlePrompt:SetClassName("FirstPlayBundlePrompt")



--[[
Creates the base prompt.
--]]
function FirstPlayBundlePrompt:__new()
    self:InitializeSuper("FirstPlayBundlePrompt")

    --Create the prompt.
    local PromptBackgroundAdorn = Instance.new("Frame")
    PromptBackgroundAdorn.BackgroundTransparency = 1
    PromptBackgroundAdorn.AnchorPoint = Vector2.new(0.5,0.5)
    PromptBackgroundAdorn.Position = UDim2.new(0.5,0,0.5,0)
    PromptBackgroundAdorn.Size = UDim2.new(0.8,0,0.4,0)
    PromptBackgroundAdorn.SizeConstraint = Enum.SizeConstraint.RelativeYY
    PromptBackgroundAdorn.Parent = self.AdornFrame

    local PurchaseBackground = CutFrame.new(PromptBackgroundAdorn)
    PurchaseBackground.BackgroundTransparency = 0.5
    PurchaseBackground.BackgroundColor3 = Color3.new(1,1,1)
    PurchaseBackground:CutCorner("Top","Left",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeYY)
    PurchaseBackground:CutCorner("Bottom","Right",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeYY)

    local CharacterIcon = PlayerIcon.new()
    CharacterIcon.Size = UDim2.new(0.8,0,0.8,0)
    CharacterIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
    CharacterIcon.Position = UDim2.new(-0.025,0,0.1,0)
    CharacterIcon.ZIndex = 5
    CharacterIcon.Parent = PromptBackgroundAdorn
    CharacterIcon:PlayAnimation("rbxassetid://507766388")
    CharacterIcon:SetArmor("Body",102)
    CharacterIcon:SetArmor("Legs",201)
    self.CharacterIcon = CharacterIcon

    local RankIcon = Instance.new("ImageLabel")
    RankIcon.BackgroundTransparency = 1
    RankIcon.Position = UDim2.new(0.4,0,0.4,0)
    RankIcon.Size = UDim2.new(0.6,0,0.6,0)
    RankIcon.Image = "rbxassetid://6866145490"
    RankIcon.ImageColor3 = Color3.new(230/255,230/255,230/255)
    RankIcon.ImageRectSize = Vector2.new(512,512)
    RankIcon.ZIndex = 6
    RankIcon.Parent = CharacterIcon.ViewportFrame

    local PromptText = Instance.new("TextLabel")
    PromptText.BackgroundTransparency = 1
    PromptText.Size = UDim2.new(0.6,0,0.9,0)
    PromptText.Position = UDim2.new(0.35,0,0.05,0)
    PromptText.Font = Enum.Font.SourceSansBold
    PromptText.Text = "Hit the ground running! This exclusive offer gives you armor with 25% absorption, as well as skipping to rank 5!"
    PromptText.TextScaled = true
    PromptText.TextColor3 = Color3.new(0,0,0)
    PromptText.TextStrokeColor3 = Color3.new(1,1,1)
    PromptText.TextStrokeTransparency = 0
    PromptText.ZIndex = 5
    PromptText.Parent = PromptBackgroundAdorn

    local BuyButton,BuyText = GreenTextButtonFactory:Create()
    BuyButton.Size = UDim2.new(0.7,0,0.15,0)
    BuyButton.Position = UDim2.new(0.3,0,1.1,0)
    BuyButton.AnchorPoint = Vector2.new(0.5,0)
    BuyButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    BuyButton:SetControllerIcon(Enum.KeyCode.ButtonX)
    BuyButton:MapKey(Enum.KeyCode.ButtonX,Enum.UserInputType.MouseButton1)
    BuyButton.Parent = PromptBackgroundAdorn
    BuyText.Text = tostring(DEFAULT_BUNDLE_COST)
    self.BuyButton = BuyButton

    local RobuxIcon = Instance.new("ImageLabel")
    RobuxIcon.BackgroundTransparency = 1
    RobuxIcon.AnchorPoint = Vector2.new(1,0)
    RobuxIcon.Position = UDim2.new(0.95,0,0.05,0)
    RobuxIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
    RobuxIcon.Size = UDim2.new(0.9,0,0.9,0)
    RobuxIcon.Image = "rbxasset://textures/ui/common/robux@3x.png"
    RobuxIcon.ZIndex = 5
    RobuxIcon.Parent = BuyButton:GetAdornFrame()

    local CloseButton,CloseText = RedTextButtonFactory:Create()
    CloseButton.Size = UDim2.new(0.7,0,0.15,0)
    CloseButton.Position = UDim2.new(0.7,0,1.1,0)
    CloseButton.AnchorPoint = Vector2.new(0.5,0)
    CloseButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    CloseButton:SetControllerIcon(Enum.KeyCode.ButtonB)
    CloseButton:MapKey(Enum.KeyCode.ButtonB,Enum.UserInputType.MouseButton1)
    CloseButton.Parent = PromptBackgroundAdorn
    CloseText.Text = "CLOSE"
    self.CloseButton = CloseButton

    --Get the product id.
    local ProductId = 0
    for _,RobuxItem in pairs(RobuxItems) do
        if RobuxItem.Name == "FirstArmorBundle" then
            ProductId = RobuxItem.ProductId
        end
    end

    --Update the price until the prompt is destroyed.
    coroutine.wrap(function()
        while self.AdornFrame.Parent do
            --Get the Robux cost.
            local RobuxCost = DEFAULT_BUNDLE_COST
            if ProductId ~= 0 then
                local Worked,Return = pcall(function()
                    return MarketplaceService:GetProductInfo(ProductId,Enum.InfoType.Product).PriceInRobux
                end)
                if Worked then
                    RobuxCost = Return
                else
                    warn("Get product info failed because "..tostring(Return))
                end
            end

            --Update the button text.
            BuyText.Text = tostring(RobuxCost)
            wait(10)
        end
    end)()

    --Connect buying.
    BuyButton.MouseButton1Down:Connect(function()
        if not self:IsFocused() then return end
        MarketplaceService:PromptProductPurchase(Players.LocalPlayer,ProductId)
    end)

    --Connect closing.
    CloseButton.MouseButton1Down:Connect(function()
        if not self:IsOpen() then return end
        RejectArmorBundle:FireServer()
        self:Destroy()
    end)
    FirstTimeBundleClosedValue:GetPropertyChangedSignal("Value"):Connect(function()
        if FirstTimeBundleClosedValue.Value then
            self:Destroy()
        end
    end)
end

--[[
Destroys the prompt
--]]
function FirstPlayBundlePrompt:Destroy()
    self.super:Destroy()
    delay(1,function()
        self.BuyButton:Destroy()
        self.CloseButton:Destroy()
        self.CharacterIcon:Destroy()
    end)
end



return FirstPlayBundlePrompt