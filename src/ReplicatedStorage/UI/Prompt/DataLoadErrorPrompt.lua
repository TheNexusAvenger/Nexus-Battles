--[[
TheNexusAvenger

Prompt for alerting the player their data didn't load.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CutFrame = ReplicatedStorageProject:GetResource("External.NexusButton.Gui.CutFrame")
local RedTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(170/255,0,0))

local DataLoadErorPrompt = ReplicatedStorageProject:GetResource("UI.Prompt.BasePrompt"):Extend()
DataLoadErorPrompt:SetClassName("DataLoadErorPrompt")



--[[
Creates the base prompt.
--]]
function DataLoadErorPrompt:__new()
    self:InitializeSuper("DataLoadErorPrompt")

    --Create the prompt.
    local PromptBackground = Instance.new("Frame")
    PromptBackground.BackgroundTransparency = 1
    PromptBackground.AnchorPoint = Vector2.new(0.5,0.5)
    PromptBackground.Position = UDim2.new(0.5,0,0.5,0)
    PromptBackground.Size = UDim2.new(0.6,0,0.3,0)
    PromptBackground.SizeConstraint = Enum.SizeConstraint.RelativeYY
    PromptBackground.Parent = self.AdornFrame

    local PurchaseBackground = CutFrame.new(PromptBackground)
    PurchaseBackground.BackgroundTransparency = 0.5
    PurchaseBackground.BackgroundColor3 = Color3.new(1,1,1)
    PurchaseBackground:CutCorner("Top","Left",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeYY)
    PurchaseBackground:CutCorner("Bottom","Right",UDim2.new(0.1,0,0.1,0),Enum.SizeConstraint.RelativeYY)

    local PromptText = Instance.new("TextLabel")
    PromptText.BackgroundTransparency = 1
    PromptText.Size = UDim2.new(0.95,0,0.95,0)
    PromptText.Position = UDim2.new(0.025,0,0.025,0)
    PromptText.Font = Enum.Font.SourceSansBold
    PromptText.Text = "Your data failed to load. You can still play, but any progress you make won't save. Rejoining the game may fix this."
    PromptText.TextScaled = true
    PromptText.TextColor3 = Color3.new(0,0,0)
    PromptText.TextStrokeColor3 = Color3.new(1,1,1)
    PromptText.TextStrokeTransparency = 0
    PromptText.ZIndex = 5
    PromptText.Parent = PromptBackground

    local CloseButton,CloseText = RedTextButtonFactory:Create()
    CloseButton.Size = UDim2.new(0.7,0,0.15,0)
    CloseButton.Position = UDim2.new(0.5,0,1.1,0)
    CloseButton.AnchorPoint = Vector2.new(0.5,0)
    CloseButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    CloseButton:SetControllerIcon(Enum.KeyCode.ButtonB)
    CloseButton:MapKey(Enum.KeyCode.ButtonB,Enum.UserInputType.MouseButton1)
    CloseButton.Parent = PromptBackground
    CloseText.Text = "CLOSE"

    --Connect closing.
    CloseButton.MouseButton1Down:Connect(function()
        if not self:IsOpen() then return end
        self:Destroy()
    end)
end



return DataLoadErorPrompt