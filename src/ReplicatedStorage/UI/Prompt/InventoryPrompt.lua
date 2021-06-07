--[[
TheNexusAvenger

Prompt for the inventory.
--]]

local INVENTORY_GRID_SIZE = 5



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local CutFrame = ReplicatedStorageProject:GetResource("External.NexusButton.Gui.CutFrame")
local Inventory = ReplicatedStorageProject:GetResource("State.Inventory.Inventory")
local BlueTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,255/255))
local RedTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(170/255,0,0))
local ArmorIcon = ReplicatedStorageProject:GetResource("UI.Icon.ArmorIcon")
local PlayerInventoryIcon = ReplicatedStorageProject:GetResource("UI.Icon.PlayerInventoryIcon")

local InventoryPrompt = ReplicatedStorageProject:GetResource("UI.Prompt.BasePrompt"):Extend()
InventoryPrompt:SetClassName("InventoryPrompt")



--Create a dictionary of the armor ids to max health and model names.
local ArmorMaxHealth = {}
local ArmorModelNames = {}
local ArmorDataLookup = {}
for ArmorName,ArmorData in pairs(Armor) do
    ArmorDataLookup[ArmorData.Id] = ArmorData
    ArmorMaxHealth[ArmorData.Id] = ArmorData.MaxHealth
    ArmorModelNames[ArmorData.Id] = ArmorName
end



--[[
Creates the inventory prompt.
--]]
function InventoryPrompt:__new()
    self:InitializeSuper("InventoryPrompt")

    --Create the prompt.
    local InventoryAdorn = Instance.new("Frame")
    InventoryAdorn.BackgroundTransparency = 1
    InventoryAdorn.AnchorPoint = Vector2.new(0.5,0.5)
    InventoryAdorn.Position = UDim2.new(0.5,0,0.5,0)
    InventoryAdorn.Size = UDim2.new(0.8 * (3/2),0,0.8,0)
    InventoryAdorn.SizeConstraint = Enum.SizeConstraint.RelativeYY
    InventoryAdorn.Parent = self.AdornFrame

    local CloseButton,CloseText = RedTextButtonFactory:Create()
    CloseButton.AnchorPoint = Vector2.new(0,0.5)
    CloseButton.Size = UDim2.new(0.1,0,0.1,0)
    CloseButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    CloseButton.Position = UDim2.new(1.01,0,0,0)
    CloseButton.ZIndex = 5
    CloseButton:MapKey(Enum.KeyCode.ButtonB,Enum.UserInputType.MouseButton1)
    CloseButton.Parent = InventoryAdorn
    CloseText.Text = "X"

    local CharacterAdorn = Instance.new("Frame")
    CharacterAdorn.BackgroundTransparency = 1
    CharacterAdorn.Size = UDim2.new(1/3,0,1,0)
    CharacterAdorn.Parent = InventoryAdorn

    local CharacterIcon = PlayerInventoryIcon.new(Players.LocalPlayer)
    CharacterIcon.AnchorPoint = Vector2.new(0.5,0)
    CharacterIcon.Size = UDim2.new(0.7 * 3,0,0.7,0)
    CharacterIcon.Position = UDim2.new(0.5,0,0,0)
    CharacterIcon.Parent = CharacterAdorn
    CharacterIcon:PlayAnimation("rbxassetid://507777826")

    local ItemInfoAdorn = Instance.new("Frame")
    ItemInfoAdorn.BackgroundTransparency = 1
    ItemInfoAdorn.Size = UDim2.new(0.9,0,0.3,0)
    ItemInfoAdorn.Position = UDim2.new(0.05,0,0.65,0)
    ItemInfoAdorn.Parent = CharacterAdorn

    local ItemInfoBackground = CutFrame.new(ItemInfoAdorn)
    ItemInfoBackground.BackgroundColor3 = Color3.new(0,0,0)
    ItemInfoBackground.BackgroundTransparency = 0.5
    ItemInfoBackground:CutCorner("Top","Left",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeYY)
    ItemInfoBackground:CutCorner("Bottom","Right",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeYY)

    local ItemNameText = Instance.new("TextLabel")
    ItemNameText.BackgroundTransparency = 1
    ItemNameText.Size = UDim2.new(0.9,0,0.3,0)
    ItemNameText.Position = UDim2.new(0.05,0,0.05,0)
    ItemNameText.Font = Enum.Font.SourceSansBold
    ItemNameText.TextScaled = true
    ItemNameText.TextColor3 = Color3.new(1,1,1)
    ItemNameText.TextStrokeColor3 = Color3.new(0,0,0)
    ItemNameText.TextStrokeTransparency = 0
    ItemNameText.Text = ""
    ItemNameText.ZIndex = 5
    ItemNameText.Parent = ItemInfoAdorn

    local ItemDescriptionText = Instance.new("TextLabel")
    ItemDescriptionText.BackgroundTransparency = 1
    ItemDescriptionText.Size = UDim2.new(0.9,0,0.6,0)
    ItemDescriptionText.Position = UDim2.new(0.05,0,0.35,0)
    ItemDescriptionText.Font = Enum.Font.SourceSansBold
    ItemDescriptionText.TextScaled = true
    ItemDescriptionText.TextColor3 = Color3.new(1,1,1)
    ItemDescriptionText.TextStrokeColor3 = Color3.new(0,0,0)
    ItemDescriptionText.TextStrokeTransparency = 0
    ItemDescriptionText.Text = ""
    ItemDescriptionText.ZIndex = 5
    ItemDescriptionText.TextYAlignment = Enum.TextYAlignment.Top
    ItemDescriptionText.Parent = ItemInfoAdorn

    local GridAdorn = Instance.new("Frame")
    GridAdorn.BackgroundTransparency = 1
    GridAdorn.Size = UDim2.new(2/3,0,1,0)
    GridAdorn.Position = UDim2.new(1/3,0,0,0)
    GridAdorn.Parent = InventoryAdorn

    local SlotFrames = {}
    local CurrentPage = 1
    local PlayerInventory = Inventory.new(Players.LocalPlayer:WaitForChild("PersistentStats"):WaitForChild("Inventory"))

    --[[
    Creates an item slot.
    --]]
    local function CreateItemSlot(SlotId,FrameProperties)
        --Create the frames.
        local SlotFrame = Instance.new("Frame")
        SlotFrame.BorderSizePixel = 0
        SlotFrame.BackgroundTransparency = 0.5
        SlotFrame.BackgroundColor3 = Color3.new(1,1,1)
        SlotFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
        for Name,Value in pairs(FrameProperties) do
            SlotFrame[Name] = Value
        end

        local SlotFrameUICorner = Instance.new("UICorner")
        SlotFrameUICorner.CornerRadius = UDim.new(0.1,0)
        SlotFrameUICorner.Parent = SlotFrame

        local HealthBackground = Instance.new("Frame")
        HealthBackground.BorderSizePixel = 0
        HealthBackground.BackgroundColor3 = Color3.new(170/255,0,0)
        HealthBackground.AnchorPoint = Vector2.new(0.5,0.5)
        HealthBackground.Size = UDim2.new(0.9,0,0.05,0)
        HealthBackground.Position = UDim2.new(0.5,0,0.75,0)
        HealthBackground.ClipsDescendants = true
        HealthBackground.Visible = false
        HealthBackground.ZIndex = 3
        HealthBackground.Parent = SlotFrame

        local HealthBackgroundUICorner = Instance.new("UICorner")
        HealthBackgroundUICorner.CornerRadius = UDim.new(0.5,0)
        HealthBackgroundUICorner.Parent = HealthBackground

        local HealthFill = Instance.new("Frame")
        HealthFill.BorderSizePixel = 0
        HealthFill.BackgroundColor3 = Color3.new(0,170/255,0)
        HealthFill.ZIndex = 3
        HealthFill.Parent = HealthBackground

        local HealthFillUICorner = Instance.new("UICorner")
        HealthFillUICorner.CornerRadius = UDim.new(0.5,0)
        HealthFillUICorner.Parent = HealthFill

        --Set up the slot data.
        local SlotFrameData = {
            Slot = SlotId,
            SlotFrame = SlotFrame,
            HealthBackground = HealthBackground,
            HealthFill = HealthFill,
            Visible = true,
        }
        SlotFrames[SlotId] = SlotFrameData

        --[[
        Updates the displayed item.
        --]]
        function SlotFrameData:Update()
            --Get the slot and item.
            local Slot = SlotId
            if typeof(Slot) == "number" then
                Slot = Slot + (INVENTORY_GRID_SIZE * INVENTORY_GRID_SIZE * (CurrentPage - 1))
            end
            self.Slot = Slot
            local Item = PlayerInventory:GetItemAtSlot(Slot)

            --Update the display.
            if Item then
                --Create the icon.
                if self.CurrentItemId ~= Item.Id then
                    self.CurrentItemId = Item.Id
                    if self.ArmorIcon then
                        self.ArmorIcon:Destroy()
                    end
                    self.ArmorIcon = ArmorIcon.new(ArmorModelNames[Item.Id])
                    self.ArmorIcon.Size = UDim2.new(0.9,0,0.9,0)
                    self.ArmorIcon.Position = UDim2.new(0.05,0,0.05,0)
                    self.ArmorIcon.Parent = self.SlotFrame
                end
                self.ArmorIcon.Visible = self.Visible

                --Update the health.
                if Item.Health and ArmorMaxHealth[Item.Id] then
                    self.HealthBackground.Visible = self.Visible
                    self.HealthFill.Size = UDim2.new(Item.Health/ArmorMaxHealth[Item.Id],0,1,0)
                else
                    self.HealthBackground.Visible = false
                end
            else
                --Hide the frame.
                if self.ArmorIcon then
                    self.ArmorIcon:Destroy()
                    self.ArmorIcon = nil
                    self.CurrentItemId = nil
                end
                self.HealthBackground.Visible = false
            end
        end

        --[[
        Shows the slot.
        --]]
        function SlotFrameData:Show()
            self.Visible = true
            self:Update()
        end

        --[[
        Hides the slot.
        --]]
        function SlotFrameData:Hide()
            self.Visible = false
            self:Update()
        end

        --Connect updating the display.
        SlotFrameData:Update()
        PlayerInventory.InventoryChanged:Connect(function()
            SlotFrameData:Update()
        end)
    end

    --[[
    Updates the size of the store.
    --]]
    local function UpdateSize()
        local ScreenSize = self.AdornFrame.AbsoluteSize
        if ScreenSize.Y * 0.8 * (3/2) > ScreenSize.X * 0.9 then
            InventoryAdorn.Size = UDim2.new(0.9,0,0.9 * (2/3),0)
            InventoryAdorn.SizeConstraint = Enum.SizeConstraint.RelativeXX
        else
            InventoryAdorn.Size = UDim2.new(0.8 * (3/2),0,0.8,0)
            InventoryAdorn.SizeConstraint = Enum.SizeConstraint.RelativeYY
        end
    end

    --Create the slots.
    CreateItemSlot("Head",{
        AnchorPoint = Vector2.new(1,0),
        Size = UDim2.new(0.15,0,0.15,0),
        Position = UDim2.new(1,0,0.025,0),
        Parent = CharacterAdorn,
    })
    CreateItemSlot("Body",{
        AnchorPoint = Vector2.new(1,0),
        Size = UDim2.new(0.15,0,0.15,0),
        Position = UDim2.new(1,0,0.225,0),
        Parent = CharacterAdorn,
    })
    CreateItemSlot("Legs",{
        AnchorPoint = Vector2.new(1,0),
        Size = UDim2.new(0.15,0,0.15,0),
        Position = UDim2.new(1,0,0.425,0),
        Parent = CharacterAdorn,
    })
    for Y = 1,INVENTORY_GRID_SIZE do
        for X = 1,INVENTORY_GRID_SIZE do
            CreateItemSlot(((Y - 1) * INVENTORY_GRID_SIZE) + X,{
                AnchorPoint = Vector2.new(0.5,0.5),
                Size = UDim2.new(0.9 * (1/INVENTORY_GRID_SIZE),0,0.9 * (1/INVENTORY_GRID_SIZE),0),
                Position = UDim2.new((X - 0.5) * (1/INVENTORY_GRID_SIZE),0,(Y - 0.5) * (1/INVENTORY_GRID_SIZE),0),
                Parent = GridAdorn,
            })
        end
    end

    --Connect the mouse events.
    local CurrentHoveringSlotFrame = nil
    local InitialDragFrame = nil
    local MovingItemFrame = nil
    UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        --Update the current hovering frame.
        CurrentHoveringSlotFrame = nil
        for _,SlotFrame in pairs(SlotFrames) do
            local FramePosition,FrameSize = SlotFrame.SlotFrame.AbsolutePosition,SlotFrame.SlotFrame.AbsoluteSize
            if Input.Position.X >= FramePosition.X and Input.Position.X <= FramePosition.X + FrameSize.X and Input.Position.Y >= FramePosition.Y and Input.Position.Y <= FramePosition.Y + FrameSize.Y then
                CurrentHoveringSlotFrame = SlotFrame
            end
        end

        --Update the item information.
        if CurrentHoveringSlotFrame and CurrentHoveringSlotFrame.CurrentItemId then
            local ArmorData = ArmorDataLookup[CurrentHoveringSlotFrame.CurrentItemId]
            ItemNameText.Text = ArmorData.Name
            ItemDescriptionText.Text = ArmorData.Description
        else
            ItemNameText.Text = ""
            ItemDescriptionText.Text = ""
        end

        --Update the drag frame.
        if MovingItemFrame then
            MovingItemFrame.Position = UDim2.new(0,Input.Position.X,0,Input.Position.Y)
        end
    end)
    UserInputService.InputBegan:Connect(function(Input,Processed)
        if Processed then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        --End the existing drag if one exists.
        if InitialDragFrame then
            InitialDragFrame:Show()
            InitialDragFrame = nil
        end
        if MovingItemFrame then
            MovingItemFrame:Destroy()
            MovingItemFrame = nil
        end
        if not CurrentHoveringSlotFrame or not CurrentHoveringSlotFrame.CurrentItemId then return end

        --Start dragging.
        InitialDragFrame = CurrentHoveringSlotFrame
        CurrentHoveringSlotFrame:Hide()
        MovingItemFrame = ArmorIcon.new(ArmorModelNames[CurrentHoveringSlotFrame.CurrentItemId])
        MovingItemFrame.AnchorPoint = Vector2.new(0.5,0.5)
        MovingItemFrame.Size = UDim2.new(0,CurrentHoveringSlotFrame.SlotFrame.AbsoluteSize.X,0,CurrentHoveringSlotFrame.SlotFrame.AbsoluteSize.Y)
        MovingItemFrame.Position = UDim2.new(0,Input.Position.X,0,Input.Position.Y)
        MovingItemFrame.Parent = self.AdornFrame
    end)
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        --End the existing drag if one exists.
        if InitialDragFrame then
            InitialDragFrame:Show()
        end
        if MovingItemFrame then
            MovingItemFrame:Destroy()
            MovingItemFrame = nil
        end
        if not CurrentHoveringSlotFrame or not InitialDragFrame then
            InitialDragFrame = nil
            return
        end

        --Attempt to swap the slots.
        PlayerInventory:SwapItems(CurrentHoveringSlotFrame.Slot,InitialDragFrame.Slot)
        InitialDragFrame = nil
    end)

    --Connect closing.
    CloseButton.MouseButton1Down:Connect(function()
        self:Close()
    end)

    --Connect updating the size.
    self.AdornFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    UpdateSize()
end



return InventoryPrompt