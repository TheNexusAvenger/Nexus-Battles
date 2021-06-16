--[[
TheNexusAvenger

Class for a Rocket Race round.
--]]

local CAPTURE_TIME_SECONDS = 30
local TEAM_COLORS = {
    BrickColor.new("Bright red"),
    BrickColor.new("Bright blue"),
    BrickColor.new("Bright yellow"),
    BrickColor.new("Bright orange"),
    BrickColor.new("Bright green"),
    BrickColor.new("Bright violet"),
    BrickColor.new("Cyan"),
    BrickColor.new("Br. yellowish green"),
    BrickColor.new("Cork"),
    BrickColor.new("Maroon"),
    BrickColor.new("Deep orange"),
    BrickColor.new("Magenta"),
    BrickColor.new("Pastel green"),
    BrickColor.new("Institutional white"),
    BrickColor.new("Really black"),
    BrickColor.new("Burnt Sienna"),
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))

local RocketRace = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
RocketRace:SetClassName("RocketRace")
RocketRace:AddFromSerializeData("RocketRace")
NexusReplication:GetObjectReplicator():RegisterType("RocketRace",RocketRace)



--[[
Creates the round object.
--]]
function RocketRace:__new()
    self:InitializeSuper()
    self.Name = "RocketRace"
end

--[[
Starts the round.
--]]
function RocketRace:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword","RocketLauncher"})
    end

    --Get the checkpoint parts and level end part.
    local LevelEndPart = self.Map:WaitForChild("EndPart")
    local CheckpointParts = {}
    local LocalEffectService = self:GetService("LocalEffectService")
    for _,Part in pairs(self.Map:GetChildren()) do
        if Part.Name == "CheckpointPart" then
            local TeamColorName = Part.BrickColor.Name
            if not CheckpointParts[TeamColorName] then
                CheckpointParts[TeamColorName] = {}
            end
            table.insert(CheckpointParts[TeamColorName],Part)

            --Connect setting the spawn point.
            Part.Touched:Connect(function(TouchPart)
                --Get the player and return if they are dead or not the right team.
                local Character = TouchPart.Parent
                if not Character then return end
                local Humanoid = Character:FindFirstChild("Humanoid")
                if not Humanoid or Humanoid.Health <= 0 then return end
                local Player = Players:GetPlayerFromCharacter(Character)
                if not Player or Player.TeamColor.Name ~= TeamColorName then return end

                --Set the material of the checkpoint parts of the same color.
                for _,OtherPart in pairs(CheckpointParts[TeamColorName]) do
                    OtherPart.Material = ((OtherPart == Part) and Enum.Material.Neon or Enum.Material.Slate)
                end

                --Set the spawn.
                self:SetPlayerSpawn(Player,Part)
            end)
        end
    end

    --Spawn the players.
    for i,Player in pairs(self.Players:GetAll()) do
        Player.Neutral = false
        Player.TeamColor = TEAM_COLORS[i]
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)
        for _,Part in pairs(CheckpointParts[Player.TeamColor.Name]) do
            LocalEffectService:PlayLocalEffect(Player,"StartFlashingPart",Part)
        end
    end

    --Wait for the timer to complete.
    local EndPartCenter,EndPartSizeHalf = LevelEndPart.Position,LevelEndPart.Size/2
    local MinX,MaxX = EndPartCenter.X - EndPartSizeHalf.X,EndPartCenter.X + EndPartSizeHalf.X
    local MinY,MaxY = EndPartCenter.Y,EndPartCenter.Y + 20
    local MinZ,MaxZ = EndPartCenter.Z - EndPartSizeHalf.Z,EndPartCenter.Z + EndPartSizeHalf.Z
    local LastCapturer,LastCaptureStartTime,LastDisplayTimer
    while self.Timer.State ~= "COMPLETE" do
        --Determine the capturing players.
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

        --Update the capturing player.
        if #PlayersInZone == 1 then
            --Start the capture.
            local CapturingPlayer = PlayersInZone[1]
            if CapturingPlayer ~= LastCapturer then
                LastCapturer = CapturingPlayer
                LastCaptureStartTime = tick()
                LocalEffectService:BroadcastLocalEffect(CapturingPlayer,"DisplayAlert",CapturingPlayer.DisplayName.." is now capturing!")
            end

            --End the round or display the time left.
            local DeltaTime = tick() - LastCaptureStartTime
            if DeltaTime >= CAPTURE_TIME_SECONDS then
                self.MVPs = {CapturingPlayer}
                self.Timer:Stop()
                self.Timer.State = "COMPLETE"
                self:End()
            else
                local TimeLeft = CAPTURE_TIME_SECONDS - DeltaTime
                local SecondsLeft = math.ceil(TimeLeft)
                if LastDisplayTimer ~= SecondsLeft then
                    LastDisplayTimer = SecondsLeft
                    LocalEffectService:BroadcastLocalEffect(CapturingPlayer,"DisplayDamageIndicator",LevelEndPart,SecondsLeft,5)
                end
            end
        else
            LastCapturer,LastCaptureStartTime,LastDisplayTimer = nil,nil,nil
        end

        --Wait to continue.
        wait()
    end

    --End the round.
    self:End()
end



return RocketRace