--[[
TheNexusAvenger

Creates buffer and non-buffer slingshot ammo.
--]]

local SlingshotBallCreator = {}

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local SlingshotBallScript = script:WaitForChild("SlingshotBallScript")
local PlayerDamagerScript = Tool:WaitForChild("PlayerDamager")
local ConfigurationScript = Tool:WaitForChild("Configuration")

--[[
Creates a slingshot ball.
--]]
function SlingshotBallCreator:CreateSlingshotBall(IsBuffer)
    --Create the base part.
    local SlingshotBall = Instance.new("Part")
    SlingshotBall.Name = "SlingshotBall"
    SlingshotBall.BottomSurface = "Smooth"
    SlingshotBall.TopSurface = "Smooth"
    SlingshotBall.Shape = "Ball"
    SlingshotBall.Size = Vector3.new(1,1,1)

    local SlingshotBallMesh = Instance.new("SpecialMesh")
    SlingshotBallMesh.MeshId = "http://www.roblox.com/asset/?id=94689434"
    SlingshotBallMesh.TextureId = "http://www.roblox.com/asset/?id=94689543"
    SlingshotBallMesh.Scale = Vector3.new(1.5,1.5,1.5)
    SlingshotBallMesh.Name = "SlingshotBallMesh"
    SlingshotBallMesh.Parent = SlingshotBall

    if IsBuffer then
        --If it is a buffer version, add the scripts.
        local NewSlingshotBallScript = SlingshotBallScript:Clone()
        NewSlingshotBallScript.Disabled = false
        NewSlingshotBallScript.Parent = SlingshotBall

        PlayerDamagerScript:Clone().Parent = NewSlingshotBallScript
        ConfigurationScript:Clone().Parent = NewSlingshotBallScript
    else
        --If it isn't a buffer version, make it uncollidable.
        SlingshotBall.CanCollide = false
    end

    return SlingshotBall
end



return SlingshotBallCreator