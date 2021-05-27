--[[
TheNexusAvenger

Service for damaging players.
--]]

local TAG_EXPIRE_TIME_SECONDS = 10
local MINIMUM_KILLS_FOR_INCREASED_COINS = 3
local KILLSTREAK_MESSAGES = {
    [3] = {AudioId = 104480252,Message = "'s on a streak!"},
    [5] = {AudioId = 104480252,Message = " is on fire!"},
    [8] = {AudioId = 104480252,Message = " is UNSTOPPABLE!"},
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local NexusEventCreator = ReplicatedStorageProject:GetResource("External.NexusInstance.Event.NexusEventCreator")
local CoinService = ServerScriptServiceProject:GetResource("Service.CoinService")
local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")
local ModifierService = ServerScriptServiceProject:GetResource("Service.ModifierService")
local RoundService = ServerScriptServiceProject:GetResource("Service.RoundService")
local StatService = ServerScriptServiceProject:GetResource("Service.StatService")

local DamageService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
DamageService:SetClassName("DamageService")
DamageService.HumanoidTags = {}
DamageService.PlayersToHumanoids = {}
DamageService.PlayerKOEvents = {}
DamageService.PlayerWOEvents = {}



--[[
Connects a character being added.
--]]
local function CharacterAdded(Character)
    --Return if there is no character.
    if not Character then return end
    local Player = Players:GetPlayerFromCharacter(Character)

    --Connect the character being killed.
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid.Died:Connect(function()
        --Split the tags by damaging player.
        local HumanoidTagsByPlayer = {}
        for _,Tag in pairs(DamageService.HumanoidTags[Humanoid] or {}) do
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
            LocalEffectService:BroadcastLocalEffect(Player,"DisplayKillFeed",{
                KilledPlayer = Player,
            })

            --Fire the WO event.
            if DamageService.PlayerWOEvents[Player] then
                DamageService.PlayerWOEvents[Player]:Fire()
            end
        else
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

            --Display the killfeed.
            if KillingPlayerTemporaryStats then
                local KillStreak = KillingPlayerTemporaryStats:Get("CurrentStreak"):Get()
                local KillstreakMessage = KILLSTREAK_MESSAGES[KillStreak]
                if KillstreakMessage then
                    LocalEffectService:BroadcastLocalEffect(Player,"DisplayKillFeed",{
                        Message = MostDamagePlayer.DisplayName..KillstreakMessage.Message,
                        AudioId = KillstreakMessage.AudioId,
                    })
                end
            end
            LocalEffectService:BroadcastLocalEffect(Player,"DisplayKillFeed",{
                KilledPlayer = Player,
                KillingPlayer = MostDamagePlayer,
                MostDamageTool = MostDamageTool,
            })

            --Drop the coins.
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                local TotalCoins = 4
                local KillStreak = KillingPlayerTemporaryStats:Get("CurrentStreak"):Get()
                if KillStreak >= MINIMUM_KILLS_FOR_INCREASED_COINS then
                    TotalCoins = TotalCoins + (KillStreak - MINIMUM_KILLS_FOR_INCREASED_COINS + 1)
                end
                for _ = 1,TotalCoins do
                    CoinService:DropCoin(HumanoidRootPart.Position,RoundService:GetPlayerRoundContainer(Player))
                end
            end

            --Fire the KO and WO events.
            if DamageService.PlayerKOEvents[MostDamagePlayer] then
                DamageService.PlayerKOEvents[MostDamagePlayer]:Fire(Player,MostDamageTool)
            end
            if DamageService.PlayerWOEvents[Player] then
                DamageService.PlayerWOEvents[Player]:Fire(MostDamagePlayer,MostDamageTool)
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
    end)
end

--[[
Connects a player being added.
--]]
local function PlayerAdded(Player)
    Player.CharacterAdded:Connect(CharacterAdded)
    CharacterAdded(Player.Character)
end


--[[
Damages a humanoid.
--]]
function DamageService:DamageHumanoid(Humanoid,Damage,DamagingPlayer,DamagingToolName)
    if not Humanoid.Parent then return end
    if Humanoid.Health == 0 then return end

    --Set up the humanoid.
    local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)
    if not self.HumanoidTags[Humanoid] then
        self.HumanoidTags[Humanoid] = {}
        if Player then
            self.PlayersToHumanoids[Player] = Humanoid
        end
    end

    --Determine the damage.
    local Modifiers = ModifierService:GetModifiers(Player)
    --TODO: Damage armor based on initial math.min(Damage,Humanoid.Health)
    if Modifiers then
        Damage = Damage * (1 - Modifiers:Get("AbsorbDamage"))
    end
    Damage = math.min(Damage,Humanoid.Health)

    --Add the tag.
    if DamagingPlayer and DamagingPlayer ~= Player then
        table.insert(self.HumanoidTags[Humanoid],{
            Damage = Damage,
            Player = DamagingPlayer,
            Tool = DamagingToolName,
            Time = tick(),
        })
    end

    --Damage the humanoid.
    Humanoid:TakeDamage(Damage)

    --Display the indicator.
    local Head = Humanoid.Parent:FindFirstChild("Head")
    if Head and math.floor(Damage + 0.5) > 0 then
        LocalEffectService:BroadcastLocalEffect(DamagingPlayer,"DisplayDamageIndicator",Head,Damage)
    end
    if DamagingPlayer then
        LocalEffectService:PlayLocalEffect(DamagingPlayer,"PlayHitSound")
    end
end

--[[
Returns the KO event for a player.
--]]
function DamageService:GetKOEvent(Player)
    if not self.PlayerKOEvents[Player] then
        self.PlayerKOEvents[Player] = NexusEventCreator:CreateEvent()
    end
    return self.PlayerKOEvents[Player]
end

--[[
Returns the WO event for a player.
--]]
function DamageService:GetWOEvent(Player)
    if not self.PlayerWOEvents[Player] then
        self.PlayerWOEvents[Player] = NexusEventCreator:CreateEvent()
    end
    return self.PlayerWOEvents[Player]
end



--Connect players leaving.
Players.PlayerAdded:Connect(PlayerAdded)
for _,Player in pairs(Players:GetPlayers()) do
    coroutine.wrap(function()
        PlayerAdded(Player)
    end)()
end
Players.PlayerRemoving:Connect(function(Player)
    DamageService.PlayersToHumanoids[Player] = nil
    DamageService.PlayerKOEvents[Player] = nil
    DamageService.PlayerWOEvents[Player] = nil
end)



return DamageService