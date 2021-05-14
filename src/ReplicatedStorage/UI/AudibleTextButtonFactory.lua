--[[
TheNexusAvenger

Extends the text button factory to add audible feedback
for a click.
--]]

local BORDER_COLOR_OFFSET = Color3.new(-30/255,-30/255,-30/255)
local CLICK_SOUND = "rbxassetid://421058925"


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local TextButtonFactory = ReplicatedStorageProject:GetResource("External.NexusButton.Factory.TextButtonFactory")

local AudibleTextButtonFactory = TextButtonFactory:Extend()
AudibleTextButtonFactory:SetClassName(AudibleTextButtonFactory)

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = CLICK_SOUND



--[[
Adds two Color3s.
--]]
local function AddColor3(Color1,Color2)
    --Multiply the R,G,B values.
    local NewR,NewG,NewB = Color1.R + Color2.R,Color1.G + Color2.G,Color1.B + Color2.B

    --Clamp the values.
    NewR = math.clamp(NewR,0,1)
    NewG = math.clamp(NewG,0,1)
    NewB = math.clamp(NewB,0,1)

    --Return the color.
    return Color3.new(NewR,NewG,NewB)
end



--[[
Creates a audible text button factory with the default
style. This is used by Nexus Development projects.
--]]
function AudibleTextButtonFactory.CreateDefault(Color)
    --Create the factory.
    local Factory = AudibleTextButtonFactory.new()

    --Set the defaults.
    Factory:SetDefault("BackgroundColor3",Color)
    Factory:SetDefault("BorderColor3",AddColor3(Color,BORDER_COLOR_OFFSET))
    Factory:SetDefault("BorderTransparency",0.25)
    Factory:SetTextDefault("Font",Enum.Font.SourceSansBold)
    Factory:SetTextDefault("TextColor3",Color3.new(1,1,1))
    Factory:SetTextDefault("TextStrokeColor3",Color3.new(0,0,0))
    Factory:SetTextDefault("TextStrokeTransparency",0)
    Factory:SetTextDefault("TextScaled",true)

    --Return the factory.
    return Factory
end

--[[
Creates a text button instance.
--]]
function AudibleTextButtonFactory:Create()
    --Create the button and text label.
    local Button,TextLabel = self.super:Create()

    --Connect the button being clicked and play a sound.
    Button.MouseButton1Down:Connect(function()
        SoundService:PlayLocalSound(ClickSound)
    end)

    --Return the button and textlabel.
    return Button,TextLabel
end



return AudibleTextButtonFactory