--[[
TheNexusAvenger

Tests the ReplicatedContainer class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))
local ReplicatedContainer = NexusRoundSystem:GetResource("Common.Object.Base.ReplicatedContainer")
local ReplicatedContainerTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function ReplicatedContainerTest:Setup()
    self.CuT1 = ReplicatedContainer.new()
    self.CuT1.Id = -1
    self.CuT2 = ReplicatedContainer.new()
    self.CuT2.Id = -2
    self.CuT3 = ReplicatedContainer.new()
    self.CuT3.Id = -3
end

--[[
Tears down the test.
--]]
function ReplicatedContainerTest:Teardown()
    self.CuT1:Destroy()
    self.CuT2:Destroy()
    self.CuT3:Destroy()
    NexusRoundSystem:ClearInstances()
end

--[[
Tests the Serialize method.
--]]
NexusUnitTesting:RegisterUnitTest(ReplicatedContainerTest.new("Serialize"):SetRun(function(self)
    --Assert the base objects serialize.
    self:AssertEquals(self.CuT1:Serialize(),{Children={},Name="ReplicatedContainer"})
    self:AssertEquals(self.CuT2:Serialize(),{Children={},Name="ReplicatedContainer"})
    self:AssertEquals(self.CuT3:Serialize(),{Children={},Name="ReplicatedContainer"})

    --Set the parents and assert the serialization is correct.
    self.CuT2.Parent = self.CuT1
    self.CuT3.Parent = self.CuT2
    self:AssertEquals(self.CuT1:Serialize(),{Children={-2},Name="ReplicatedContainer"})
    self:AssertEquals(self.CuT2:Serialize(),{Children={-3},Parent=-1,Name="ReplicatedContainer"})
    self:AssertEquals(self.CuT3:Serialize(),{Children={},Parent=-2,Name="ReplicatedContainer"})
    self.CuT3.Parent = self.CuT1
    self:AssertEquals(self.CuT1:Serialize(),{Children={-2,-3},Name="ReplicatedContainer"})
    self:AssertEquals(self.CuT2:Serialize(),{Children={},Parent=-1,Name="ReplicatedContainer"})
    self:AssertEquals(self.CuT3:Serialize(),{Children={},Parent=-1,Name="ReplicatedContainer"})
    self.CuT2.Parent = nil
    self:AssertEquals(self.CuT1:Serialize(),{Children={-3},Name="ReplicatedContainer"})
    self:AssertEquals(self.CuT2:Serialize(),{Children={},Name="ReplicatedContainer"})
    self:AssertEquals(self.CuT3:Serialize(),{Children={},Parent=-1,Name="ReplicatedContainer"})

    --Add a raw property and assert the serialization is correct.
    self.CuT1:AddToSerialization("Name2")
    self.CuT2:AddToSerialization("Name2")
    self.CuT3:AddToSerialization("Name2")
    self.CuT1.Name2 = "Test1"
    self.CuT2.Name2 = "Test2"
    self:AssertEquals(self.CuT1:Serialize(),{Children={-3},Name="ReplicatedContainer",Name2="Test1"})
    self:AssertEquals(self.CuT2:Serialize(),{Children={},Name="ReplicatedContainer",Name2="Test2"})
    self:AssertEquals(self.CuT3:Serialize(),{Children={},Parent=-1,Name="ReplicatedContainer"})
end))



return true