--[[
TheNexusAvenger

Container for several stats.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Stat = ReplicatedStorageProject:GetResource("State.Stats.Stat")

local StatContainer = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
StatContainer:SetClassName("StatContainer")


--[[
Creates the stats container.
--]]
function StatContainer:__new(Container)
    self:InitializeSuper()

    --Store the container.
    self.Container = Container
    self.CachedStats = {}
end

--[[
Creates the stats container depending
on whether the Player is on the client
or server.
--]]
function StatContainer.GetContainer(Player,Name)
    if RunService:IsClient() or Player:FindFirstChild(Name) then
        return StatContainer.new(Player:WaitForChild(Name))
    else
        local Container = Instance.new("Folder")
        Container.Name = Name
        Container.Parent = Player
        return StatContainer.new(Container)
    end
end

--[[
Creates a stat with the given name, type,
and default value.
--]]
function StatContainer:Create(Name,ValueType,DefaultValue)
    if DefaultValue == nil then DefaultValue = 0 end

    --Return if the value already exists.
    if self.Container:FindFirstChild(Name) then
        return
    end

    --Create the value.
    local ValueObject = Instance.new(ValueType or "NumberValue")
    ValueObject.Name = Name
    ValueObject.Value = DefaultValue
    ValueObject.Parent = self.Container
end

--[[
Returns the stat for the given name.
--]]
function StatContainer:Get(Name)
    --Create the cached stat if it doesn't exists.
    if not self.CachedStats[Name] then
        self.CachedStats[Name] = Stat.new(self.Container:WaitForChild(Name))
    end

    --Return the cached stat.
    return self.CachedStats[Name]
end

--[[
Sets the persistent data source to use.
--]]
function StatContainer:SetDataSource(DataSource)
    --Set the data source.
    self.DataSource = DataSource
    if self.DataSourceEvents then
        for _,Event in pairs(self.DataSourceEvents) do
            Event:Disconnect()
        end
        self.DataSourceEvents = nil
    end
    if not self.DataSource then return end
    self.DataSourceEvents = {}

    --[[
    Connects changes to the stat value object.
    --]]
    local function ConnectValueObject(ValueObject)
        --Set the initial value.
        local NewValue = DataSource:Get(ValueObject.Name)
        if NewValue then
            ValueObject.Value = NewValue
        end

        --Connect the value changing.
        table.insert(self.DataSourceEvents,ValueObject:GetPropertyChangedSignal("Value"):Connect(function()
            self.DataSource:Set(ValueObject.Name,ValueObject.Value)
        end))
        table.insert(self.DataSourceEvents,self.DataSource:OnUpdate(ValueObject.Name,function(ChangedValue)
            if ChangedValue then
                ValueObject.Value = ChangedValue
            end
        end))
    end

    --Connect stats changing.
    table.insert(self.DataSourceEvents,self.Container.ChildAdded:Connect(ConnectValueObject))
    for _,ValueObject in pairs(self.Container:GetChildren()) do
        ConnectValueObject(ValueObject)
    end
end

--[[
Destroys the container.
--]]
function StatContainer:Destroy()
    self.Container:Destroy()
end



return StatContainer