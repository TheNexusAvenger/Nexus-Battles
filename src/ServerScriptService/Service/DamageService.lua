--[[
TheNexusAvenger

Service for damaging players.

TODO: Connect humanoids dieing; current implementation makes it so
players who reset or fall into the void don't register kills.
--]]

local TAG_EXPIRE_TIME_SECONDS = 10

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")
local StatService = ServerScriptServiceProject:GetResource("Service.StatService")

local DamageService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
DamageService:SetClassName("DamageService")
DamageService.HumanoidTags = {}
DamageService.PlayersToHumanoids = {}



--[[
Damages a humanoid.
--]]
function DamageService:DamageHumanoid(Humanoid,Damage,DamagingPlayer,DamagingToolName)
    if not Humanoid.Parent then return end
    if Humanoid.Health == 0 then return end
    Damage = math.min(Damage,Humanoid.Health)

    --Set up the humanoid.
    local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)
    if not self.HumanoidTags[Humanoid] then
        self.HumanoidTags[Humanoid] = {}
        if Player then
            self.PlayersToHumanoids[Player] = Humanoid
        end
    end

    --Add the tag.
    if DamagingPlayer or Player then
        table.insert(self.HumanoidTags[Humanoid],{
            Damage = Damage,
            Player = DamagingPlayer or Player,
            Tool = DamagingToolName,
            Time = tick(),
        })
    end

    --Damage the humanoid.
    Humanoid:TakeDamage(Damage)

    --Award the player kill.
    if Humanoid.Health <= 0 and Player then
        --Split the tags by damaging player.
        local HumanoidTagsByPlayer = {}
        for _,Tag in pairs(self.HumanoidTags[Humanoid]) do
            if tick() - Tag.Time  <= TAG_EXPIRE_TIME_SECONDS then
                --Store the killing player information.
                if not HumanoidTagsByPlayer[Tag.Player] then
                    HumanoidTagsByPlayer[Tag.Player] = {
                        Damage = 0,
                        LastToolTime = 0,
                    }
                end

                --Add the damage.
                local TotalTagData = HumanoidTagsByPlayer[Tag.Player]
                TotalTagData.Damage = TotalTagData.Damage + Tag.Damage
                if Tag.Time > TotalTagData.LastToolTime then
                    TotalTagData.LastToolTime = Tag.Time
                    TotalTagData.LastTool = Tag.Tool
                end
            end
        end

        --Get the player who did the most damage.
        local MostDamage,MostDamagePlayer,MostDamageTool = 0,nil,nil
        for KillingPlayer,PlayerDamageData in pairs(HumanoidTagsByPlayer) do
            if PlayerDamageData.Damage > MostDamage then
                MostDamagePlayer = KillingPlayer
                MostDamageTool = PlayerDamageData.LastTool
            end
        end

        --Award the kill.
        local DamagedPlayerPersistentStats = StatService:GetPersistentStats(Player)
        local DamagedPlayerTemporaryStats = StatService:GetTemporaryStats(Player,false)
        if not MostDamagePlayer or MostDamagePlayer == Player then
            --Display the killfeed.
            print("Player killed self: "..tostring(Player)) --TODO: Killfeed
        else
            --Display the killfeed.
            print(tostring(Player).." killed by "..tostring(MostDamagePlayer).." with "..tostring(MostDamageTool)) --TODO: Killfeed

            --Drop the coins.
            --TODO: Drop coins

            --Increment the stats.
            local KillingPlayerPersistentStats = StatService:GetPersistentStats(MostDamagePlayer)
            local KillingPlayerTemporaryStats = StatService:GetTemporaryStats(MostDamagePlayer,false)
            KillingPlayerPersistentStats:Create("TotalKOs_"..tostring(MostDamageTool))
            KillingPlayerPersistentStats:Get("TotalKOs"):Increment(1)
            KillingPlayerPersistentStats:Get("TotalKOs_"..tostring(MostDamageTool)):Increment(1)
            if KillingPlayerTemporaryStats then
                KillingPlayerTemporaryStats:Create("KOs_"..tostring(MostDamageTool))
                KillingPlayerTemporaryStats:Get("KOs"):Increment(1)
                KillingPlayerTemporaryStats:Get("KOs_"..tostring(MostDamageTool)):Increment(1)
                KillingPlayerTemporaryStats:Get("CurrentStreak"):Increment(1)
                if KillingPlayerTemporaryStats:Get("CurrentStreak"):Get() > KillingPlayerTemporaryStats:Get("MaxStreak"):Get() then
                    KillingPlayerTemporaryStats:Get("MaxStreak"):Set(KillingPlayerTemporaryStats:Get("CurrentStreak"):Get())
                end
                if KillingPlayerTemporaryStats:Get("KOs"):Get() > KillingPlayerPersistentStats:Get("MostKOs"):Get() then
                    KillingPlayerPersistentStats:Get("MostKOs"):Set(KillingPlayerTemporaryStats:Get("KOs"):Get())
                end
                if KillingPlayerTemporaryStats:Get("CurrentStreak"):Get() > KillingPlayerPersistentStats:Get("LongestKOStreak"):Get() then
                    KillingPlayerPersistentStats:Get("LongestKOStreak"):Set(KillingPlayerTemporaryStats:Get("CurrentStreak"):Get())
                end
            end

            --Focus on the credited player.
            LocalEffectService:PlayLocalEffect(Player,"FocusKillingPlayer",MostDamagePlayer)
        end

        --Award the wipeout.
        DamagedPlayerPersistentStats:Get("TotalWOs"):Increment(1)
        if DamagedPlayerTemporaryStats then
            DamagedPlayerTemporaryStats:Get("WOs"):Increment(1)
            DamagedPlayerTemporaryStats:Get("CurrentStreak"):Set(0)
            if DamagedPlayerTemporaryStats:Get("WOs"):Get() > DamagedPlayerPersistentStats:Get("MostWOs"):Get() then
                DamagedPlayerPersistentStats:Get("MostWOs"):Set(DamagedPlayerTemporaryStats:Get("WOs"):Get())
            end
        end
    end

    --Display the indicator.
    local Head = Humanoid.Parent:FindFirstChild("Head")
    if Head and math.floor(Damage + 0.5) > 0 then
        LocalEffectService:BroadcastLocalEffect(DamagingPlayer,"DisplayDamageIndicator",Head,Damage)
    end
    if DamagingPlayer then
        LocalEffectService:PlayLocalEffect(DamagingPlayer,"PlayHitSound")
    end
end



--Connect players leaving.
Players.PlayerRemoving:Connect(function(Player)
    DamageService.PlayersToHumanoids[Player] = nil
end)



return DamageService