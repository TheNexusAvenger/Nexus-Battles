--[[
TheNexusAvenger

Runs the server-side superball.
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local HandleMesh = Handle:WaitForChild("Mesh")
local EquipSound = Handle:WaitForChild("EquipSound")
local ThrowSound = Handle:WaitForChild("ThrowSound")

local SuperballCreator = require(Tool:WaitForChild("SuperballCreator"))
local BufferCreator = require(Tool:WaitForChild("BufferCreator"))
local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local SUPERBALL_RELOAD_TIME = Configuration.SUPERBALL_RELOAD_TIME

local SuperballBuffer = BufferCreator:CreateServerBuffer("SuperballBuffer")
local FireSuperballEvent = RemoteEventCreator:CreateRemoteEvent("FireSuperball")

local CurrentPlayer,CurrentCharacter
local CurrentSuperball
local Equipped = false
local ToolEnabled = true



--[[
Adds a superball to the buffer.
--]]
local function AddBufferSuperball()
    local NewSuperball = SuperballCreator:CreateSuperball()
    CurrentSuperball = NewSuperball
    SuperballBuffer:AddItem(NewSuperball)
end
AddBufferSuperball()



--Set up the activated event.
FireSuperballEvent.OnServerEvent:Connect(function(Player)
    if Player == CurrentPlayer and ToolEnabled then
        ToolEnabled = false
        Tool.Enabled = false

        --Set up the superball.
        CurrentSuperball = SuperballBuffer:PopItem() or CurrentSuperball
        Handle.Transparency = 1
        ThrowSound:Play()
        CurrentSuperball:WaitForChild("SuperballMesh").VertexColor = HandleMesh.VertexColor

        --Add who fired the superball.
        local FiredBy = Instance.new("ObjectValue")
        FiredBy.Name = "FiredBy"
        FiredBy.Value = Player
        FiredBy.Parent = CurrentSuperball

        --Reload the superball.
        wait(SUPERBALL_RELOAD_TIME)
        Handle.Transparency = 0
        AddBufferSuperball()
        ToolEnabled = true
        Tool.Enabled = true
    end
end)


--Set up the equipped and unequipped events.
Tool.Equipped:Connect(function()
    if not Equipped then
        Equipped = true

        --Set up the current player.
        CurrentCharacter = Tool.Parent
        CurrentPlayer = Players:GetPlayerFromCharacter(CurrentCharacter)
        EquipSound:Play()

        --Set the owner of the superball buffer.
        SuperballBuffer:SetCurrentPlayer(CurrentPlayer)
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Reset the current player and superball buffer owner.
        CurrentCharacter = nil
        CurrentPlayer = nil
        EquipSound:Stop()
        ThrowSound:Stop()
        SuperballBuffer:SetCurrentPlayer()
    end
end)



--Start updating the color.
while true do
    --Select the next non-dark color.
    local NextColor
    while not NextColor do
        NextColor = Color3.new(math.random(),math.random(),math.random())
        if 0.2126 * NextColor.R + 0.7152 * NextColor.G + 0.0722 * NextColor.B < 0.4 then NextColor = nil end
    end

    --Tween the color.
    TweenService:Create(HandleMesh,TweenInfo.new(2),{
        VertexColor = Vector3.new(NextColor.r,NextColor.g,NextColor.b),
    }):Play()
    wait(2)
    Handle.Color = NextColor
    wait(0.1)
end