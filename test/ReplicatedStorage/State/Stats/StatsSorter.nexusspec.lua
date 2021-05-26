--[[
TheNexusAvenger

Tests the StatsSorter class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local StatsSorter = ReplicatedStorageProject:GetResource("State.Stats.StatsSorter")
local StatsSorterTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function StatsSorterTest:Setup()
    --Create the mock players.
    self.MockPlayers = {}
    local function CreateMockPlayer(DisplayName,Stats)
        --Create the mock stats.
        local MockStatsContainer
        if Stats then
            MockStatsContainer = Instance.new("Folder")
            MockStatsContainer.Name = "TemporaryStats"
            for Name,Value in pairs(Stats) do
                local MockValue = Instance.new("NumberValue")
                MockValue.Name = Name
                MockValue.Value = Value
                MockValue.Parent = MockStatsContainer
            end
        end

        --Add the mock player.
        local MockPlayer = {
            DisplayName = DisplayName,
            FindFirstChild = function()
                return MockStatsContainer
            end
        }
        table.insert(self.MockPlayers,MockPlayer)
    end
    CreateMockPlayer("MockPlayer1",{
        Stat1 = 3,
        Stat2 = 2,
        Stat3 = 2,
    })
    CreateMockPlayer("MockPlayer2",{
        Stat1 = 4,
        Stat2 = 1,
        Stat3 = 2,
    })
    CreateMockPlayer("MockPlayer3",{
        Stat1 = 3,
        Stat2 = 1,
        Stat3 = 8,
    })
    CreateMockPlayer("MockPlayer4",{
        Stat1 = 5,
    })
    CreateMockPlayer("MockPlayer5")
    CreateMockPlayer("MockPlayer6",{
        Stat1 = 4,
        Stat2 = 1,
        Stat3 = 2,
    })

    --Create the component under test.
    self.CuT = StatsSorter.new({
        {
            Name = "Stat1",
            DefaultValue = 3,
            Prefer = "Higher",
        },
        {
            Name = "Stat2",
            DefaultValue = 3,
            Prefer = "Lower",
        },
        {
            Name = "Stat3",
            DefaultValue = 0,
        },
    })
end

--[[
Tears down the test.
--]]
function StatsSorterTest:Teardown()
    ReplicatedStorageProject:Clear()
end

--[[
Asserts the player names match.
--]]
function StatsSorterTest:AssetPlayerNames(Players,PlayerNames)
    --Convert the players to the names.
    local ActualPlayerNames = {}
    for _,Player in pairs(Players) do
        table.insert(ActualPlayerNames,Player.DisplayName)
    end

    --Assert the names are the same.
    self:AssertEquals(ActualPlayerNames,PlayerNames)
end

--[[
Tests the GetSortedPlayers method.
--]]
NexusUnitTesting:RegisterUnitTest(StatsSorterTest.new("GetSortedPlayers"):SetRun(function(self)
    --Test the sorted players are correct with all values populated.
    self:AssetPlayerNames(self.CuT:GetSortedPlayers({self.MockPlayers[1],self.MockPlayers[2]},{}),{"MockPlayer2","MockPlayer1"})
    self:AssetPlayerNames(self.CuT:GetSortedPlayers({self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3]},{}),{"MockPlayer2","MockPlayer3","MockPlayer1"})

    --Test the sorted players are correct with missing values.
    self:AssetPlayerNames(self.CuT:GetSortedPlayers({self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3],self.MockPlayers[4],self.MockPlayers[5]},{}),{"MockPlayer4","MockPlayer2","MockPlayer3","MockPlayer1","MockPlayer5"})

    --Test that MVP players appear at the front.
    self:AssetPlayerNames(self.CuT:GetSortedPlayers({self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3],self.MockPlayers[4],self.MockPlayers[5]},{},{self.MockPlayers[1]}),{"MockPlayer1","MockPlayer4","MockPlayer2","MockPlayer3","MockPlayer5"})
    self:AssetPlayerNames(self.CuT:GetSortedPlayers({self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3],self.MockPlayers[4],self.MockPlayers[5]},{},{self.MockPlayers[1],self.MockPlayers[3]}),{"MockPlayer3","MockPlayer1","MockPlayer4","MockPlayer2","MockPlayer5"})
end))

--[[
Tests the GetMVPs method.
--]]
NexusUnitTesting:RegisterUnitTest(StatsSorterTest.new("GetMVPs"):SetRun(function(self)
    --Test the MVPs are correct with all values populated.
    self:AssetPlayerNames(self.CuT:GetMVPs({self.MockPlayers[1],self.MockPlayers[2]}),{"MockPlayer2"})
    self:AssetPlayerNames(self.CuT:GetMVPs({self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[6]}),{"MockPlayer2","MockPlayer6"})

    --Test the MVPs are correct with missing values.
    self:AssetPlayerNames(self.CuT:GetMVPs({self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3],self.MockPlayers[4],self.MockPlayers[5],self.MockPlayers[6]}),{"MockPlayer4"})
    self:AssetPlayerNames(self.CuT:GetMVPs({self.MockPlayers[1],self.MockPlayers[4]}),{"MockPlayer4"})
    self:AssetPlayerNames(self.CuT:GetMVPs({self.MockPlayers[1],self.MockPlayers[5]}),{"MockPlayer1"})
    self:AssetPlayerNames(self.CuT:GetMVPs({self.MockPlayers[4],self.MockPlayers[5]}),{"MockPlayer4"})
end))



return true