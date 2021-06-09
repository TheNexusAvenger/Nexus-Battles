--[[
TheNexusAvenger

Base entry for the player list.
--]]

local TEXT_SIZE_MULTIPLIER = 0.85
local STAT_TEXT_ASPECT_RATIO = 1.8
local TRIANGLE_ASPECT_RATIO = 0.2
local BORDER_ASPECT_RATIO_SPACE = 0.5
local TRIANGLE_TEXTURES = "rbxassetid://4449507744"
local TRIANGLE_TEXTURE_SIZE = Vector2.new(512,512)
local BOTTOM_LEFT_TRIANGLE_OFFSET = Vector2.new(0,512)
local TOP_RIGHT_TRIANGLE_OFFSET = Vector2.new(512,0)



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local NexusInstance = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance")
local RankIcon = ReplicatedStorageProject:GetResource("UI.Icon.RankIcon")

local BaseEntry = NexusInstance:Extend()
BaseEntry:SetClassName("BaseEntry")



--[[
Creates the base entry.
--]]
function BaseEntry:__new()
    self:InitializeSuper()

    --Create the default frames.
    local AdornFrame = Instance.new("Frame")
    AdornFrame.Size = UDim2.new(1,0,1,0)
    AdornFrame.BackgroundTransparency = 1
    self.AdornFrame = AdornFrame

    local BorderBottomLeftTriangle = Instance.new("ImageLabel")
    BorderBottomLeftTriangle.BackgroundTransparency = 1
    BorderBottomLeftTriangle.Image = TRIANGLE_TEXTURES
    BorderBottomLeftTriangle.ImageRectSize = TRIANGLE_TEXTURE_SIZE
    BorderBottomLeftTriangle.ImageRectOffset = BOTTOM_LEFT_TRIANGLE_OFFSET
    BorderBottomLeftTriangle.Parent = AdornFrame
    self.BorderBottomLeftTriangle = BorderBottomLeftTriangle

    local BorderTopRightTriangle = Instance.new("ImageLabel")
    BorderTopRightTriangle.BackgroundTransparency = 1
    BorderTopRightTriangle.Image = TRIANGLE_TEXTURES
    BorderTopRightTriangle.ImageRectSize = TRIANGLE_TEXTURE_SIZE
    BorderTopRightTriangle.ImageRectOffset = TOP_RIGHT_TRIANGLE_OFFSET
    BorderTopRightTriangle.Parent = AdornFrame
    self.BorderTopRightTriangle = BorderTopRightTriangle

    local BottomLeftTriangle = Instance.new("ImageLabel")
    BottomLeftTriangle.BackgroundTransparency = 1
    BottomLeftTriangle.Image = TRIANGLE_TEXTURES
    BottomLeftTriangle.ImageRectSize = TRIANGLE_TEXTURE_SIZE
    BottomLeftTriangle.ImageRectOffset = BOTTOM_LEFT_TRIANGLE_OFFSET
    BottomLeftTriangle.Parent = AdornFrame
    self.BottomLeftTriangle = BottomLeftTriangle

    local TopRightTriangle = Instance.new("ImageLabel")
    TopRightTriangle.BackgroundTransparency = 1
    TopRightTriangle.Image = TRIANGLE_TEXTURES
    TopRightTriangle.ImageRectSize = TRIANGLE_TEXTURE_SIZE
    TopRightTriangle.ImageRectOffset = TOP_RIGHT_TRIANGLE_OFFSET
    TopRightTriangle.Parent = AdornFrame
    self.TopRightTriangle = TopRightTriangle

    local CenterFillFrame = Instance.new("Frame")
    CenterFillFrame.Size = UDim2.new(1,0,1,0)
    CenterFillFrame.BorderSizePixel = 0
    CenterFillFrame.Parent = AdornFrame
    self.CenterFillFrame = CenterFillFrame
    self.StatLabels = {}

    local PlayerRankIconImage = Instance.new("ImageLabel")
    PlayerRankIconImage.BackgroundTransparency = 1
    PlayerRankIconImage.Image = ""
    PlayerRankIconImage.Size = UDim2.new(0.8,0,0.8,0)
    PlayerRankIconImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
    PlayerRankIconImage.Parent = self.CenterFillFrame
    self.PlayerRankIconImage = PlayerRankIconImage

    local PlayerRankIcon = RankIcon.new(PlayerRankIconImage)
    self.PlayerRankIcon = PlayerRankIcon

    local MainText = Instance.new("TextLabel")
    MainText.BackgroundTransparency = 1
    MainText.Font = "SourceSansBold"
    MainText.TextColor3 = Color3.new(1,1,1)
    MainText.TextStrokeColor3 = Color3.new(0,0,0)
    MainText.TextStrokeTransparency = 0
    MainText.TextXAlignment = Enum.TextXAlignment.Left
    MainText.TextTruncate = Enum.TextTruncate.AtEnd
    MainText.Parent = self.CenterFillFrame
    self.MainText = MainText

    --Connect the events.
    AdornFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local AdornSize = self.AdornFrame.AbsoluteSize
        local AdornSizeX,AdornSizeY = math.floor(AdornSize.X + 0.5),math.floor(AdornSize.Y + 0.5)
        local TriangleSizeX = math.floor((AdornSizeY * TRIANGLE_ASPECT_RATIO) + 0.5)

        --Update the size of the frames.
        self.BorderBottomLeftTriangle.Size = UDim2.new(0,TriangleSizeX,0,AdornSizeY)
        self.BorderTopRightTriangle.Size = UDim2.new(0,TriangleSizeX,0,AdornSizeY)
        self.BottomLeftTriangle.Size = UDim2.new(0,TriangleSizeX,0,AdornSizeY)
        self.TopRightTriangle.Size = UDim2.new(0,TriangleSizeX,0,AdornSizeY)
        self.CenterFillFrame.Size = UDim2.new(0,AdornSizeX - (2 * TriangleSizeX),0,AdornSizeY)

        --Update the position of the frames.
        self.BorderBottomLeftTriangle.Position = UDim2.new(0,-(1 + BORDER_ASPECT_RATIO_SPACE) * TriangleSizeX,0,0)
        self.BorderTopRightTriangle.Position = UDim2.new(0,-BORDER_ASPECT_RATIO_SPACE * TriangleSizeX,0,0)
        self.TopRightTriangle.Position = UDim2.new(0,AdornSizeX - TriangleSizeX,0,0)
        self.CenterFillFrame.Position = UDim2.new(0,TriangleSizeX,0,0)

        --Update the text size.
        self:UpdateTextSize()
    end)
    self:AddPropertyFinalizer("Parent",function(_,Parent)
        self.AdornFrame.Parent = Parent
    end)
    self:AddPropertyFinalizer("BackgroundColor3",function(_,BackgroundColor3)
        self.BottomLeftTriangle.ImageColor3 = BackgroundColor3
        self.TopRightTriangle.ImageColor3 = BackgroundColor3
        self.CenterFillFrame.BackgroundColor3 = BackgroundColor3
    end)
    self:AddPropertyFinalizer("BorderColor3",function(_,BorderColor3)
        self.BorderBottomLeftTriangle.ImageColor3 = BorderColor3
        self.BorderTopRightTriangle.ImageColor3 = BorderColor3
    end)
    self:AddPropertyFinalizer("BackgroundTransparency",function(_,BackgroundTransparency)
        self.BottomLeftTriangle.ImageTransparency = BackgroundTransparency
        self.TopRightTriangle.ImageTransparency = BackgroundTransparency
        self.CenterFillFrame.BackgroundTransparency = BackgroundTransparency
    end)
    self:AddPropertyFinalizer("BorderTransparency",function(_,BorderTransparency)
        self.BorderBottomLeftTriangle.ImageTransparency = BorderTransparency
        self.BorderTopRightTriangle.ImageTransparency = BorderTransparency
    end)
    self:AddPropertyFinalizer("TotalStats",function(_,TotalStats)
        --Create the additional text labels.
        for _ = #self.StatLabels,TotalStats - 1 do
            local NewTextLabel = Instance.new("TextLabel")
            NewTextLabel.BackgroundTransparency = 1
            NewTextLabel.Font = "SourceSansBold"
            NewTextLabel.TextColor3 = self.TextColor3
            NewTextLabel.TextStrokeColor3 = Color3.new(0,0,0)
            NewTextLabel.TextStrokeTransparency = 0
            NewTextLabel.ClipsDescendants = true
            NewTextLabel.Parent = self.CenterFillFrame
            table.insert(self.StatLabels,NewTextLabel)
        end

        --Remove extra text labels.
        for i = #self.StatLabels,TotalStats + 1,-1 do
            table.remove(self.StatLabels,i):Destroy()
        end

        --Update the text size.
        self:UpdateTextSize()
    end)
    self:AddPropertyFinalizer("TextColor3",function(_,TextColor3)
        for _,StatLabel in pairs(self.StatLabels) do
            StatLabel.TextColor3 = TextColor3
        end
        self.MainText.TextColor3 = TextColor3
    end)

    --Set the defaults.
    self.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
    self.BorderColor3 = Color3.new(1,1,1)
    self.TextColor3 = Color3.new(1,1,1)
    self.BackgroundTransparency = 0.6
    self.BorderTransparency = 0.4
    self.TotalStats = 0
end

--[[
Updates the size of the text.
--]]
function BaseEntry:UpdateTextSize()
    --Get the size.
    local FillSize = self.CenterFillFrame.AbsoluteSize
    local FillSizeX,FillSizeY = FillSize.X,FillSize.Y

    --Update the size of the stats.
    local StatStartPositionX = FillSizeX - (#self.StatLabels * STAT_TEXT_ASPECT_RATIO * FillSizeY)
    for i,StatLabel in pairs(self.StatLabels) do
        StatLabel.Size = UDim2.new(0,FillSizeY * STAT_TEXT_ASPECT_RATIO,0,FillSizeY)
        StatLabel.Position = UDim2.new(0,StatStartPositionX + (FillSizeY * STAT_TEXT_ASPECT_RATIO * (i - 1)),0,0)
        StatLabel.TextSize = FillSizeY * TEXT_SIZE_MULTIPLIER
    end

    --Update the size of the main text.
    self.MainText.Size = UDim2.new(0,StatStartPositionX - FillSizeY,0,FillSizeY)
    self.MainText.Position = UDim2.new(0,FillSizeY,0,0)
    self.MainText.TextSize = FillSizeY * TEXT_SIZE_MULTIPLIER
    self.PlayerRankIconImage.Position = UDim2.new(0,FillSizeY * 0.1,0,FillSizeY * 0.1)
end

--[[
Destroys the base entry.
--]]
function BaseEntry:Destroy()
    self.super:Destroy()
    self.AdornFrame:Destroy()
    self.PlayerRankIcon:Destroy()
end



return BaseEntry