--[[
TheNexusAvenger

Displays a damage indicator above a player.
--]]

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

return function (CenterPart,Number,Scale)
    Number = math.floor((Number or 0) + 0.5)
    Scale = Scale or 1

    --Create the indicator.
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Size = UDim2.new(2 * Scale,0,2 * Scale,0)
    BillboardGui.Adornee = CenterPart
    BillboardGui.Parent = Workspace.CurrentCamera
    Debris:AddItem(BillboardGui,2)

    local DamageText = Instance.new("TextLabel")
    DamageText.Size = UDim2.new(1,0,1,0)
    DamageText.BackgroundTransparency = 1
    DamageText.Text = tostring(Number)
    DamageText.Rotation = math.random(-15,15)
    DamageText.Font = "Legacy"
    DamageText.TextColor3 = Color3.new(1,0,0)
    DamageText.TextScaled = true
    DamageText.Parent = BillboardGui

    --Show the indicator.
    TweenService:Create(BillboardGui,TweenInfo.new(2/3),{
        StudsOffset = Vector3.new(0,4 * Scale,0),
    }):Play()
    wait(2/3)
    TweenService:Create(BillboardGui,TweenInfo.new(2/3),{
        Size = UDim2.new(3 * Scale,0,3 * Scale,0),
    }):Play()
    TweenService:Create(DamageText,TweenInfo.new(0.5),{
        Rotation = math.random(-15,15),
        TextTransparency = 1,
    }):Play()
end