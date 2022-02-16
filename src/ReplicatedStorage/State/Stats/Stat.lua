--[[
TheNexusAvenger

Logic for a player stat.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusEvent = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEvent")

local Stat = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
Stat:SetClassName("Stat")



--[[
Creates the stat.
--]]
function Stat:__new(ValueObject)
    self:InitializeSuper()

    --Set up the stat.
    self.ValueObject = ValueObject

    --Set up the events.
    self.StatChanged = NexusEvent.new()
    ValueObject:GetPropertyChangedSignal("Value"):Connect(function()
        self:Set(self.ValueObject.Value)
    end)
end

--[[
Returns the value of the stat.
--]]
function Stat:Get()
    return self.ValueObject.Value
end

--[[
Sets the value of the stat.
--]]
function Stat:Set(NewValue)
    if self.ValueObject.Value ~= NewValue then
        self.ValueObject.Value = NewValue
        self.StatChanged:Fire(NewValue)
    end
end

--[[
Increments the value of the stat.
--]]
function Stat:Increment(Increment)
    self:Set(self:Get() + (Increment or 1))
end



return Stat