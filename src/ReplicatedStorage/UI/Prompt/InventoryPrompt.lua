--[[
TheNexusAvenger

Prompt for the inventory.
--]]

local INVENTORY_GRID_SIZE = 5



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local CutFrame = ReplicatedStorageProject:GetResource("External.NexusButton.Gui.CutFrame")
local ControllerIcon = ReplicatedStorageProject:GetResource("External.NexusButton.Gui.ControllerIcon")
local ClientInventory = ReplicatedStorageProject:GetResource("State.Inventory.ClientInventory")
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
    InventoryAdorn.AnchorPoint = Vector2.new(0.5,0.55)
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

    local ControllerInfoFrame = Instance.new("Frame")
    ControllerInfoFrame.BackgroundTransparency = 1
    ControllerInfoFrame.Size = UDim2.new(0.9,0,0.4,0)
    ControllerInfoFrame.Position = UDim2.new(0.05,0,1.05,0)
    ControllerInfoFrame.Parent = ItemInfoAdorn

    local XIcon = ControllerIcon.new()
    XIcon.AdornFrame.Position = UDim2.new(0,0,0,0)
    XIcon.AdornFrame.Size = UDim2.new(0.5,0,0.5,0)
    XIcon.AdornFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
    XIcon.AdornFrame.Parent = ControllerInfoFrame
    XIcon:SetIcon(Enum.KeyCode.ButtonX)

    local XButtonText = Instance.new("TextLabel")
    XButtonText.BackgroundTransparency = 1
    XButtonText.Size = UDim2.new(6,0,1,0)
    XButtonText.Position = UDim2.new(1,0,0,0)
    XButtonText.Font = Enum.Font.SourceSansBold
    XButtonText.TextColor3 = Color3.new(0,0,0)
    XButtonText.TextStrokeColor3 = Color3.new(1,1,1)
    XButtonText.TextStrokeTransparency = 0
    XButtonText.TextScaled = true
    XButtonText.TextXAlignment = Enum.TextXAlignment.Left
    XButtonText.Text = "Move Item"
    XButtonText.Parent = XIcon.Icon

    local BIcon = ControllerIcon.new()
    BIcon.AdornFrame.Position = UDim2.new(0,0,0.5,0)
    BIcon.AdornFrame.Size = UDim2.new(0.5,0,0.5,0)
    BIcon.AdornFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
    BIcon.AdornFrame.Visible = false
    BIcon.AdornFrame.Parent = ControllerInfoFrame
    BIcon:SetIcon(Enum.KeyCode.ButtonB)

    local BButtonText = Instance.new("TextLabel")
    BButtonText.BackgroundTransparency = 1
    BButtonText.Size = UDim2.new(6,0,1,0)
    BButtonText.Position = UDim2.new(1,0,0,0)
    BButtonText.Font = Enum.Font.SourceSansBold
    BButtonText.TextColor3 = Color3.new(0,0,0)
    BButtonText.TextStrokeColor3 = Color3.new(1,1,1)
    BButtonText.TextStrokeTransparency = 0
    BButtonText.TextScaled = true
    BButtonText.TextXAlignment = Enum.TextXAlignment.Left
    BButtonText.Text = "Cancel"
    BButtonText.Parent = BIcon.Icon

    local GridAdorn = Instance.new("Frame")
    GridAdorn.BackgroundTransparency = 1
    GridAdorn.Size = UDim2.new(2/3,0,1,0)
    GridAdorn.Position = UDim2.new(1/3,0,0,0)
    GridAdorn.Parent = InventoryAdorn

    local CurrentPageText = Instance.new("TextLabel")
    CurrentPageText.BackgroundTransparency = 1
    CurrentPageText.Size = UDim2.new(0.1,0,0.075,0)
    CurrentPageText.Position = UDim2.new(0.45,0,1,0)
    CurrentPageText.Font = Enum.Font.SourceSansBold
    CurrentPageText.TextScaled = true
    CurrentPageText.TextColor3 = Color3.new(0,0,0)
    CurrentPageText.TextStrokeColor3 = Color3.new(1,1,1)
    CurrentPageText.TextStrokeTransparency = 0
    CurrentPageText.Text = "1"
    CurrentPageText.ZIndex = 5
    CurrentPageText.TextYAlignment = Enum.TextYAlignment.Top
    CurrentPageText.Parent = GridAdorn

    local PageLeftButton,PageLeftText = BlueTextButtonFactory:Create()
    PageLeftButton.Size = UDim2.new(0.1,0,0.075,0)
    PageLeftButton.Position = UDim2.new(0.35,0,1,0)
    PageLeftButton:MapKey(Enum.KeyCode.ButtonL1,Enum.UserInputType.MouseButton1)
    PageLeftButton.Parent = GridAdorn
    PageLeftText.Text = "<"

    local PageRightButton,PageRightText = BlueTextButtonFactory:Create()
    PageRightButton.Size = UDim2.new(0.1,0,0.075,0)
    PageRightButton.Position = UDim2.new(0.55,0,1,0)
    PageRightButton:MapKey(Enum.KeyCode.ButtonR1,Enum.UserInputType.MouseButton1)
    PageRightButton.Parent = GridAdorn
    PageRightText.Text = ">"

    local CurrentHoveringSlotFrame = nil
    local InitialDragFrame = nil
    local InitialDragSlot = nil
    local MovingItemFrame = nil
    local SlotFrames = {}
    local SlotFrameLookup = {}
    local CurrentPage = 1
    local PlayerInventory = ClientInventory.new(Players.LocalPlayer:WaitForChild("PersistentStats"):WaitForChild("Inventory"))

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
        SlotFrame.Selectable = true
        for Name,Value in pairs(FrameProperties) do
            SlotFrame[Name] = Value
        end
        self.SelectionGroup:AddFrame(SlotFrame)

        local SlotFrameUICorner = Instance.new("UICorner")
        SlotFrameUICorner.CornerRadius = UDim.new(0.1,0)
        SlotFrameUICorner.Parent = SlotFrame

        local HealthBackground = Instance.new("Frame")
        HealthBackground.BorderSizePixel = 0
        HealthBackground.BackgroundColor3 = Color3.new(170/255,0,0)
        HealthBackground.AnchorPoint = Vector2.new(0.5,0.5)
        HealthBackground.Size = UDim2.new(0.9,0,0.05,0)
        HealthBackground.Position = UDim2.new(0.5,0,0.75,0)
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
            HiddenForSlotible = nil,
        }
        SlotFrames[SlotId] = SlotFrameData
        SlotFrameLookup[SlotFrame] = SlotFrameData

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
                local Visible = (self.HiddenForSlot ~= self.Slot)
                self.ArmorIcon.Visible = Visible

                --Update the health.
                if Item.Health and ArmorMaxHealth[Item.Id] then
                    self.HealthBackground.Visible = Visible
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
            self.HiddenForSlot = nil
            self:Update()
        end

        --[[
        Hides the slot.
        --]]
        function SlotFrameData:Hide()
            self.HiddenForSlot = self.Slot
            self:Update()
        end

        --Connect updating the display.
        SlotFrameData:Update()
        PlayerInventory.InventoryChanged:Connect(function()
            SlotFrameData:Update()
        end)

        --Return the slot frame.
        return SlotFrame
    end

    --[[
    Sets the hovered frame.
    --]]
    local function SetHoveredFrame(Frame)
        CurrentHoveringSlotFrame = Frame

        --Update the item information.
        if CurrentHoveringSlotFrame and CurrentHoveringSlotFrame.CurrentItemId then
            local ArmorData = ArmorDataLookup[CurrentHoveringSlotFrame.CurrentItemId]
            ItemNameText.Text = ArmorData.Name
            ItemDescriptionText.Text = ArmorData.Description
            ControllerInfoFrame.Visible = true
        else
            ItemNameText.Text = ""
            ItemDescriptionText.Text = ""
            if not InitialDragFrame then
                ControllerInfoFrame.Visible = false
            end
        end
    end

    --[[
    Cancels dragging the current item.
    --]]
    local function CancelDragging(IgnoreCloseButton)
        if IgnoreCloseButton ~= true then
            --Delay showing the close button (leads to closing after pressing B).
            delay(0,function()
                CloseButton.Visible = true
            end)
        end

        --End the existing drag if one exists.
        if InitialDragFrame then
            InitialDragFrame:Show()
            InitialDragFrame = nil
        end
        if MovingItemFrame then
            MovingItemFrame:Destroy()
            MovingItemFrame = nil
        end
        InitialDragSlot = nil
        XButtonText.Text = "Move Item"
        BIcon.AdornFrame.Visible = false
    end

    --[[
    Starts dragging an item at the starting slot.
    --]]
    local function StartDragging(StartX,StartY)
        --End the existing drag if one exists.
        CancelDragging(true)
        if not CurrentHoveringSlotFrame or not CurrentHoveringSlotFrame.CurrentItemId then return end

        --Start dragging.
        InitialDragFrame = CurrentHoveringSlotFrame
        InitialDragSlot = CurrentHoveringSlotFrame.Slot
        CurrentHoveringSlotFrame:Hide()
        MovingItemFrame = ArmorIcon.new(ArmorModelNames[CurrentHoveringSlotFrame.CurrentItemId])
        MovingItemFrame.AnchorPoint = Vector2.new(0.5,0.5)
        MovingItemFrame.Size = UDim2.new(0,CurrentHoveringSlotFrame.SlotFrame.AbsoluteSize.X,0,CurrentHoveringSlotFrame.SlotFrame.AbsoluteSize.Y)
        MovingItemFrame.Position = UDim2.new(0,StartX,0,StartY)
        MovingItemFrame.Parent = self.AdornFrame
        XButtonText.Text = "Finish"
        BIcon.AdornFrame.Visible = true
    end

    --[[
    Stops dragging the current item.
    --]]
    local function StopDragging()
        CloseButton.Visible = true

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
            InitialDragSlot = nil
            XButtonText.Text = "Move Item"
            BIcon.AdornFrame.Visible = false
            return
        end

        --Attempt to swap the slots.
        PlayerInventory:SwapItems(CurrentHoveringSlotFrame.Slot,InitialDragSlot)
        InitialDragFrame = nil
        InitialDragSlot = nil
        XButtonText.Text = "Move Item"
        BIcon.AdornFrame.Visible = false
    end

    --[[
    Updates the page display.
    --]]
    local function UpdatePages()
        --Determine the max slot and max pages.
        local MaxSlot = 1
        for _,ArmorData in pairs(PlayerInventory.Inventory) do
            if typeof(ArmorData.Slot) == "number" then
                MaxSlot = math.max(MaxSlot,ArmorData.Slot)
            end
        end
        local MaxPage = math.ceil(MaxSlot / (INVENTORY_GRID_SIZE * INVENTORY_GRID_SIZE))

        --Clamp the current page and update the display.
        CurrentPage = math.clamp(CurrentPage,1,MaxPage)
        PageLeftButton.Visible = (CurrentPage ~= 1)
        PageRightButton.Visible = (CurrentPage ~= MaxPage)
        CurrentPageText.Visible = (MaxPage ~= 1)
        CurrentPageText.Text = tostring(CurrentPage)
        for _,SlotFrame in pairs(SlotFrames) do
            SlotFrame:Update()
        end
        SetHoveredFrame(CurrentHoveringSlotFrame)
    end

    --[[
    Updates the size of the store.
    --]]
    local function UpdateSize()
        --Determine how to orient the prompt.
        local ScreenSize = self.AdornFrame.AbsoluteSize
        local UseRelativeXX = (ScreenSize.Y * 0.8 * (3/2) > ScreenSize.X * 0.9)
        local MakeVertical = UseRelativeXX and ScreenSize.X * 0.8 * (3/2) < ScreenSize.Y * 0.9

        --Move the elements.
        if MakeVertical then
            CharacterAdorn.Size = UDim2.new(0.7 * 0.5,0,0.7 * 2/3,0)
            CharacterAdorn.Position = UDim2.new(0.05,0,0.05,0)
            ItemInfoAdorn.Size = UDim2.new(1.6,0,0.4,0)
            ItemInfoAdorn.Position = UDim2.new(1.1,0,0.2,0)
            GridAdorn.Size = UDim2.new(1,0,2/3,0)
            GridAdorn.Position = UDim2.new(0,0,1/3,0)
            CloseButton.AnchorPoint = Vector2.new(1,0)
            CloseButton.Size = UDim2.new(0.05,0,0.05,0)
            CloseButton.Position = UDim2.new(1,0,0.065,0)
        else
            CharacterAdorn.Size = UDim2.new(1/3,0,1,0)
            CharacterAdorn.Position = UDim2.new(0,0,0,0)
            ItemInfoAdorn.Size = UDim2.new(0.9,0,0.3,0)
            ItemInfoAdorn.Position = UDim2.new(0.05,0,0.65,0)
            GridAdorn.Size = UDim2.new(2/3,0,1,0)
            GridAdorn.Position = UDim2.new(1/3,0,0,0)
            CloseButton.AnchorPoint = Vector2.new(0,0.5)
            CloseButton.Size = UDim2.new(0.1,0,0.1,0)
            CloseButton.Position = UDim2.new(1.01,0,0,0)
        end

        --Change the prompt size.
        if UseRelativeXX then
            InventoryAdorn.Size = UDim2.new(0.9,0,0.9 * (MakeVertical and (3/2) or (2/3)),0)
            InventoryAdorn.SizeConstraint = Enum.SizeConstraint.RelativeXX
        else
            InventoryAdorn.Size = UDim2.new(0.8 * (3/2),0,0.8,0)
            InventoryAdorn.SizeConstraint = Enum.SizeConstraint.RelativeYY
        end
    end

    --Create the slots.
    local SlotFramesGrid = {}
    for Y = 1,INVENTORY_GRID_SIZE do
        SlotFramesGrid[Y] = {}
        for X = 1,INVENTORY_GRID_SIZE do
            SlotFramesGrid[Y][X] = CreateItemSlot(((Y - 1) * INVENTORY_GRID_SIZE) + X,{
                AnchorPoint = Vector2.new(0.5,0.5),
                Size = UDim2.new(0.9 * (1/INVENTORY_GRID_SIZE),0,0.9 * (1/INVENTORY_GRID_SIZE),0),
                Position = UDim2.new((X - 0.5) * (1/INVENTORY_GRID_SIZE),0,(Y - 0.5) * (1/INVENTORY_GRID_SIZE),0),
                Parent = GridAdorn,
            })
        end
    end
    local HeadSlotFrame = CreateItemSlot("Head",{
        AnchorPoint = Vector2.new(1,0),
        Size = UDim2.new(0.15,0,0.15,0),
        Position = UDim2.new(1,0,0.025,0),
        Parent = CharacterAdorn,
    })
    local BodySlotFrame = CreateItemSlot("Body",{
        AnchorPoint = Vector2.new(1,0),
        Size = UDim2.new(0.15,0,0.15,0),
        Position = UDim2.new(1,0,0.225,0),
        Parent = CharacterAdorn,
    })
    local LegsSlotFrame = CreateItemSlot("Legs",{
        AnchorPoint = Vector2.new(1,0),
        Size = UDim2.new(0.15,0,0.15,0),
        Position = UDim2.new(1,0,0.425,0),
        Parent = CharacterAdorn,
    })

    --Set up the selection order.
    for Y,Column in pairs(SlotFramesGrid) do
        for X,Frame in pairs(Column) do
            Frame.NextSelectionUp = (SlotFramesGrid[Y - 1] and SlotFramesGrid[Y - 1][X]) or Frame
            Frame.NextSelectionDown = (SlotFramesGrid[Y + 1] and SlotFramesGrid[Y + 1][X]) or Frame
            Frame.NextSelectionLeft = Column[X - 1] or LegsSlotFrame
            Frame.NextSelectionRight = Column[X + 1] or Frame
        end
    end
    SlotFramesGrid[1][1].NextSelectionLeft = HeadSlotFrame
    SlotFramesGrid[2][1].NextSelectionLeft = BodySlotFrame
    HeadSlotFrame.NextSelectionUp = HeadSlotFrame
    HeadSlotFrame.NextSelectionDown = BodySlotFrame
    HeadSlotFrame.NextSelectionLeft = HeadSlotFrame
    HeadSlotFrame.NextSelectionRight = SlotFramesGrid[1][1]
    BodySlotFrame.NextSelectionUp = HeadSlotFrame
    BodySlotFrame.NextSelectionDown = LegsSlotFrame
    BodySlotFrame.NextSelectionLeft = BodySlotFrame
    BodySlotFrame.NextSelectionRight = SlotFramesGrid[2][1]
    LegsSlotFrame.NextSelectionUp = BodySlotFrame
    LegsSlotFrame.NextSelectionDown = LegsSlotFrame
    LegsSlotFrame.NextSelectionLeft = LegsSlotFrame
    LegsSlotFrame.NextSelectionRight = SlotFramesGrid[3][1]

    --Connect the mouse events.
    UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        --Update the current hovering frame.
        local NewHoveringSlotFrame = nil
        for _,SlotFrame in pairs(SlotFrames) do
            local FramePosition,FrameSize = SlotFrame.SlotFrame.AbsolutePosition,SlotFrame.SlotFrame.AbsoluteSize
            if Input.Position.X >= FramePosition.X and Input.Position.X <= FramePosition.X + FrameSize.X and Input.Position.Y >= FramePosition.Y and Input.Position.Y <= FramePosition.Y + FrameSize.Y then
                NewHoveringSlotFrame = SlotFrame
            end
        end
        SetHoveredFrame(NewHoveringSlotFrame)

        --Update the drag frame.
        if MovingItemFrame then
            MovingItemFrame.Position = UDim2.new(0,Input.Position.X,0,Input.Position.Y)
        end

        --Show the close button (may override controller selection).
        CloseButton.Visible = true
    end)
    UserInputService.InputBegan:Connect(function(Input,Processed)
        if Processed then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        StartDragging(Input.Position.X,Input.Position.Y)
    end)
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        StopDragging()
    end)

    --Connect the gamepad events.
    UserInputService.InputBegan:Connect(function(Input,Processed)
        if not self:IsOpen() then return end
        if Processed then return end

        if Input.KeyCode == Enum.KeyCode.ButtonX and CurrentHoveringSlotFrame then
            if InitialDragFrame then
                --Stop dragging the current frame.
                StopDragging()
            else
                --Start dragging the current frame.
                local SlotFrame = CurrentHoveringSlotFrame
                if SlotFrame and SlotFrame.CurrentItemId then
                    CloseButton.Visible = false
                    local SlotFramePosition,SlotFrameSize = SlotFrame.SlotFrame.AbsolutePosition,SlotFrame.SlotFrame.AbsoluteSize
                    StartDragging(SlotFramePosition.X + (SlotFrameSize.X/2),SlotFramePosition.Y + (SlotFrameSize.Y/2))
                end
            end
        elseif Input.KeyCode == Enum.KeyCode.ButtonB then
            --Cancel the dragging.
            CancelDragging()
        end
    end)
    GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
        if GuiService.SelectedObject and SlotFrameLookup[GuiService.SelectedObject] then
            --Set the hovered frame.
            SetHoveredFrame(SlotFrameLookup[GuiService.SelectedObject])

            --Update the dragging item position.
            local SlotFrame = CurrentHoveringSlotFrame
            if MovingItemFrame and SlotFrame then
                local SlotFramePosition,SlotFrameSize = SlotFrame.SlotFrame.AbsolutePosition,SlotFrame.SlotFrame.AbsoluteSize
                MovingItemFrame.Position = UDim2.new(0,SlotFramePosition.X + (SlotFrameSize.X/2),0,SlotFramePosition.Y + (SlotFrameSize.Y/2))
            end
        end
    end)

    --Connect changing pages.
    PageLeftButton.MouseButton1Down:Connect(function()
        if not self:IsOpen() then return end
        CurrentPage = CurrentPage - 1
        UpdatePages()
    end)
    PageRightButton.MouseButton1Down:Connect(function()
        if not self:IsOpen() then return end
        CurrentPage = CurrentPage + 1
        UpdatePages()
    end)
    PlayerInventory.InventoryChanged:Connect(function()
        UpdatePages()
    end)
    UpdatePages()

    --Connect closing.
    CloseButton.MouseButton1Down:Connect(function()
        if not CloseButton.Visible or not self:IsOpen() then return end
        self:Close()
    end)

    --Connect updating the size.
    self.AdornFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    UpdateSize()
end



return InventoryPrompt