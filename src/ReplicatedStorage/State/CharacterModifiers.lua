--[[
TheNexusAvenger

Stores modifiers for the characters.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local NexusEventCreator = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEventCreator")

local CharacterModifiers = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
CharacterModifiers:SetClassName("CharacterModifiers")



--[[
Creates the character modifiers.
--]]
function CharacterModifiers:__new(Character)
    self:InitializeSuper()

    --Create the container.
    local ModifiersContainer = Instance.new("Folder")
    ModifiersContainer.Name = "Modifiers"
    ModifiersContainer.Parent = Character
    self.ModifiersContainer = ModifiersContainer
    self.ModifierChanged = NexusEventCreator:CreateEvent()

    --Connect the events.
    self.Events = {}
    self.LastModifiers = {}
    self.KeyToValue = {}
    table.insert(self.Events,ModifiersContainer.ChildAdded:Connect(function(Value)
        --Connect the value changing.
        Value.Changed:Connect(function()
            self:UpdateModifierType(Value.Name)
        end)

        --Update the total modifier.
        self:UpdateModifierType(Value.Name)
    end))
    table.insert(self.Events,ModifiersContainer.ChildRemoved:Connect(function(Value)
        --Update the total modifier.
        self:UpdateModifierType(Value.Name)
    end))
end

--[[
Adds a modifier.
--]]
function CharacterModifiers:Add(Key,Type,Value)
    --Throw an error if the key already exists.
    if self.KeyToValue[Key] then
        error("Modifier key already used: "..tostring(Key))
    end

    --Create and store the value.
    local ModifierValue = Instance.new("NumberValue")
    ModifierValue.Name = Type
    ModifierValue.Value = Value
    ModifierValue.Parent = self.ModifiersContainer
    self.KeyToValue[Key] = ModifierValue
end

--[[
Removes a modifier.
--]]
function CharacterModifiers:Remove(Key)
    if self.KeyToValue[Key] then
        self.KeyToValue[Key]:Destroy()
        self.KeyToValue[Key] = nil
    end
end

--[[
Returns the current value of the given modifier.
--]]
function CharacterModifiers:Get(Type)
    --Calculate and return the total.
    local Total = 0
    for _,Value in pairs(self.ModifiersContainer:GetChildren()) do
        if Value.Name == Type then
            Total = Total + Value.Value
        end
    end
    return Total
end

--[[
Updates the value of a modifier type.
--]]
function CharacterModifiers:UpdateModifierType(Type)
    --Store the new value and fire the event if the total changed.
    local Total = self:Get(Type)
    if self.LastModifiers[Type] ~= Total then
        self.LastModifiers[Type] = Total
        self.ModifierChanged:Fire(Type,Total)
    end
end

--[[
Destroys the character modifiers.
--]]
function CharacterModifiers:Destroy()
    --Destroy the container.
    self.ModifiersContainer:Destroy()
    self.LastModifiers = {}
    self.KeyToValue = {}

    --Disconnect the events.
    self.ModifierChanged:Disconnect()
    for _,Event in pairs(self.Events) do
        Event:Disconnect()
    end
    self.Events = {}
end



return CharacterModifiers