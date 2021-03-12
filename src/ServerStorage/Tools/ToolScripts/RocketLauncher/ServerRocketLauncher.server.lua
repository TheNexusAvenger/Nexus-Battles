--[[
TheNexusAvenger

Runs the server-side rocket launcher.
--]]

local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local EquipSound = Handle:WaitForChild("EquipSound")

local RocketCreator = require(Tool:WaitForChild("RocketCreator"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local ROCKET_RELOAD_TIME = Configuration.ROCKET_RELOAD_TIME

local RocketBuffer = BufferCreator:CreateServerBuffer("RocketBuffer")
local FireRocketEvent = RemoteEventCreator:CreateRemoteEvent("FireRocket")

local CurrentPlayer,CurrentCharacter
local CurrentHandRocket,CurrentRocket
local Equipped = false
local ToolEnabled = true



--Adds a rocket to the buffer.
local function AddBufferRocket()
    local NewRocket = RocketCreator:CreateRocket(true)
    CurrentRocket = NewRocket
    RocketBuffer:AddItem(NewRocket)
end
AddBufferRocket()




--Set up firing the rocket.
FireRocketEvent.OnServerEvent:Connect(function(Player)
    if Player == CurrentPlayer and ToolEnabled then
        ToolEnabled = false
        Tool.Enabled = false
        CurrentRocket = RocketBuffer:PopItem() or CurrentRocket

        local FiredBy = Instance.new("ObjectValue")
        FiredBy.Name = "FiredBy"
        FiredBy.Value = Player
        FiredBy.Parent = CurrentRocket

        wait(ROCKET_RELOAD_TIME)
        AddBufferRocket()
        ToolEnabled = true
        Tool.Enabled = true
    end
end)

--Set up equipping and unequipping the tool.
Tool.Equipped:Connect(function()
    if not Equipped then
        Equipped = true

        CurrentCharacter = Tool.Parent
        CurrentPlayer = Players:GetPlayerFromCharacter(CurrentCharacter)
        EquipSound:Play()

        --Create the left hand rocket.
        local LeftGripAttachment = CurrentCharacter:FindFirstChild("LeftGripAttachment",true)
        if LeftGripAttachment then
            CurrentHandRocket = RocketCreator:CreateRocket(false)
            CurrentHandRocket.Name = "HandRocket"
            CurrentHandRocket.Transparency  = 1
            CurrentHandRocket.Parent = Tool

            local Weld = Instance.new("Weld")
            Weld.Part0 = LeftGripAttachment.Parent
            Weld.Part1 = CurrentHandRocket
            Weld.C0 = LeftGripAttachment.CFrame
            Weld.C1 = CFrame.Angles(0,math.pi,0)
            Weld.Parent = CurrentHandRocket
        end

        RocketBuffer:SetCurrentPlayer(CurrentPlayer)
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        CurrentCharacter = nil
        CurrentPlayer = nil
        EquipSound:Stop()
        if CurrentHandRocket then CurrentHandRocket:Destroy() end
        RocketBuffer:SetCurrentPlayer()
    end
end)