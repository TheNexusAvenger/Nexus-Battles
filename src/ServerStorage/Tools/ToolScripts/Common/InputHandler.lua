--[[
TheNexusAvenger

Centralizes user input for use with tools.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local InputBeganEvent = Instance.new("BindableEvent")
local LongInputBeganEvent = Instance.new("BindableEvent")
local InputEndedEvent = Instance.new("BindableEvent")

local InputHandler = {
    WeaponActivateBegan = LongInputBeganEvent.Event,
    WeaponActivateEnded = InputEndedEvent.Event,
    WeaponActivated = InputBeganEvent.Event,
}

local Tool = script.Parent
local Camera = Workspace.CurrentCamera

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local EventsToDisconnect = {}



--[[
Casts a ray. It will ignore nearly
transparent objects and the tool's parent.
--]]
function CastRay(StartPos,Direction,Length)
    local RaycastResult = Workspace:Raycast(StartPos,Direction * Length)
    if RaycastResult then
        local Hit,EndPos = RaycastResult.Instance,RaycastResult.Position
        if Hit then
            if (not Tool.Parent or Hit:IsDescendantOf(Tool.Parent)) or Hit.Transparency > 0.9 then
                return CastRay(EndPos + (Direction * 0.01),Direction,Length - ((StartPos - EndPos).Magnitude))
            end
        end
        return EndPos
    end

    return StartPos + (Direction * Length)
end

--[[
Casts the mouse's position to 3D space.
--]]
local function Get3DPosition(X,Y)
    local MouseRay = Camera:ScreenPointToRay(X,Y,1000)
    local EndPos = MouseRay.Origin + MouseRay.Direction
    return CastRay(Camera.CFrame.Position,(EndPos - Camera.CFrame.Position).Unit,1000)
end

--[[
Disconnects the events if the tool is unparented.
--]]
local function DisconnectEvents()
    if not Tool.Parent then
        for _,Event in pairs(EventsToDisconnect) do
            Event:Disconnect()
        end
        EventsToDisconnect = {}
    end
end



--Set up input changed class for controllers.
local ControllerDown = false
table.insert(EventsToDisconnect,UserInputService.InputChanged:Connect(function(Input,Processed)
    if Processed then return end
    local Character = Player.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end

    --Disconnect the event if the tool is unparented.
    DisconnectEvents()

    --Handle input if it is the right trigger.
    if (Input.UserInputType == Enum.UserInputType.Gamepad1 or Input.UserInputType == Enum.UserInputType.Gamepad2) and Input.KeyCode == Enum.KeyCode.ButtonR2 then
        local ShouldBeDown = (Input.Position.Z > 0.8)

        if ShouldBeDown and not ControllerDown then
            --If it is 80% down and it was up, set it down.
            ControllerDown = true

            if VRService.VREnabled then
                --The camera's CFrame is used with VR.
                --For a VR version, a more robust implemention should be done.
                local CameraCF = Camera.CFrame
                local Position = CastRay(CameraCF.Position,CameraCF.LookVector,1000)
                LongInputBeganEvent:Fire(Position)
                InputBeganEvent:Fire(Position)
            else
                --The center mouse is used with controllers.
                local Position = Get3DPosition(Mouse.X,Mouse.Y)
                LongInputBeganEvent:Fire(Position)
                InputBeganEvent:Fire(Position)
            end
        elseif not ShouldBeDown and ControllerDown then
            --If it is not 80% down and it was down, set it to up.
            ControllerDown = false

            if VRService.VREnabled then
                --The camera's CFrame is used with VR.
                --For a VR version, a more robust implemention should be done.
                local CameraCF = Camera.CFrame
                InputEndedEvent:Fire(CastRay(CameraCF.Position,CameraCF.LookVector,1000))
            else
                --The center mouse is used with controllers.
                InputEndedEvent:Fire(Get3DPosition(Mouse.X,Mouse.Y))
            end
        end
    end
end))

--Set up input began and ended for controller.
table.insert(EventsToDisconnect,UserInputService.InputBegan:Connect(function(Input,Processed)
    if Processed then return end
    local Character = Player.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end

    --Disconnect the event if the tool is unparented.
    DisconnectEvents()

    --Register event if it was a mouse left click.
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        local Position = Get3DPosition(Input.Position.X,Input.Position.Y)
        LongInputBeganEvent:Fire(Position)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            InputBeganEvent:Fire(Position)
        end
    end
end))

table.insert(EventsToDisconnect,UserInputService.TouchTap:Connect(function(Positions,Processed)
    if Processed then return end
    local Character = Player.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end

    --Disconnect the event if the tool is unparented.
    DisconnectEvents()

    local Position = Positions[1]
    if Position then
        InputBeganEvent:Fire(Get3DPosition(Position.X,Position.Y))
    end
end))

table.insert(EventsToDisconnect,UserInputService.InputEnded:Connect(function(Input)
    --Disconnect the event if the tool is unparented.
    DisconnectEvents()

    --Register event if it was a mouse left click or a touch.
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        InputEndedEvent:Fire(Get3DPosition(Input.Position.X,Input.Position.Y))
    end
end))



return InputHandler