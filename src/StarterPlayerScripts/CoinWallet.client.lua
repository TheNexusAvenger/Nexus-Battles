--[[
TheNexusAvenger

Displays the coins of the player.
--]]

--TODO: Add coin collect sound?

local COIN_WIDTH = 1.5
local COIN_TRAVEL_TIME_SCREEN_WIDTH_MULTIPLIER = 0.5
local MAX_COIN_SCREEN_HEIGHT = 0.3



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PersistentStats = Players.LocalPlayer:WaitForChild("PersistentStats")
local CoinsValue = PersistentStats:WaitForChild("Coins")



local UpdateCoinsEvent = Instance.new("BindableEvent")
UpdateCoinsEvent.Name = "UpdateCoins"
UpdateCoinsEvent.Parent = script

local DisplayCoinsUpdateEvent = Instance.new("BindableEvent")
DisplayCoinsUpdateEvent.Name = "DisplayCoinsUpdate"
DisplayCoinsUpdateEvent.Parent = script

local DisplayWorldSpaceCoinEvent = Instance.new("BindableEvent")
DisplayWorldSpaceCoinEvent.Name = "DisplayWorldSpaceCoin"
DisplayWorldSpaceCoinEvent.Parent = script

local CoinWalletContainer = Instance.new("ScreenGui")
CoinWalletContainer.Name = "CoinWallet"
CoinWalletContainer.ResetOnSpawn = false
CoinWalletContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local CoinImage = Instance.new("ImageLabel")
CoinImage.BackgroundTransparency = 1
CoinImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
CoinImage.Size = UDim2.new(0.1,0,0.1,0)
CoinImage.Position = UDim2.new(0.005,0,0.49,0)
CoinImage.Image = "rbxassetid://121148238"
CoinImage.Parent = CoinWalletContainer

local CoinCount = Instance.new("TextLabel")
CoinCount.BackgroundTransparency = 1
CoinCount.AnchorPoint = Vector2.new(0.5,0.5)
CoinCount.Position = UDim2.new(0.5,0,0.5,0)
CoinCount.Size = UDim2.new(0.95,0,0.7,0)
CoinCount.ZIndex = 5
CoinCount.Font = Enum.Font.ArialBold
CoinCount.Text = tostring(CoinsValue.Value)
CoinCount.TextScaled = true
CoinCount.TextColor3 = Color3.new(231/255,193/255,0)
CoinCount.TextStrokeColor3 = Color3.new(0,0,0)
CoinCount.TextStrokeTransparency = 0
CoinCount.Parent = CoinImage



--[[
Flashes a coin and updates the count.
--]]
local function FlashCoins(AddedCoins)
    AddedCoins = AddedCoins or math.huge

    --Update the text.
    local CurrentDisplayedCoins = tonumber(CoinCount.Text)
    CoinCount.Text = math.min(CurrentDisplayedCoins + AddedCoins,CoinsValue.Value)

    --Create the coin to flash.
    local FlashCoinImage = Instance.new("ImageLabel")
    FlashCoinImage.AnchorPoint = Vector2.new(0.5,0.5)
    FlashCoinImage.BackgroundTransparency = 1
    FlashCoinImage.ImageTransparency = 0.5
    FlashCoinImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
    FlashCoinImage.Size = UDim2.new(1,0,1,0)
    FlashCoinImage.Position = UDim2.new(0.5,0,0.5,0)
    FlashCoinImage.Image = "rbxassetid://121148238"
    FlashCoinImage.Parent = CoinImage

    local FlashCoinScale = Instance.new("UIScale")
    FlashCoinScale.Parent = FlashCoinImage

    --Flash the coins.
    TweenService:Create(FlashCoinImage,TweenInfo.new(0.25),{
        ImageTransparency = 1,
    }):Play()
    TweenService:Create(FlashCoinScale,TweenInfo.new(0.25),{
        Scale = 1.5,
    }):Play()
    wait(0.25)
    FlashCoinImage:Destroy()
end

--[[
Converts a world position to a screen position.
--]]
local function WorldToScreenPoint(Position)
    local ScreenPosition,_ = Workspace.CurrentCamera:WorldToScreenPoint(Position)
    return ScreenPosition
end

--[[
Shows a coin animated in local space.
--]]
local function ShowLocalCoin(AddedCoins,PosX,PosY,Width)
    --camp the width.
    local ScreenHeight = CoinWalletContainer.AbsoluteSize.Y
    if Width > ScreenHeight * MAX_COIN_SCREEN_HEIGHT then
        Width = ScreenHeight * MAX_COIN_SCREEN_HEIGHT
    end

    --Create the coin.
    local MovingCoinImage = Instance.new("ImageLabel")
    MovingCoinImage.AnchorPoint = Vector2.new(0.5,0.5)
    MovingCoinImage.BackgroundTransparency = 1
    MovingCoinImage.Size = UDim2.new(0,Width,0,Width)
    MovingCoinImage.Position = UDim2.new(0,PosX,0,PosY)
    MovingCoinImage.Image = "rbxassetid://121148238"
    MovingCoinImage.ZIndex = 2
    MovingCoinImage.Parent = CoinWalletContainer

    --Determine the travel time.
    local TargetPosX,TargetPosY = CoinImage.AbsolutePosition.X + (CoinImage.AbsoluteSize.X/2),CoinImage.AbsolutePosition.Y + (CoinImage.AbsoluteSize.Y/2)
    local TravelDistance = (((PosX - TargetPosX) ^ 2) + ((PosY - TargetPosY) ^ 2)) ^ 0.5
    local TravelTime = COIN_TRAVEL_TIME_SCREEN_WIDTH_MULTIPLIER * (TravelDistance / CoinWalletContainer.AbsoluteSize.X)
    local MaxTravelTime = 2 * COIN_TRAVEL_TIME_SCREEN_WIDTH_MULTIPLIER * (CoinWalletContainer.AbsoluteSize.X / CoinWalletContainer.AbsoluteSize.X)
    if MaxTravelTime > TravelTime then
        TravelTime = MaxTravelTime
    end

    --Animate moving the coin.
    MovingCoinImage:TweenSize(UDim2.new(0,CoinImage.AbsoluteSize.X,0,CoinImage.AbsoluteSize.Y),"Out","Sine",TravelTime)
    MovingCoinImage:TweenPosition(UDim2.new(0,TargetPosX,0,TargetPosY),"Out","Sine",TravelTime)
    wait(TravelTime)
    MovingCoinImage:Destroy()
    FlashCoins(AddedCoins)
end

--[[
Shows a coin animating from the world space.
--]]
local function ShowWorldCoin(AddedCoins,WorldPosition)
    --Calculate a rough bounding box of the coin.
    local CoinWorldPoints = {
        WorldToScreenPoint(WorldPosition + Vector3.new(COIN_WIDTH/2,0,COIN_WIDTH/2)),
        WorldToScreenPoint(WorldPosition + Vector3.new(-COIN_WIDTH/2,0,COIN_WIDTH/2)),
        WorldToScreenPoint(WorldPosition + Vector3.new(COIN_WIDTH/2,0,-COIN_WIDTH/2)),
        WorldToScreenPoint(WorldPosition + Vector3.new(-COIN_WIDTH/2,0,-COIN_WIDTH/2)),
    }
    local MinX,MaxX,MinY,MaxY = math.huge,-math.huge,math.huge,-math.huge
    local CoinBehindCamera = false
    for _,Point in pairs(CoinWorldPoints) do
        MinX = math.min(MinX,Point.X)
        MaxX = math.max(MaxX,Point.X)
        MinY = math.min(MinY,Point.Y)
        MaxY = math.max(MaxY,Point.Y)
        CoinBehindCamera = CoinBehindCamera or (Point.Z < 0)
    end

    --Modify the coin to come from the edge if it is behind the player.
    local CoinSize = math.max(math.abs(MaxX - MinX),math.abs(MaxY - MinY))
    local CoinX,CoinY = (MinX + MaxX)/2,(MinY + MaxY)/2
    if CoinBehindCamera then
        local ScreenSize = CoinWalletContainer.AbsoluteSize
        local CenterX,CenterY = ScreenSize.X/2,ScreenSize.Y/2
        if CoinX > 0 and CoinX < ScreenSize.X and CoinY > 0 and CoinY < ScreenSize.Y then
            local CoinAngle = math.atan2(CoinY - CenterY,CoinX - CenterX)
            local NewCoinAngle = CoinAngle + math.pi
            local EdgeX,EdgeY = CenterX + (CenterX * math.cos(NewCoinAngle)),CenterY + (CenterY * math.sin(NewCoinAngle))
            if CoinAngle <= math.rad(45) and CoinAngle >= math.rad(-45) then
                CoinX = -CoinSize/2
                CoinY = EdgeY
            elseif CoinAngle <= math.rad(135) and CoinAngle >= math.rad(45) then
                CoinX = EdgeX
                CoinY = -CoinSize/2
            elseif CoinAngle <= math.rad(-45) and CoinAngle >= math.rad(-135) then
                CoinX = EdgeX
                CoinY = ScreenSize.Y + (CoinSize/2)
            else
                CoinX = ScreenSize.X + (CoinSize/2)
                CoinY = EdgeY
            end
        end
    end

    --Show the coin.
    ShowLocalCoin(AddedCoins,CoinX,CoinY,CoinSize)
end



--Connect the events.
UpdateCoinsEvent.Event:Connect(function(AddedCoins)
    FlashCoins(AddedCoins)
end)
DisplayCoinsUpdateEvent.Event:Connect(function(AddedCoins)
    local ScreenSize = CoinWalletContainer.AbsoluteSize
    ShowLocalCoin(AddedCoins,ScreenSize.X/2,ScreenSize.Y/2,ScreenSize.Y * 0.075)
end)
DisplayWorldSpaceCoinEvent.Event:Connect(function(AddedCoins,WorldPosition)
    ShowWorldCoin(AddedCoins,WorldPosition)
end)