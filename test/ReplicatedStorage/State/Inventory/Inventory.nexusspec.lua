--[[
TheNexusAvenger

Tests the Inventory class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local Inventory = ReplicatedStorageProject:GetResource("State.Inventory.Inventory")
local InventoryTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function InventoryTest:Setup()
    --Create the component under testing.
    self.InventoryValue = Instance.new("StringValue")
    self.InventoryValue.Value = HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    })
    self.CuT = Inventory.new(self.InventoryValue)
end

--[[
Tears down the test.
--]]
function InventoryTest:Teardown()
    self.CuT:Destroy()
    ReplicatedStorageProject:Clear()
end

--[[
Tests the Save method.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("Save"):SetRun(function(self)
    self.CuT:GetItemAtSlot(4).Slot = 2
    self.CuT:GetItemAtSlot(5).Slot = "Body"
    self.CuT:Save()
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 2,
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
    }))
end))

--[[
Tests the GetItemAtSlot method.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("GetItemAtSlot"):SetRun(function(self)
    self:AssertEquals(self.CuT:GetItemAtSlot(1).Id,1)
    self:AssertNil(self.CuT:GetItemAtSlot(2))
    self:AssertNil(self.CuT:GetItemAtSlot(3))
    self:AssertEquals(self.CuT:GetItemAtSlot(4).Id,101)
    self:AssertEquals(self.CuT:GetItemAtSlot(5).Id,101)
    self:AssertNil(self.CuT:GetItemAtSlot(6))
    self:AssertEquals(self.CuT:GetItemAtSlot("Head").Id,2)
    self:AssertNil(self.CuT:GetItemAtSlot("Body"))
end))

--[[
Tests the GetNextSlot method.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("GetNextSlot"):SetRun(function(self)
    self:AssertEquals(self.CuT:GetNextSlot(),2)
    self.CuT:GetItemAtSlot(4).Slot = 2
    self:AssertEquals(self.CuT:GetNextSlot(),3)
    self.CuT:GetItemAtSlot(1).Slot = 3
    self:AssertEquals(self.CuT:GetNextSlot(),1)
end))

--[[
Tests the Reload method with setting the value.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("Reload"):SetRun(function(self)
    self.InventoryValue.Value = HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 2,
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
    })
    wait()
    self:AssertEquals(self.CuT:GetItemAtSlot(1).Id,1)
    self:AssertEquals(self.CuT:GetItemAtSlot(2).Id,101)
    self:AssertNil(self.CuT:GetItemAtSlot(3))
    self:AssertNil(self.CuT:GetItemAtSlot(4))
    self:AssertNil(self.CuT:GetItemAtSlot(5))
    self:AssertEquals(self.CuT:GetItemAtSlot("Head").Id,2)
    self:AssertEquals(self.CuT:GetItemAtSlot("Body").Id,101)
end))

--[[
Tests the CanMoveToSlot method.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("CanMoveToSlot"):SetRun(function(self)
    --Assert with no items at the slot.
    self:AssertTrue(self.CuT:CanMoveToSlot(6,2))
    self:AssertTrue(self.CuT:CanMoveToSlot(6,"Head"))

    --Assert with number slots for items.
    self:AssertTrue(self.CuT:CanMoveToSlot(1,2))
    self:AssertTrue(self.CuT:CanMoveToSlot("Head",3))
    self:AssertFalse(self.CuT:CanMoveToSlot(1,3.2))
    self:AssertFalse(self.CuT:CanMoveToSlot("Head",3.2))
    self:AssertFalse(self.CuT:CanMoveToSlot(1,0))
    self:AssertFalse(self.CuT:CanMoveToSlot("Head",0))
    self:AssertFalse(self.CuT:CanMoveToSlot(1,-1))
    self:AssertFalse(self.CuT:CanMoveToSlot("Head",-1))

    --Assert with non-number slots for items.
    self:AssertTrue(self.CuT:CanMoveToSlot(1,"Head"))
    self:AssertFalse(self.CuT:CanMoveToSlot(1,"Body"))
    self:AssertTrue(self.CuT:CanMoveToSlot(4,"Body"))
    self:AssertFalse(self.CuT:CanMoveToSlot(4,"Head"))
end))

--[[
Tests the AddItem method.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("AddItem"):SetRun(function(self)
    --Test adding valid items.
    self:AssertEquals(self.CuT:AddItem(102),2)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
        {
            Id = 102,
            Health = 660,
            Slot = 2,
        },
    }))
    self:AssertEquals(self.CuT:AddItem(107),3)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
        {
            Id = 102,
            Health = 660,
            Slot = 2,
        },
        {
            Id = 107,
            Slot = 3,
        },
    }))

    --Test adding a non-existent item.
    self:AssertNil(self.CuT:AddItem(299))
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
        {
            Id = 102,
            Health = 660,
            Slot = 2,
        },
        {
            Id = 107,
            Slot = 3,
        },
    }))
end))

--[[
Tests the RemoveItem method.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("RemoveItem"):SetRun(function(self)
    --Test removing valid items.
    self.CuT:RemoveItem(4)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))
    self.CuT:RemoveItem("Head")
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))

    --Test removing a non-existent item.
    self.CuT:RemoveItem(10)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 1,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))
end))

--[[
Tests the DamageItem method.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("DamageItem"):SetRun(function(self)
    --Test damaging items.
    self.CuT:DamageItem(1,50)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 150,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))
    self.CuT:DamageItem("Head",100)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 150,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 150,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))

    --Test a negative damage.
    self.CuT:DamageItem(1,-50)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 150,
            Slot = 1,
        },
        {
            Id = 2,
            Health = 150,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))

    --Test destroying an item.
    self.CuT:DamageItem("Head",150)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 150,
            Slot = 1,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))
    self.CuT:DamageItem(1,200)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))
end))

--[[
Tests the SwapItems method.
--]]
NexusUnitTesting:RegisterUnitTest(InventoryTest.new("SwapItems"):SetRun(function(self)
    --Test swapping items with 1 empty slot.
    self.CuT:SwapItems(1,3)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 3,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 4,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))
    self.CuT:SwapItems(4,"Body")
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 3,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 5,
        },
    }))

    --Test swapping between slots.
    self.CuT:SwapItems(3,5)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 5,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 3,
        },
    }))
    self.CuT:SwapItems("Body",3)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = 5,
        },
        {
            Id = 2,
            Health = 250,
            Slot = "Head",
        },
        {
            Id = 101,
            Health = 400,
            Slot = 3,
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
    }))
    self.CuT:SwapItems(5,"Head")
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = "Head",
        },
        {
            Id = 2,
            Health = 250,
            Slot = 5,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 3,
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
    }))

    --Test invalid item swaps.
    self.CuT:SwapItems("Body","Head")
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = "Head",
        },
        {
            Id = 2,
            Health = 250,
            Slot = 5,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 3,
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
    }))
    self.CuT:SwapItems(3,"Head")
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = "Head",
        },
        {
            Id = 2,
            Health = 250,
            Slot = 5,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 3,
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
    }))
    self.CuT:SwapItems(3,-1)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = "Head",
        },
        {
            Id = 2,
            Health = 250,
            Slot = 5,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 3,
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
    }))

    --Test swapping between phantom slots.
    self.CuT:SwapItems(8,9)
    self:AssertEquals(self.InventoryValue.Value,HttpService:JSONEncode({
        {
            Id = 1,
            Health = 200,
            Slot = "Head",
        },
        {
            Id = 2,
            Health = 250,
            Slot = 5,
        },
        {
            Id = 101,
            Health = 400,
            Slot = 3,
        },
        {
            Id = 101,
            Health = 400,
            Slot = "Body",
        },
    }))
end))



return true