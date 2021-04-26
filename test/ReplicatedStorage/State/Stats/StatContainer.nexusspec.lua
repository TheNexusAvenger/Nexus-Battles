--[[
TheNexusAvenger

Tests the StatContainer class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatContainer = require(ReplicatedStorage:WaitForChild("State"):WaitForChild("Stats"):WaitForChild("StatContainer"))
local StatContainerTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function StatContainerTest:Setup()
    --Create the container and a dummy value.
    self.Container = Instance.new("Folder")

    self.TestValue = Instance.new("NumberValue")
    self.TestValue.Name = "TestStat1"
    self.TestValue.Value = 2
    self.TestValue.Parent = self.Container

    --Create the event and component under testing.
    self.TestValue = Instance.new("NumberValue")
    self.CuT = StatContainer.new(self.Container)
end

--[[
Tests the Get method.
--]]
NexusUnitTesting:RegisterUnitTest(StatContainerTest.new("Get"):SetRun(function(self)
    --Create 2 test values.
    self.CuT:Create("TestStat2")
    self.CuT:Create("TestStat3","StringValue","TestValue")

    --Assert the stats are correct.
    self:AssertEquals(self.CuT:Get("TestStat1"):Get(),2)
    self:AssertEquals(self.CuT:Get("TestStat2"):Get(),0)
    self:AssertEquals(self.CuT:Get("TestStat3"):Get(),"TestValue")
    self:AssertSame(self.CuT:Get("TestStat3"),self.CuT:Get("TestStat3"))
end))

--[[
Tests the SetDataSource method.
--]]
NexusUnitTesting:RegisterUnitTest(StatContainerTest.new("SetDataSource"):SetRun(function(self)
    --Create the mock DataStore from NexusDataStore.]
    local MockValues = {
        TestStat1 = 5,
        TestStat2 = 6,
        TestStat4 = "NewTestValue2",
    }
    local MockEvents = {
        TestStat1 = Instance.new("BindableEvent"),
        TestStat2 = Instance.new("BindableEvent"),
        TestStat3 = Instance.new("BindableEvent"),
        TestStat4 = Instance.new("BindableEvent"),
    }
    local MockDataStore = {
        Get = function(_,Name)
            return MockValues[Name]
        end,
        Set = function(_,Name,Value)
            MockValues[Name] = Value
        end,
        OnUpdate = function(_,Name,Callback)
            return MockEvents[Name].Event:Connect(function()
                Callback(MockValues[Name])
            end)
        end,
    }

    --Add a test value and assert the values are correct.
    self.CuT:Create("TestStat2")
    self:AssertEquals(self.CuT:Get("TestStat1"):Get(),2)
    self:AssertEquals(self.CuT:Get("TestStat2"):Get(),0)

    --Set the data source and assert the values are correct.
    self.CuT:SetDataSource(MockDataStore)
    self:AssertEquals(self.CuT:Get("TestStat1"):Get(),5)
    self:AssertEquals(self.CuT:Get("TestStat2"):Get(),6)

    --Create 2 new values and assert they are correct.
    self.CuT:Create("TestStat3","StringValue","TestValue1")
    self.CuT:Create("TestStat4","StringValue","TestValue2")
    self:AssertEquals(self.CuT:Get("TestStat3"):Get(),"TestValue1")
    self:AssertEquals(self.CuT:Get("TestStat4"):Get(),"NewTestValue2")

    --Set 2 values and assert they are set.
    self.CuT:Get("TestStat1"):Set(7)
    self.CuT:Get("TestStat3"):Set("NewTestValue1")
    self:AssertEquals(self.CuT:Get("TestStat1"):Get(),7)
    self:AssertEquals(self.CuT:Get("TestStat3"):Get(),"NewTestValue1")
    self:AssertEquals(MockValues,{
        TestStat1 = 7,
        TestStat2 = 6,
        TestStat3 = "NewTestValue1",
        TestStat4 = "NewTestValue2",
    })

    --Invoke the OnUpdate events and assert the values change.
    MockValues["TestStat1"] = 8
    MockValues["TestStat4"] = "NewTestValue3"
    MockEvents.TestStat1:Fire(8)
    MockEvents.TestStat4:Fire("NewTestValue3")
    self:AssertEquals(self.CuT:Get("TestStat1"):Get(),8)
    self:AssertEquals(self.CuT:Get("TestStat2"):Get(),6)
    self:AssertEquals(self.CuT:Get("TestStat3"):Get(),"NewTestValue1")
    self:AssertEquals(self.CuT:Get("TestStat4"):Get(),"NewTestValue3")
end))



return true