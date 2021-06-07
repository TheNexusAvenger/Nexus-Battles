--[[
TheNexusAvenger

Collection of frames that can be selected by a controller.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusEventCreator = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEventCreator")

local SelectionGroup = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
SelectionGroup:SetClassName("SelectionGroup")



--[[
Creates the selection group.
--]]
function SelectionGroup:__new()
    self:InitializeSuper()

    --Set up the initial state.
    self.Frames = {}
    self.GroupChanged = NexusEventCreator:CreateEvent()
end

--[[
Returns if the frame is in the group.
--]]
function SelectionGroup:ContainsFrame(Frame)
    for _,OtherFrame in pairs(self.Frames) do
        if Frame == OtherFrame then
            return true
        end
    end
    return false
end

--[[
Returns the first frame in the group.
--]]
function SelectionGroup:GetFirstFrame()
    return ((self.FirstFrame and self:ContainsFrame(self.FirstFrame)) and self.FirstFrame) or self.Frames[1]
end

--[[
Set the first frame when the group is activated.
--]]
function SelectionGroup:SetFirstFrame(Frame)
    if self:ContainsFrame(Frame) then
        self.FirstFrame = Frame
    else
        self.FirstFrame = nil
    end
    self.GroupChanged:Fire()
end

--[[
Adds a frame to the selection group.
--]]
function SelectionGroup:AddFrame(Frame)
    if not self:ContainsFrame(Frame) then
        table.insert(self.Frames,Frame)
        self.GroupChanged:Fire()
    end
end

--[[
Removes a frame from the selection group.
--]]
function SelectionGroup:RemoveFrame(Frame)
    for Id,OtherFrame in pairs(self.Frames) do
        if Frame == OtherFrame then
            table.remove(self.Frames,Id)
            self.GroupChanged:Fire()
            break
        end
    end
end

--[[
Clears all frames in the controller group.
--]]
function SelectionGroup:ClearFrames()
    self.Frames = {}
    self.GroupChanged:Fire()
end



return SelectionGroup