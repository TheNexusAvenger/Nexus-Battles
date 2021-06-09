--[[
TheNexusAvenger

Controls the dual rocks on the client.
--]]

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local AnimationPlayer = require(Tool:WaitForChild("AnimationPlayer"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local InputHandler = require(Tool:WaitForChild("InputHandler"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))

local RockBuffer = BufferCreator:CreateClientBuffer("Rocks")
local ThrowRockEvent = RemoteEventCreator:GetRemoteEvent("ThrowRock")
local Equipped = false
local HoldTrack,ThrowTrack = nil,nil



--Connect the inputs.
InputHandler.WeaponActivateBegan:Connect(function()
    if not Equipped then return end

    --Start the throwing animation.
    ThrowTrack = AnimationPlayer:PlayAnimation("DualRocksThrow")
    ThrowTrack.KeyframeReached:connect(function(Keyframe)
        --Determine the handle to throw from.
        local StartRock = nil
        local OtherRock = nil
        if Keyframe == "Middle" then
            StartRock = Tool:FindFirstChild("FakeHandle")
            OtherRock = Tool:FindFirstChild("Handle")
        elseif Keyframe == "End" then
            StartRock = Tool:FindFirstChild("Handle")
            OtherRock = Tool:FindFirstChild("FakeHandle")
        end
        if not StartRock then return end

        --Change the transparency of the correct rock.
        StartRock.Transparency = 1
        if OtherRock then OtherRock.Transparency = 0 end

        --Throw the rock.
        local Rock = RockBuffer:PopItem()
        if Rock then
            Rock.CFrame = StartRock.CFrame * CFrame.new(0,-0.5,0)
            Rock.Velocity = -Rock.CFrame.UpVector * (75 + (250 * 0.25 ^ 2)) + Vector3.new(0,30,0)
            ThrowRockEvent:FireServer()
        end
    end)
end)
InputHandler.WeaponActivateEnded:Connect(function()
    --Stop the throwing animation.
    if ThrowTrack then
        ThrowTrack:Stop()
        ThrowTrack = nil
    end
    local FakeHandle = Tool:FindFirstChild("FakeHandle")
    Handle.Transparency = 0
    if FakeHandle then FakeHandle.Transparency = 0 end
end)

--Set up tool equipping and unequipping.
Tool.Equipped:Connect(function(NewMouse)
    if not Equipped then
        Equipped = true
        NewMouse.Icon = "rbxasset://textures/GunCursor.png"

        --Start the hold animation.
        HoldTrack = AnimationPlayer:PlayAnimation("DualRocksHold")
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Reset current player.
        if HoldTrack then
            HoldTrack:Stop()
            HoldTrack = nil
        end
        if ThrowTrack then
            ThrowTrack:Stop()
            ThrowTrack = nil
        end
        Handle.Transparency = 0
    end
end)
