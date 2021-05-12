--[[
TheNexusAvenger

Creates an arrow for the Juggernaut.
--]]

local LastJuggernautArrow



return function(Head)
    --Clear the last arrow.
    if LastJuggernautArrow then
        LastJuggernautArrow:Destroy()
        LastJuggernautArrow = nil
    end

    --Create the new arrow.
    if Head then
        local BillboardGui = Instance.new("BillboardGui")
        BillboardGui.Active = false
        BillboardGui.SizeOffset = Vector2.new(0,0.8)
        BillboardGui.AlwaysOnTop = true
        BillboardGui.Size = UDim2.new(1.5,75,3.5,175)
        LastJuggernautArrow = BillboardGui

        local ImageLabel = Instance.new("ImageLabel")
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.Parent = BillboardGui
        ImageLabel.Image = "http://www.roblox.com/asset/?id=119545962"
        ImageLabel.Size = UDim2.new(1,0,1,0)
        BillboardGui.Adornee = Head
        BillboardGui.Parent = Head
    end
end