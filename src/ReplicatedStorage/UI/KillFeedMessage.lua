--[[
TheNexusAvenger

Message for a killfeed.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local WeaponIcon = ReplicatedStorageProject:GetResource("UI.Icon.WeaponIcon")

local KillFeedMessage = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
KillFeedMessage:SetClassName("KillFeedMessage")



--[[
Creates the kill feed message.
--]]
function KillFeedMessage:__new(KillFeedData)
    self:InitializeSuper()

    --Convert the message for a self-kill.
    if KillFeedData.KilledPlayer and not KillFeedData.KillingPlayer then
        KillFeedData = {
            Message = tostring(KillFeedData.KilledPlayer).." BLOXXED themself!"
        }
    end

    --Create the message.
    if KillFeedData.Message then
        local Message = Instance.new("TextLabel")
        Message.AnchorPoint = Vector2.new(1,0)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.SourceSansBold
        Message.TextColor3 = Color3.new(1,1,1)
        Message.TextStrokeColor3 = Color3.new(0,0,0)
        Message.TextStrokeTransparency = 0
        Message.Text = KillFeedData.Message
        self.MessageFrame = Message

        --Connect the resize event.
        self:AddPropertyFinalizer("HeightPixels",function(_,HeightPixels)
            local MessageSizeBounds = TextService:GetTextSize(KillFeedData.Message,HeightPixels,Enum.Font.SourceSansBold,Vector2.new(10000,HeightPixels))
            Message.TextSize = HeightPixels
            Message.Size = UDim2.new(0,MessageSizeBounds.X + 10,0,HeightPixels)
        end)
    else
        local AdornFrame = Instance.new("Frame")
        AdornFrame.AnchorPoint = Vector2.new(1,0)
        AdornFrame.BackgroundTransparency = 1
        self.MessageFrame = AdornFrame

        local KillingPlayerText = Instance.new("TextLabel")
        KillingPlayerText.BackgroundTransparency = 1
        KillingPlayerText.Font = Enum.Font.SourceSansBold
        KillingPlayerText.TextColor3 = Color3.new(1,1,1)
        KillingPlayerText.TextStrokeColor3 = Color3.new(0,0,0)
        KillingPlayerText.TextStrokeTransparency = 0
        KillingPlayerText.Text = KillFeedData.KillingPlayer.DisplayName
        KillingPlayerText.Parent = AdornFrame

        local KillingWeaponIcon = WeaponIcon.new(KillFeedData.MostDamageTool)
        KillingWeaponIcon.Parent = AdornFrame
        self.KillingWeaponIcon = KillingWeaponIcon

        local KilledPlayerText = Instance.new("TextLabel")
        KilledPlayerText.BackgroundTransparency = 1
        KilledPlayerText.Font = Enum.Font.SourceSansBold
        KilledPlayerText.TextColor3 = Color3.new(1,1,1)
        KilledPlayerText.TextStrokeColor3 = Color3.new(0,0,0)
        KilledPlayerText.TextStrokeTransparency = 0
        KilledPlayerText.Text = KillFeedData.KilledPlayer.DisplayName
        KilledPlayerText.Parent = AdornFrame

        --Connect the resize event.
        self:AddPropertyFinalizer("HeightPixels",function(_,HeightPixels)
            local KillingPlayerSizeBounds = TextService:GetTextSize(KillFeedData.KillingPlayer.DisplayName,HeightPixels,Enum.Font.SourceSansBold,Vector2.new(10000,HeightPixels))
            local KilledPlayerSizeBounds = TextService:GetTextSize(KillFeedData.KilledPlayer.DisplayName,HeightPixels,Enum.Font.SourceSansBold,Vector2.new(10000,HeightPixels))

            KillingPlayerText.Size = UDim2.new(0,KillingPlayerSizeBounds.X + 10,0,HeightPixels)
            KillingPlayerText.TextSize = HeightPixels
            KillingWeaponIcon.Size = UDim2.new(0,HeightPixels,0,HeightPixels)
            KillingWeaponIcon.Position = UDim2.new(0,KillingPlayerSizeBounds.X + 10,0,0)
            KilledPlayerText.Size = UDim2.new(0,KilledPlayerSizeBounds.X + 10,0,HeightPixels)
            KilledPlayerText.Position = UDim2.new(0,KillingPlayerSizeBounds.X + HeightPixels + 10,0,0)
            KilledPlayerText.TextSize = HeightPixels
            AdornFrame.Size = UDim2.new(0,KillingPlayerSizeBounds.X + KilledPlayerSizeBounds.Y + HeightPixels + 20,0,HeightPixels)
        end)
    end

    --Connect the events.
    self:AddPropertyFinalizer("Parent",function(_,Parent)
        self.MessageFrame.Parent = Parent
    end)
end

--[[
Sets the Y position.
--]]
function KillFeedMessage:SetYPosition(RelativeY,Instant)
    if Instant then
        self.MessageFrame.Position = UDim2.new(0,0,RelativeY,0)
    else
        TweenService:Create(self.MessageFrame,TweenInfo.new(0.5),{
            Position = UDim2.new(0,0,RelativeY,0),
        }):Play()
    end
end

--[[
Shows the message.
--]]
function KillFeedMessage:Show()
    TweenService:Create(self.MessageFrame,TweenInfo.new(0.5),{
        AnchorPoint = Vector2.new(0,0),
    }):Play()
end

--[[
Hides the message and destroys it.
--]]
function KillFeedMessage:Hide()
    TweenService:Create(self.MessageFrame,TweenInfo.new(0.5),{
        AnchorPoint = Vector2.new(1,0),
    }):Play()
    delay(0.5,function()
        self:Destroy()
    end)
end

--[[
Destroys the text timer.
--]]
function KillFeedMessage:Destroy()
    self.super:Destroy()
    self.MessageFrame:Destroy()
    if self.KillingWeaponIcon then
        self.KillingWeaponIcon:Destroy()
    end
end



return KillFeedMessage