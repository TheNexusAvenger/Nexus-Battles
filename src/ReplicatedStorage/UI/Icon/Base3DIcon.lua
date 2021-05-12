--[[
TheNexusAvenger

Base class for displaying a 3D item on a frame.
--]]

local ROTATION_SPEED_MULTIPLIER = 0.75



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Module3D = ReplicatedStorageProject:GetResource("External.Module3D")
local Base3DIcon = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
Base3DIcon:SetClassName("Base3DIcon")



--[[
Creates the base 3D icon.
--]]
function Base3DIcon:__new(Model)
    self:InitializeSuper()

    --Set up the Module3D frame.
    self.Module3DFrame = Module3D.new(Model)
    self.Module3DFrame.Camera.FieldOfView = 10
	self.Module3DFrame:SetDepthMultiplier(1.2)
    self.RotationOffset = CFrame.new()
    self.RotationSpeed = ROTATION_SPEED_MULTIPLIER

    --Connect the events.
    self.UpdateRotationEvent = RunService.RenderStepped:Connect(function()
        self.Module3DFrame:SetCFrame(CFrame.Angles(0,(tick() * self.RotationSpeed) % (math.pi * 2),0) * self.RotationOffset)
    end)
    self.Changed:Connect(function(Name)
        if Name == "UpdateRotationEvent" or Name == "RotationOffset" or Name == "RotationSpeed" then return end
        self.Module3DFrame[Name] = self[Name]
    end)
end

--[[
Creates an __index metamethod for an object. Used to
setup custom indexing.
--]]
function Base3DIcon:__createindexmethod(Object,Class,RootClass)
    --Get the base method.
    local BaseIndexMethod = self.super:__createindexmethod(Object,Class,RootClass)

    --Return a wrapped method.
    return function(MethodObject,Index)
        --Return the object value if it exists.
        local BaseReturn = BaseIndexMethod(MethodObject,Index)
        if BaseReturn ~= nil or Index == "Module3DFrame" or Index == "UpdateRotationEvent" or Index == "RotationSpeed" or Index == "RotationOffset" or Index == "super" then
            return BaseReturn
        end

        --Return the frames's value.
        local Module3DFrame = Object.Module3DFrame
        if Module3DFrame then
            return Module3DFrame[Index]
        end
    end
end

--[[
Destroys the icon.
--]]
function Base3DIcon:Destroy()
    self.super:Destroy()
    if self.UpdateRotationEvent then
        self.UpdateRotationEvent:Disconnect()
        self.UpdateRotationEvent = nil
    end
end



return Base3DIcon