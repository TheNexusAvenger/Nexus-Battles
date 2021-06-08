--[[
TheNexusAvenger

Controls the dual rocks on the server.
--]]

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local PlayerDamagerModule = Tool:WaitForChild("PlayerDamager")
local RockScript = script:WaitForChild("RockScript")

local RockBuffer = BufferCreator:CreateServerBuffer("Rocks")
local ThrowRockEvent = RemoteEventCreator:CreateRemoteEvent("ThrowRock")
local Equipped = false
local FakeHandle = nil



--[[
Adds a rock to the buffer.
--]]
local function AddRock()
    --Create the rock.
    local Rock = Handle:Clone()
    Rock.CanCollide = true
    Rock:WaitForChild("Swish").Pitch = (1.1 + (0.15 * math.random()))

    local NewRockScript = RockScript:Clone()
    PlayerDamagerModule:Clone().Parent = NewRockScript
    NewRockScript.Disabled = false
    NewRockScript.Parent = Rock

    --Add the rock to the buffer.
    RockBuffer:AddItem(Rock)
end



--Add 2 initial rocks.
AddRock()
AddRock()

--Connect the replication.
ThrowRockEvent.OnServerEvent:Connect(function(Player)
    --Pop the rock.
    local Rock = RockBuffer:PopItem()
    Rock:WaitForChild("Swish"):Play()
    Debris:AddItem(Rock,6)

    --Add who fired the rock.
    local FiredBy = Instance.new("ObjectValue")
    FiredBy.Name = "FiredBy"
    FiredBy.Value = Player
    FiredBy.Parent = Rock

    --Add the new rock.
    wait(0.1)
    AddRock()
end)

--Set up tool equipping and unequipping.
Tool.Equipped:Connect(function()
    if not Equipped then
        Equipped = true

		--Set current player.
		local CurrentCharacter = Tool.Parent
		local CurrentHumanoid = CurrentCharacter:FindFirstChildOfClass("Humanoid")
		local CurrentPlayer = Players:GetPlayerFromCharacter(CurrentCharacter)
		RockBuffer:SetCurrentPlayer(CurrentPlayer)

        --Create the fake handle.
        local LeftHand = CurrentCharacter:FindFirstChild("LeftHand")
        if LeftHand then
            local LeftGripAttachment = LeftHand:FindFirstChild("LeftGripAttachment")
            if LeftGripAttachment then
                FakeHandle = Handle:Clone()
                FakeHandle.Name = "FakeHandle"
                FakeHandle.Parent = Tool

                local RockWeld = Instance.new("Weld")
                RockWeld.C0 = LeftGripAttachment.CFrame
                RockWeld.Part0 = LeftHand
                RockWeld.Part1 = FakeHandle
                RockWeld.Parent = LeftHand
            end
        end
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Reset current player.
        if FakeHandle then
            FakeHandle:Destroy()
            FakeHandle = nil
        end
    end
end)