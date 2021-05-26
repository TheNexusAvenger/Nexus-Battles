--[[
TheNexusAvenger

Displays the rank information at the end of a round.
--]]

local INITIAL_ANIMATION_DELAY = 0.5
local MAX_PROGRESS_BAR_FILL_TIME = 1
local PROGRESS_BAR_TO_BONUSES_DELAY = 0.25
local BONUSES_DISPLAY_TIME = 0.5
local BONUS_MESSAGE_RELATIVE_HEIGHT = 0.06



local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local RankIcons = ReplicatedStorageProject:GetResource("Data.RankIcons")
table.sort(RankIcons.Normal,function(a,b) return a.RankScore < b.RankScore end)

local RoundEndRank = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
RoundEndRank:SetClassName("RoundEndRank")



--[[
Creates the round end rank information.
--]]
function RoundEndRank:__new(ContainerFrame,StartRankScore,EndRankScore,Bonuses)
    self:InitializeSuper()

    --Determine the current and next rank.
    local CurrentRankId = 1
    for i,RankData in pairs(RankIcons.Normal) do
        if EndRankScore >= RankData.RankScore then
            CurrentRankId = i
        end
    end
    local CurrentRankData = RankIcons.Normal[CurrentRankId]
    local NextRankData = RankIcons.Normal[CurrentRankId + 1]
    if NextRankData then
        self.PreviousFill = math.clamp((StartRankScore - CurrentRankData.RankScore)/(NextRankData.RankScore - CurrentRankData.RankScore),0,1)
        self.NextFill = math.clamp((EndRankScore - CurrentRankData.RankScore)/(NextRankData.RankScore - CurrentRankData.RankScore),0,1)
    else
        self.PreviousFill = 1
        self.NextFill = 1
    end

    --Store the container.
    self.ContainerFrame = ContainerFrame

    --Create the UI components.
    local CurrentRankImage = Instance.new("ImageLabel")
    CurrentRankImage.BackgroundTransparency = 1
    CurrentRankImage.AnchorPoint = Vector2.new(0.5,0)
    CurrentRankImage.Size = UDim2.new(0.8,0,0.8,0)
    CurrentRankImage.Position = UDim2.new(0.5,0,0.025,0)
    CurrentRankImage.Image = CurrentRankData.Image
    CurrentRankImage.ImageRectSize = CurrentRankData.Size
    CurrentRankImage.ImageRectOffset = CurrentRankData.Position
    CurrentRankImage.ImageColor3 = CurrentRankData.Color
    CurrentRankImage.Parent = ContainerFrame
    self.CurrentRankImage = CurrentRankImage

    local CurrentRankText = Instance.new("TextLabel")
    CurrentRankText.BackgroundTransparency = 1
    CurrentRankText.Size = UDim2.new(1,0,0.3,0)
    CurrentRankText.Position = UDim2.new(0,0,0.7,0)
    CurrentRankText.Font = Enum.Font.SourceSansBold
    CurrentRankText.TextScaled = true
    CurrentRankText.Text = "RANK "..tostring(CurrentRankId)
    CurrentRankText.TextColor3 = CurrentRankData.Color
    CurrentRankText.TextStrokeTransparency = 0
    CurrentRankText.TextStrokeColor3 = Color3.new(0,0,0)
    CurrentRankText.Parent = CurrentRankImage

    local RankProgressBarBack = Instance.new("Frame")
    RankProgressBarBack.BackgroundTransparency = 0.5
    RankProgressBarBack.BackgroundColor3 = Color3.new(0,0,0)
    RankProgressBarBack.Size = UDim2.new(0.9,0,0.025,0)
    RankProgressBarBack.Position = UDim2.new(0.05,0,0.95,0)
    RankProgressBarBack.Parent = ContainerFrame
    self.RankProgressBarBack = RankProgressBarBack

    local RankProgressBarBackUICorner = Instance.new("UICorner")
    RankProgressBarBackUICorner.CornerRadius = UDim.new(0.5,0)
    RankProgressBarBackUICorner.Parent = RankProgressBarBack

    local RankProgressBarPrevious = Instance.new("Frame")
    RankProgressBarPrevious.BackgroundColor3 = Color3.new(0,170/255,255/255)
    RankProgressBarPrevious.Size = UDim2.new(0,0,1,0)
    RankProgressBarPrevious.ZIndex = 3
    RankProgressBarPrevious.Parent = RankProgressBarBack
    self.RankProgressBarPrevious = RankProgressBarPrevious

    local RankProgressBarPreviousUICorner = Instance.new("UICorner")
    RankProgressBarPreviousUICorner.CornerRadius = UDim.new(0.5,0)
    RankProgressBarPreviousUICorner.Parent = RankProgressBarPrevious

    local RankProgressBarNew = Instance.new("Frame")
    RankProgressBarNew.BackgroundColor3 = Color3.new(0,255/255,0)
    RankProgressBarNew.Size = UDim2.new(0,0,1,0)
    RankProgressBarNew.Parent = RankProgressBarBack
    self.RankProgressBarNew = RankProgressBarNew

    local RankProgressBarNewUICorner = Instance.new("UICorner")
    RankProgressBarNewUICorner.CornerRadius = UDim.new(0.5,0)
    RankProgressBarNewUICorner.Parent = RankProgressBarNew

    local NextRankText = Instance.new("TextLabel")
    NextRankText.BackgroundTransparency = 1
    NextRankText.Size = UDim2.new(1,0,4,0)
    NextRankText.Position = UDim2.new(0,0,-4,0)
    NextRankText.Font = Enum.Font.SourceSansBold
    NextRankText.TextScaled = true
    NextRankText.Text = (NextRankData and "NEXT RANK" or "AT MAX RANK")
    NextRankText.TextColor3 = Color3.new(1,1,1)
    NextRankText.TextStrokeTransparency = 0
    NextRankText.TextStrokeColor3 = Color3.new(0,0,0)
    NextRankText.Parent = RankProgressBarBack

    local BonusMessagesContainer = Instance.new("Frame")
    BonusMessagesContainer.BackgroundTransparency = 1
    BonusMessagesContainer.AnchorPoint = Vector2.new(0,1)
    BonusMessagesContainer.Size = UDim2.new(1,0,0,0)
    BonusMessagesContainer.Position = UDim2.new(0,0,1,0)
    BonusMessagesContainer.Visible = false
    BonusMessagesContainer.Parent = ContainerFrame
    self.BonusMessagesContainer = BonusMessagesContainer

    Bonuses = Bonuses or {}
    for i,BonusData in pairs(Bonuses) do
        local BonusMessageText = Instance.new("TextLabel")
        BonusMessageText.BackgroundTransparency = 1
        BonusMessageText.Size = UDim2.new(1,0,1/#Bonuses,0)
        BonusMessageText.Position = UDim2.new(0,0,(i - 1)/#Bonuses,0)
        BonusMessageText.Font = Enum.Font.SourceSansBold
        BonusMessageText.TextScaled = true
        BonusMessageText.Text = BonusData.Message
        BonusMessageText.TextColor3 = Color3.new(0,170/255,0)
        BonusMessageText.TextStrokeTransparency = 0
        BonusMessageText.TextStrokeColor3 = Color3.new(0,0,0)
        BonusMessageText.Parent = BonusMessagesContainer
    end
end

--[[
Animates the view in the background
--]]
function RoundEndRank:Animate()
    coroutine.wrap(function()
        --Wait to animate the view.
        wait(INITIAL_ANIMATION_DELAY)
        if not self.CurrentRankImage.Parent then return end

        --Show the progress bars.
        self.RankProgressBarPrevious:TweenSize(UDim2.new(self.PreviousFill,0,1,0),"InOut","Quad",self.PreviousFill * MAX_PROGRESS_BAR_FILL_TIME)
        self.RankProgressBarNew:TweenSize(UDim2.new(self.NextFill,0,1,0),"InOut","Quad",self.NextFill * MAX_PROGRESS_BAR_FILL_TIME)
        wait(math.max(self.PreviousFill * MAX_PROGRESS_BAR_FILL_TIME,self.NextFill * MAX_PROGRESS_BAR_FILL_TIME) + PROGRESS_BAR_TO_BONUSES_DELAY)
        if not self.CurrentRankImage.Parent or #self.BonusMessagesContainer:GetChildren() == 0 then return end

        --Show the bonuses.
        local TotalBonusMessagesHeight = #self.BonusMessagesContainer:GetChildren() * BONUS_MESSAGE_RELATIVE_HEIGHT
        self.BonusMessagesContainer.Visible = true
        self.BonusMessagesContainer:TweenSize(UDim2.new(1,0,TotalBonusMessagesHeight,0),"InOut","Quad",BONUSES_DISPLAY_TIME)
        self.CurrentRankImage:TweenSize(UDim2.new(0.8 - TotalBonusMessagesHeight,0,0.8 - TotalBonusMessagesHeight,0),"InOut","Quad",BONUSES_DISPLAY_TIME)
        self.RankProgressBarBack:TweenPosition(UDim2.new(0.05,0,0.95 - TotalBonusMessagesHeight,0),"InOut","Quad",BONUSES_DISPLAY_TIME)
    end)()
end

--[[
Destroys the rank icon.
--]]
function RoundEndRank:Destroy()
    self.CurrentRankImage:Destroy()
    self.RankProgressBarBack:Destroy()
    self.BonusMessagesContainer:Destroy()
end



return RoundEndRank