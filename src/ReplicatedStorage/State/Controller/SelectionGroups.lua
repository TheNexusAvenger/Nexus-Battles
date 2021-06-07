--[[
TheNexusAvenger

Manages the selections groups.
Class is static.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local SelectionGroups = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
SelectionGroups:SetClassName("SelectionGroups")
SelectionGroups.Groups = {}



--[[
Adds a selection group to the top.
--]]
function SelectionGroups:Add(SelectionGroup)
    table.insert(self.Groups,SelectionGroup)
    self:UpdateSelectionGroup()
end

--[[
Adds a selection group to the bottom (intended for
UI that appears below prompts while they are open).
--]]
function SelectionGroups:AddBelow(SelectionGroup)
    table.insert(self.Groups,1,SelectionGroup)
    self:UpdateSelectionGroup()
end

--[[
Removes the last index of a given selection group.
--]]
function SelectionGroups:Remove(GroupToRemove)
    --Get the highest index of the group.
    local Index
    for i,Group in pairs(self.Groups) do
        if Group == GroupToRemove then
            Index = i
        end
    end

    --Remove the group.
    if Index then
        table.remove(self.Groups,Index)
        self:UpdateSelectionGroup()
    end
end

--[[
Updates the active selection group.
--]]
function SelectionGroups:UpdateSelectionGroup()
    --Return if the group is the same.
    local NewGroup = self.Groups[#self.Groups]
    if NewGroup == self.CurrentGroup then return end

    --Disconnect the existing group.
    if self.CurrentGroup then
        self.CurrentGroup = nil
    end
    if self.CurrentGroupChangedEvent then
        self.CurrentGroupChangedEvent:Disconnect()
        self.CurrentGroupChangedEvent = nil
    end

    --Set up the new group.
    if NewGroup then
        self.CurrentGroup = NewGroup
        self.CurrentGroupChangedEvent = NewGroup.GroupChanged:Connect(function()
            self:UpdateSelectedFrame()
        end)
    end

    --Update the selection.
    self:UpdateSelectedFrame()
end

--[[
Updates the selected frame.
--]]
function SelectionGroups:UpdateSelectedFrame()
    --Unset the selection if there is no gamepad connected or no current group.
    if not self.CurrentGroup or not UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
        GuiService.SelectedObject = nil
        return
    end

    --Update the selection.
    if self.LastFrame and not self.CurrentGroup:ContainsFrame(self.LastFrame) then
        self.LastFrame = nil
    end
    GuiService.SelectedObject = (self.CurrentGroup:ContainsFrame(GuiService.SelectedObject) and GuiService.SelectedObject) or self.LastFrame or self.CurrentGroup:GetFirstFrame()
end



--Set up controller events.
UserInputService.GamepadConnected:Connect(function()
    SelectionGroups:UpdateSelectedFrame()
end)
UserInputService.GamepadDisconnected:Connect(function()
    SelectionGroups:UpdateSelectedFrame()
end)
GuiService.Changed:Connect(function()
    SelectionGroups:UpdateSelectedFrame()
end)



return SelectionGroups