--[[
TheNexusAvenger

Flashes a part locally, such as to be a hint.
--]]

local TweenService = game:GetService("TweenService")

return function(Part)
    --Clone the part.
    local ClonedPart = Part:Clone()
    ClonedPart.Color = Color3.new(1,1,1)
    ClonedPart.Material = "Neon"
    ClonedPart.Transparency = 1
    ClonedPart.Size = Part.Size * 1.01
    ClonedPart.CanCollide = false
    ClonedPart.Parent = Part

    local Weld = Instance.new("Weld")
    Weld.Part0 = Part
    Weld.Part1 = ClonedPart
    Weld.Parent = ClonedPart

    --Start the flashing loop.
    while ClonedPart.Parent and Weld.Parent do
        TweenService:Create(ClonedPart,TweenInfo.new(2),{
            Transparency = 1,
        }):Play()
        wait(2.5)
        TweenService:Create(ClonedPart,TweenInfo.new(2),{
            Transparency = 0,
        }):Play()
        wait(2.5)
    end

    --Destroy the part.
    ClonedPart:Destroy()
end