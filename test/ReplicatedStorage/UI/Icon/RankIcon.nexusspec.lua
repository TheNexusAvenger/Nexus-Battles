--[[
TheNexusAvenger

Tests the RankIcon class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RankIcon = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("Icon"):WaitForChild("RankIcon"))
local RankIconTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function RankIconTest:Setup()
    --Creates the mock player.
    self.MockPlayer1 = Instance.new("Folder")
    self.MockPlayer2 = Instance.new("Folder")

    self.MockStats = Instance.new("Folder")
    self.MockStats.Name = "PersistentStats"
    self.MockStats.Parent = self.MockPlayer1

    self.MockRankScore = Instance.new("NumberValue")
    self.MockRankScore.Name = "RankScore"
    self.MockRankScore.Value = 276
    self.MockRankScore.Parent = self.MockStats

    --Create the mock Nexus Admin.
    self.MockPlayer1AdminLevel = 0
    self.MockAdminLevelChangedEvent = Instance.new("BindableEvent")
    self.MockNexusAdmin = {
        Authorization = {
            GetAdminLevel = function()
                return self.MockPlayer1AdminLevel
            end,
            AdminLevelChanged = self.MockAdminLevelChangedEvent.Event,
        }
    }
    RankIcon.NexusAdmin = self.MockNexusAdmin

    --Create the component under testing.
    self.ImageLabel = Instance.new("ImageLabel")
    self.CuT = RankIcon.new(self.ImageLabel)
end

--[[
Tears down the test.
--]]
function RankIconTest:Teardown()
    self.CuT:Destroy()
    self.MockPlayer1:Destroy()
    self.MockPlayer2:Destroy()
    self.MockAdminLevelChangedEvent:Destroy()
end


--[[
Tests the Update method (indirectly).
--]]
NexusUnitTesting:RegisterUnitTest(RankIconTest.new("Update"):SetRun(function(self)
    --Set a player and assert the image is set to the initial state.
    self.CuT.Player = self.MockPlayer1
    wait()
    self:AssertEquals(self.ImageLabel.Image,"rbxassetid://6866145490")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(512,0))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(230/255,230/255,230/255))

    --Update the rank score and assert the values are correct.
    self.MockRankScore.Value = 1632
    wait()
    self:AssertEquals(self.ImageLabel.Image,"rbxassetid://6866145490")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(0,512))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(235/255,200/255,0))
    self.MockRankScore.Value = -1
    wait()
    self:AssertEquals(self.ImageLabel.Image,"")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(0,0))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(0,0))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(1,1,1))
    self.MockRankScore.Value = 0
    wait()
    self:AssertEquals(self.ImageLabel.Image,"rbxassetid://6866145490")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(0,0))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(180/255,110/255,0))

    --Set the admin level and assert icon changes.
    self.MockPlayer1AdminLevel = 1
    self.MockAdminLevelChangedEvent:Fire(self.MockPlayer1)
    wait()
    self:AssertEquals(self.ImageLabel.Image,"rbxassetid://6866145490")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(0,0))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(255/255,0,0))
    self.MockPlayer1AdminLevel = 6
    self.MockAdminLevelChangedEvent:Fire(self.MockPlayer1)
    wait()
    self:AssertEquals(self.ImageLabel.Image,"rbxassetid://6866145490")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(255/255,0,0))

    --Change the rank score and assert the value doesn't change.
    self.MockAdminLevelChangedEvent:Fire(self.MockPlayer2)
    wait()
    self:AssertEquals(self.ImageLabel.Image,"rbxassetid://6866145490")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(255/255,0,0))

    --Change the admin level of another player and assert the icon doesn't change.
    self.MockRankScore.Value = 1632
    wait()
    self:AssertEquals(self.ImageLabel.Image,"rbxassetid://6866145490")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(255/255,0,0))

    --Reset the admin level to 0 and assert the icon changes.
    self.MockPlayer1AdminLevel = 0
    self.MockAdminLevelChangedEvent:Fire(self.MockPlayer1)
    wait()
    self:AssertEquals(self.ImageLabel.Image,"rbxassetid://6866145490")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(0,512))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(512,512))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(235/255,200/255,0))

    --Unset the player and assert that the icon resets.
    self.CuT.Player = nil
    wait()
    self:AssertEquals(self.ImageLabel.Image,"")
    self:AssertEquals(self.ImageLabel.ImageRectOffset,Vector2.new(0,0))
    self:AssertEquals(self.ImageLabel.ImageRectSize,Vector2.new(0,0))
    self:AssertEquals(self.ImageLabel.ImageColor3,Color3.new(1,1,1))
end))



return true