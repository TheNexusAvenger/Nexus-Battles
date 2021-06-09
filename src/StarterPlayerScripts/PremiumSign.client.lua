--[[
TheNexusAvenger

Displays a sign in the lobby pushing for Premium
for faster rank ups.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Lobby = Workspace:WaitForChild("Lobby")
local PremiumSign = Lobby:WaitForChild("PremiumSign")
local SignPart = PremiumSign:WaitForChild("Sign")
local GreenTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))



--Destroy the sign if the player is premium.
if Players.LocalPlayer.MembershipType == Enum.MembershipType.Premium then
    wait()
    PremiumSign:Destroy()
    script:Destroy()
    return
end

--Set up the sign.
local SignSurfaceGui = Instance.new("SurfaceGui")
SignSurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
SignSurfaceGui.PixelsPerStud = 50
SignSurfaceGui.ResetOnSpawn = false
SignSurfaceGui.Name = "PremiumSign"
SignSurfaceGui.Adornee = SignPart
SignSurfaceGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local SignContainer = Instance.new("Frame")
SignContainer.BackgroundTransparency = 1
SignContainer.Size = UDim2.new(1,0,1,0)
SignContainer.ClipsDescendants = true
SignContainer.Parent = SignSurfaceGui

local Background = Instance.new("ImageLabel")
Background.BackgroundTransparency = 1
Background.AnchorPoint = Vector2.new(0.5,0.5)
Background.Position = UDim2.new(0.5,0,0.5,0)
Background.Size = UDim2.new(1,0,1,0)
Background.SizeConstraint = Enum.SizeConstraint.RelativeXX
Background.Image = "rbxassetid://6870151969"
Background.ImageTransparency = 0.5
Background.Parent = SignContainer

local TopText = Instance.new("TextLabel")
TopText.BackgroundTransparency = 1
TopText.Size = UDim2.new(0.9,0,0.2,0)
TopText.Position = UDim2.new(0.05,0,0.05,0)
TopText.Font = Enum.Font.SourceSansBold
TopText.TextColor3 = Color3.new(0,0,0)
TopText.TextStrokeColor3 = Color3.new(1,1,1)
TopText.TextStrokeTransparency = 0
TopText.TextScaled = true
TopText.Text = "RANK UP FASTER"
TopText.Parent = SignContainer

local BottomText = Instance.new("TextLabel")
BottomText.BackgroundTransparency = 1
BottomText.Size = UDim2.new(0.9,0,0.15,0)
BottomText.Position = UDim2.new(0.05,0,0.625,0)
BottomText.Font = Enum.Font.SourceSansBold
BottomText.TextColor3 = Color3.new(0,0,0)
BottomText.TextStrokeColor3 = Color3.new(1,1,1)
BottomText.TextStrokeTransparency = 0
BottomText.TextScaled = true
BottomText.Text = "BY GETTING PREMIUM"
BottomText.Parent = SignContainer

local PremiumIcon = Instance.new("ImageLabel")
PremiumIcon.BackgroundTransparency = 1
PremiumIcon.AnchorPoint = Vector2.new(1,0)
PremiumIcon.Position = UDim2.new(0.475,0,0.25,0)
PremiumIcon.Size = UDim2.new(0.35,0,0.35,0)
PremiumIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
PremiumIcon.Image = "rbxasset://textures/ui/PurchasePrompt/Premium.png"
PremiumIcon.Parent = SignContainer

local RankIcon1 = Instance.new("ImageLabel")
RankIcon1.BackgroundTransparency = 1
RankIcon1.Position = UDim2.new(0.525,0,0.175,0)
RankIcon1.Size = UDim2.new(0.35,0,0.35,0)
RankIcon1.SizeConstraint = Enum.SizeConstraint.RelativeYY
RankIcon1.Image = "rbxassetid://6866145490"
RankIcon1.ImageColor3 = Color3.new(0,170/255,255/255)
RankIcon1.ImageRectSize = Vector2.new(512,512)
RankIcon1.Parent = SignContainer

local RankIcon2 = Instance.new("ImageLabel")
RankIcon2.BackgroundTransparency = 1
RankIcon2.Position = UDim2.new(0.525,0,0.25,0)
RankIcon2.Size = UDim2.new(0.35,0,0.35,0)
RankIcon2.SizeConstraint = Enum.SizeConstraint.RelativeYY
RankIcon2.Image = "rbxassetid://6866145490"
RankIcon2.ImageColor3 = Color3.new(235/255,200/255,0)
RankIcon2.ImageRectSize = Vector2.new(512,512)
RankIcon2.Parent = SignContainer

local RankIcon3 = Instance.new("ImageLabel")
RankIcon3.BackgroundTransparency = 1
RankIcon3.Position = UDim2.new(0.525,0,0.325,0)
RankIcon3.Size = UDim2.new(0.35,0,0.35,0)
RankIcon3.SizeConstraint = Enum.SizeConstraint.RelativeYY
RankIcon3.Image = "rbxassetid://6866145490"
RankIcon3.ImageColor3 = Color3.new(230/255,230/255,230/255)
RankIcon3.ImageRectSize = Vector2.new(512,512)
RankIcon3.Parent = SignContainer

local GetPremiumButton,GetPremiumText = GreenTextButtonFactory:Create()
GetPremiumButton.Size = UDim2.new(0.6,0,0.15,0)
GetPremiumButton.Position = UDim2.new(0.2,0,0.8,0)
GetPremiumButton.Parent = SignContainer
GetPremiumText.Text = "GET PREMIUM"

GetPremiumButton.MouseButton1Down:Connect(function()
    MarketplaceService:PromptPremiumPurchase(Players.LocalPlayer)
end)