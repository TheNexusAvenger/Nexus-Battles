--[[
TheNexusAvenger

Updates the lighting depending on the current map.
--]]

local DEFAULT_LIGHTING = {
    --TODO: Fill when lobby added.
}



local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local MapTypes = ReplicatedStorageProject:GetResource("Data.MapTypes")
local DefaultLighting = {}



--Store the initial lighting.
for _,MapType in pairs(MapTypes) do
    if MapType.Lighting then
        for Name,_ in pairs(MapType.Lighting) do
            if not DefaultLighting[Name] then
                DefaultLighting[Name] = Lighting[Name]
            end
        end
    end
end



--[[
Invoked when the round changes.
--]]
local function CurrentRoundChanged(CurrentRound)
    --Determine the lighting to use.
    local MapLighting = {}
    if not CurrentRound then
        MapLighting = DEFAULT_LIGHTING
    elseif CurrentRound.MapName then
        local MapData = MapTypes[CurrentRound.MapName]
        if MapData and MapData.Lighting then
            MapLighting = MapData.Lighting
        end
    end

    --Apply the lighting settings.
    for PropertyName,PropertyDefault in pairs(DefaultLighting) do
        if MapLighting[PropertyName] ~= nil then
            Lighting[PropertyName] = MapLighting[PropertyName]
        else
            Lighting[PropertyName] = PropertyDefault
        end
    end
end



--Connect the current round changing.
CurrentRoundState.CurrentRoundChanged:Connect(CurrentRoundChanged)
CurrentRoundChanged(CurrentRoundState.CurrentRound)