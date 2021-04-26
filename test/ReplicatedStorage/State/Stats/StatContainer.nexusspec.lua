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



return true