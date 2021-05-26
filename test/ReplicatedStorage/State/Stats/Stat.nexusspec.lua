--[[
TheNexusAvenger

Tests the Stat class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local Stat = ReplicatedStorageProject:GetResource("State.Stats.Stat")
local StatTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function StatTest:Setup()
    --Create the event and component under testing.
    self.TestValue = Instance.new("NumberValue")
    self.CuT = Stat.new(self.TestValue)

    --Connect the changed event.
    self.FiredEvents = {}
    self.CuT.StatChanged:Connect(function(NewValue)
        table.insert(self.FiredEvents,NewValue)
    end)
end

--[[
Tears down the test.
--]]
function StatTest:Teardown()
    ReplicatedStorageProject:Clear()
end

--[[
Tests the Set method.
--]]
NexusUnitTesting:RegisterUnitTest(StatTest.new("Set"):SetRun(function(self)
    --Set the value and assert the value changed.
    self.CuT:Set(1)
    self:AssertEquals(self.CuT:Get(),1)
    self:AssertEquals(self.FiredEvents,{1})
    self.CuT:Set(2)
    self:AssertEquals(self.CuT:Get(),2)
    self:AssertEquals(self.FiredEvents,{1,2})

    --Set to an existing value and assert the value wasn't set.
    self.CuT:Set(2)
    self:AssertEquals(self.CuT:Get(),2)
    self:AssertEquals(self.FiredEvents,{1,2})
end))

--[[
Tests the Increment method.
--]]
NexusUnitTesting:RegisterUnitTest(StatTest.new("Increment"):SetRun(function(self)
    --Increment the value and assert the value changed.
    self.CuT:Increment(1)
    self:AssertEquals(self.CuT:Get(),1)
    self:AssertEquals(self.FiredEvents,{1})
    self.CuT:Increment(2)
    self:AssertEquals(self.CuT:Get(),3)
    self:AssertEquals(self.FiredEvents,{1,3})

    --Increment a value by 0 assert the value wasn't set.
    self.CuT:Increment(0)
    self:AssertEquals(self.CuT:Get(),3)
    self:AssertEquals(self.FiredEvents,{1,3})
end))



return true