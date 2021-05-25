--[[
TheNexusAvenger

Tests the CharacterModifiers class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterModifiers = require(ReplicatedStorage:WaitForChild("State"):WaitForChild("CharacterModifiers"))
local CharacterModifiersTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function CharacterModifiersTest:Setup()
    --Create the container and component under testing.
    self.TestContainer = Instance.new("Folder")
    self.CuT = CharacterModifiers.new(self.TestContainer)
end

--[[
Tears down the test.
--]]
function CharacterModifiersTest:Teardown()
    self.TestContainer:Destroy()
    self.CuT:Destroy()
end

--[[
Tests the modifiers changing.
--]]
NexusUnitTesting:RegisterUnitTest(CharacterModifiersTest.new("ChangingModifiers"):SetRun(function(self)
    --Connect the event for modifiers changing.
    local ChangedModifiers = {}
    self.CuT.ModifierChanged:Connect(function(Type,Value)
        table.insert(ChangedModifiers,{Type,Value})
    end)

    --Add a few modifiers and assert the totals are correct.
    self.CuT:Add("Key1","Type1",0.1)
    self.CuT:Add("Key2","Type2",0.2)
    self.CuT:Add("Key3","Type1",0.3)
    self:AssertClose(self.CuT:Get("Type1"),0.4,0.001)
    self:AssertClose(self.CuT:Get("Type2"),0.2,0.001)
    self:AssertEquals(self.CuT:Get("Type3"),0)

    --Assert duplicate keys can't be used.
    self:AssertErrors(function()
        self.CuT:Add("Key1","Type1",0.1)
    end)
    self:AssertErrors(function()
        self.CuT:Add("Key1","Type3",0.1)
    end)

    --Remove and re-add a modifier.
    self.CuT:Remove("Key3")
    self.CuT:Add("Key3","Type2",0.4)
    self:AssertClose(self.CuT:Get("Type1"),0.1,0.001)
    self:AssertClose(self.CuT:Get("Type2"),0.6,0.001)

    --Assert externally modified values change the modifiers.
    local ExternalValue = Instance.new("NumberValue")
    ExternalValue.Name = "Type2"
    ExternalValue.Value = 0.5
    ExternalValue.Parent = self.CuT.ModifiersContainer
    wait()
    self:AssertClose(self.CuT:Get("Type1"),0.1,0.001)
    self:AssertClose(self.CuT:Get("Type2"),1.1,0.001)
    ExternalValue.Value = 0.6
    wait()
    self:AssertClose(self.CuT:Get("Type1"),0.1,0.001)
    self:AssertClose(self.CuT:Get("Type2"),1.2,0.001)
    ExternalValue:Destroy()
    wait()
    self:AssertClose(self.CuT:Get("Type1"),0.1,0.001)
    self:AssertClose(self.CuT:Get("Type2"),0.6,0.001)

    --Remove all the keys.
    self.CuT:Remove("Key1")
    self.CuT:Remove("Key2")
    self.CuT:Remove("Key3")
    self.CuT:Remove("Key4")
    self:AssertEquals(self.CuT:Get("Type1"),0)
    self:AssertEquals(self.CuT:Get("Type2"),0)
    self:AssertEquals(self.CuT:Get("Type3"),0)

    --Assert the modifier events are correct.
    local ExpectedEventResults = {
        {"Type1",0.1},
        {"Type2",0.2},
        {"Type1",0.4},
        {"Type1",0.1},
        {"Type2",0.6},
        {"Type2",1.1},
        {"Type2",1.2},
        {"Type2",0.6},
        {"Type1",0},
        {"Type2",0.4},
        {"Type2",0},
    }
    wait()
    for i,ExpectedResult in pairs(ExpectedEventResults) do
        local ActualResult = ChangedModifiers[i]
        self:AssertEquals(ExpectedResult[1],ActualResult[1],"Result "..tostring(i).." doesn't  match")
        self:AssertClose(ExpectedResult[2],ActualResult[2],0.001,"Result "..tostring(i).." doesn't  match")
    end
end))



return true