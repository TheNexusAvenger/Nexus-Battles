--[[
TheNexusAvenger

Tests the TeamSelection class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local NexusReplication = ReplicatedStorageProject:GetResource("External.NexusReplication")
local NexusEvent = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEvent")
local TeamSelection = ReplicatedStorageProject:GetResource("State.TeamSelection")
local TeamSelectionTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function TeamSelectionTest:Setup()
    --Create the event.
    self.ReplicationContainer = Instance.new("Folder")
    self.ReplicationContainer.Name = "Replication"
    self.ReplicationContainer.Parent = ReplicatedStorage

    local RoundContainer = Instance.new("Folder")
    RoundContainer.Name = "Round"
    RoundContainer.Parent = self.ReplicationContainer

    local JoinTeamEvent = Instance.new("RemoteEvent")
    JoinTeamEvent.Name = "JoinTeam"
    JoinTeamEvent.Parent = RoundContainer

    --Create mock players.
    self.MockPlayers = {
        {UserId = 1,Name = "MockPlayer1"},
        {UserId = 2,Name = "MockPlayer2"},
        {UserId = 3,Name = "MockPlayer3"},
        {UserId = 4,Name = "MockPlayer4"},
        {UserId = 5,Name = "MockPlayer5"},
        {UserId = 6,Name = "MockPlayer6"},
        {UserId = 7,Name = "MockPlayer7"},
        {UserId = 8,Name = "MockPlayer8"},
    }

    --Create a mock round.
    self.MockRound = {
        Players = {
            ItemRemoved = NexusEvent.new(),
            Contains = function(_,Player)
                for _,OtherPlayer in pairs(self.MockPlayers) do
                    if Player == OtherPlayer then
                        return true
                    end
                end
                return false
            end,
            GetAll = function()
                return self.MockPlayers
            end,
        },

        --Overhead for Nexus Replication.
        Id = 1,
        IsA = function()
            return true
        end,
    }
    NexusReplication.ObjectRegistry[1] = self.MockRound

    --Create the component under testing.
    self.CuT = TeamSelection.new()
    self.CuT.ParentRound = self.MockRound
    self.CuT:SetTeamColors({
        BrickColor.new("Bright blue"),
        BrickColor.new("Bright red"),
        BrickColor.new("Bright green"),
    })
end

--[[
Tears down the test.
--]]
function TeamSelectionTest:Teardown()
    self.ReplicationContainer:Destroy()
    Teams:ClearAllChildren()
    ReplicatedStorageProject:Clear()
    if ReplicatedStorage:FindFirstChild("Replication") then
        ReplicatedStorage:FindFirstChild("Replication"):Destroy()
    end
end

--[[
Tests the SetPlayerTeam method.
--]]
NexusUnitTesting:RegisterUnitTest(TeamSelectionTest.new("SetPlayerTeam"):SetRun(function(self)
    --Assert teams can't be set to invalid colors or players not in the round.
    self.CuT:SetPlayerTeam(self.MockPlayers[1],BrickColor.new("Bright yellow"))
    self.CuT:SetPlayerTeam({UserId=10,Name = "MockPlayer10"},BrickColor.new("Bright blue"))
    self:AssertEquals(self.CuT.PlayerTeams.Table,{})

    --Assert adding players is set correctly.
    self.CuT:SetPlayerTeam(self.MockPlayers[1],BrickColor.new("Bright blue"))
    self.CuT:SetPlayerTeam(self.MockPlayers[2],BrickColor.new("Bright green"))
    self.CuT:SetPlayerTeam(self.MockPlayers[3],BrickColor.new("Bright green"))
    self.CuT:SetPlayerTeam(self.MockPlayers[4],BrickColor.new("Bright red"))
    self:AssertEquals(self.CuT.PlayerTeams.Table,{
        [self.MockPlayers[1].Name] = BrickColor.new("Bright blue"),
        [self.MockPlayers[2].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[3].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[4].Name] = BrickColor.new("Bright red"),
    })

    --Assert changing teams is set correctly.
    self.CuT:SetPlayerTeam(self.MockPlayers[3],BrickColor.new("Bright red"))
    self:AssertEquals(self.CuT.PlayerTeams.Table,{
        [self.MockPlayers[1].Name] = BrickColor.new("Bright blue"),
        [self.MockPlayers[2].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[3].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[4].Name] = BrickColor.new("Bright red"),
    })
    self:AssertFalse(self.CuT:IsFull(BrickColor.new("Bright blue")))
    self:AssertFalse(self.CuT:IsFull(BrickColor.new("Bright green")))
    self:AssertFalse(self.CuT:IsFull(BrickColor.new("Bright red")))

    --Assert filling a team is correct.
    self.CuT:SetPlayerTeam(self.MockPlayers[5],BrickColor.new("Bright green"))
    self.CuT:SetPlayerTeam(self.MockPlayers[6],BrickColor.new("Bright green"))
    self:AssertEquals(self.CuT.PlayerTeams.Table,{
        [self.MockPlayers[1].Name] = BrickColor.new("Bright blue"),
        [self.MockPlayers[2].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[3].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[4].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[5].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[6].Name] = BrickColor.new("Bright green"),
    })
    self:AssertFalse(self.CuT:IsFull(BrickColor.new("Bright blue")))
    self:AssertTrue(self.CuT:IsFull(BrickColor.new("Bright green")))
    self:AssertFalse(self.CuT:IsFull(BrickColor.new("Bright red")))

    --Assert the full team can't be set.
    self.CuT:SetPlayerTeam(self.MockPlayers[1],BrickColor.new("Bright green"))
    self.CuT:SetPlayerTeam(self.MockPlayers[7],BrickColor.new("Bright green"))
    self:AssertEquals(self.CuT.PlayerTeams.Table,{
        [self.MockPlayers[1].Name] = BrickColor.new("Bright blue"),
        [self.MockPlayers[2].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[3].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[4].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[5].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[6].Name] = BrickColor.new("Bright green"),
    })
    self:AssertFalse(self.CuT:IsFull(BrickColor.new("Bright blue")))
    self:AssertTrue(self.CuT:IsFull(BrickColor.new("Bright green")))
    self:AssertFalse(self.CuT:IsFull(BrickColor.new("Bright red")))

    --Assert removing a player changes the non-full teams to full teams.
    local PlayerToRemove = self.MockPlayers[8]
    table.remove(self.MockPlayers,8)
    PlayerToRemove = self.MockPlayers[5]
    table.remove(self.MockPlayers,5)
    self.MockRound.Players.ItemRemoved:Fire(PlayerToRemove)
    wait()
    self:AssertEquals(self.CuT.PlayerTeams.Table,{
        [self.MockPlayers[1].Name] = BrickColor.new("Bright blue"),
        [self.MockPlayers[2].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[3].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[4].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[5].Name] = BrickColor.new("Bright green"),
    })
    self:AssertFalse(self.CuT:IsFull(BrickColor.new("Bright blue")))
    self:AssertTrue(self.CuT:IsFull(BrickColor.new("Bright green")))
    self:AssertTrue(self.CuT:IsFull(BrickColor.new("Bright red")))
end))

--[[
Tests the Finalize method.
--]]
NexusUnitTesting:RegisterUnitTest(TeamSelectionTest.new("Finalize"):SetRun(function(self)
    --Add some players to the round.
    self.CuT:SetPlayerTeam(self.MockPlayers[1],BrickColor.new("Bright blue"))
    self.CuT:SetPlayerTeam(self.MockPlayers[2],BrickColor.new("Bright green"))
    self.CuT:SetPlayerTeam(self.MockPlayers[3],BrickColor.new("Bright green"))
    self.CuT:SetPlayerTeam(self.MockPlayers[4],BrickColor.new("Bright red"))

    --Finalize the round and assert the players are put into teams correctly.
    self.CuT:Finalize()
    self:AssertEquals(self.CuT.PlayerTeams.Table,{
        [self.MockPlayers[1].Name] = BrickColor.new("Bright blue"),
        [self.MockPlayers[2].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[3].Name] = BrickColor.new("Bright green"),
        [self.MockPlayers[4].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[5].Name] = BrickColor.new("Bright blue"),
        [self.MockPlayers[6].Name] = BrickColor.new("Bright blue"),
        [self.MockPlayers[7].Name] = BrickColor.new("Bright red"),
        [self.MockPlayers[8].Name] = BrickColor.new("Bright red"),
    })
end))



return true