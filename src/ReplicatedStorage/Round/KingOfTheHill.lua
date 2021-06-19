--[[
TheNexusAvenger

Class for a King Of The Hill round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local KingOfTheHill = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
KingOfTheHill:SetClassName("KingOfTheHill")
NexusReplication:RegisterType("KingOfTheHill",KingOfTheHill)



--[[
Creates the round object.
--]]
function KingOfTheHill:__new()
    self:InitializeSuper()
    self.Name = "KingOfTheHill"

    --Add the time stat.
    table.insert(self.RoundStats,1,{
        Name = "Time",
        ValueType = "IntValue",
        DefaultValue = 0,
        ShowInLeaderstats = true,
        Prefer = "Higher",
    })
end

--[[
Starts the round.
--]]
function KingOfTheHill:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword","Superball","Slingshot","Bomb","RocketLauncher","Reflector"})
    end

    --Spawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)
    end

    --Update the King Of The Hill times until the round ends.
    local TimeTotals = {}
    local KingPart = self.Map:WaitForChild("KingPart")
    local KingPartCenter,KingPartSizeHalf = KingPart.Position,KingPart.Size/2
    local MinX,MaxX = KingPartCenter.X - KingPartSizeHalf.X,KingPartCenter.X + KingPartSizeHalf.X
    local MinY,MaxY = KingPartCenter.Y - KingPartSizeHalf.Y,KingPartCenter.Y + KingPartSizeHalf.Y
    local MinZ,MaxZ = KingPartCenter.Z - KingPartSizeHalf.Z,KingPartCenter.Z + KingPartSizeHalf.Z
    while self.Timer.State ~= "COMPLETE" do
        --Wait and get the time that passed.
        local DeltaTime = wait()

        --Get the players in the zone.
        local PlayersInZone = {}
        for _,Player in pairs(self.Players:GetAll()) do
            local Character = Player.Character
            if Player.Character then
                local Humanoid = Character:FindFirstChild("Humanoid")
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                if Humanoid and Humanoid.Health > 0 and HumanoidRootPart then
                    local PlayerPosition = HumanoidRootPart.Position
                    if PlayerPosition.X >= MinX and PlayerPosition.X <= MaxX and PlayerPosition.Y >= MinY and PlayerPosition.Y <= MaxY and PlayerPosition.Z >= MinZ and PlayerPosition.Z <= MaxZ then
                        table.insert(PlayersInZone,Player)
                    end
                end
            end
        end

        --Add the time to the player if ther eis one.
        if #PlayersInZone == 1 then
            local KingOfTheHillPlayer = PlayersInZone[1]

            --Add the time to the player.
            if not TimeTotals[KingOfTheHillPlayer] then
                TimeTotals[KingOfTheHillPlayer] = 0
            end
            TimeTotals[KingOfTheHillPlayer] = TimeTotals[KingOfTheHillPlayer] + DeltaTime

            --Mirror the time to the temporary stat.
            local Stats = self:GetService("StatService"):GetTemporaryStats(KingOfTheHillPlayer)
            if Stats then
                Stats:Get("Time"):Set(TimeTotals[KingOfTheHillPlayer])
            end
        end
    end

    --End the round.
    self:End()
end



return KingOfTheHill