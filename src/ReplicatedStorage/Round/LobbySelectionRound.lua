--[[
TheNexusAvenger

"Round" for players selecting and starting rounds in the lobby.
--]]

local ROUND_SELECTION_DURATION = 60
local PLAYERS_READY_TIME = 3
local BORDER_COLOR_MULTIPLIER = 0.6
local PART_BORDER_SIZE = 0.4
local BORDER_IDLE_ANIMATION_SPEED = 0.5



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))
local ObjectReplication = NexusRoundSystem:GetObjectReplicator()

local LobbySelectionRound = NexusRoundSystem:GetResource("Common.Object.Base.ReplicatedContainer"):Extend()
LobbySelectionRound:SetClassName("LobbySelectionRound")
LobbySelectionRound:AddFromSerializeData("LobbySelectionRound")
NexusRoundSystem:GetObjectReplicator():RegisterType("LobbySelectionRound",LobbySelectionRound)



--[[
Creates the round object.
--]]
function LobbySelectionRound:__new()
    self:InitializeSuper()
    self.Name = "LobbySelectionRound"

    --Store the round data.
    if NexusRoundSystem:IsServer() then
        self.Players = ObjectReplication:CreateObject("ReplicatedTable")
        self.ReadyPlayers = ObjectReplication:CreateObject("ReplicatedTable")
        self.Timer = ObjectReplication:CreateObject("Timer")
        self.Timer:SetDuration(ROUND_SELECTION_DURATION)
    end
    self:AddToSerialization("RoundName")
    self:AddToSerialization("RequiredPlayers")
    self:AddToSerialization("MaxPlayers")
    self:AddToSerialization("SelectionPart")
	self:AddToSerialization("Players","ObjectReference")
	self:AddToSerialization("ReadyPlayers","ObjectReference")
    self:AddToSerialization("Timer","ObjectReference")
    self.RoundName = "Unnamed"
    self.RequiredPlayers = 1
    self.MaxPlayers = 10

    --Initialize the selector.
    if NexusRoundSystem:IsServer() then
        --Update players entering and leaving the part.
        coroutine.wrap(function()
            while self.Timer.State ~= "COMPLETE" do
                self:UpdatePlayers()
                wait()
            end
        end)()

        --Connect players leaving.
        self.PlayerRemovingEvent = Players.PlayerRemoving:Connect(function(Player)
            self.Players:Remove(Player)
        end)

        --Connect players being added and removed.
        self.Players.ItemAdded:Connect(function()
            self:UpdateTimer()
        end)
        self.Players.ItemRemoved:Connect(function(Player)
            self.ReadyPlayers:Remove(Player)
            self:UpdateTimer()
        end)
    else
        --Animate the part.
        self.RenderUpdateEvent = RunService.RenderStepped:Connect(function()
            self:UpdateAnimationParts()
        end)
    end
end

--[[
Updates the players on the part.
--]]
function LobbySelectionRound:UpdatePlayers()
    --Return if there is no round selection part.
    if not self.SelectionPart then
        return
    end

    --Update the players.
    local SelectionPartCFrame = self.SelectionPart.CFrame
    local SizeX,SizeZ = self.SelectionPart.Size.X/2,self.SelectionPart.Size.Z/2
    for _,Player in pairs(Players:GetPlayers()) do
        --Determine if the player is in the part.
        local PlayerActive = false
        local PlayerAlreadyActive = (#self.Players:GetAll(function(OtherPlayer) return OtherPlayer == Player end) > 0)
        local Character = Player.Character
        if Character then
            local Head = Character:FindFirstChild("Head")
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Head and Humanoid and Humanoid.Health > 0 then
                local LocalHeadCFrame = SelectionPartCFrame:Inverse() * Head.CFrame
                local HeadX,HeadZ = LocalHeadCFrame.X,LocalHeadCFrame.Z
                if HeadX >= -SizeX and HeadX <= SizeX and HeadZ >= -SizeZ and HeadZ <= SizeZ then
                    PlayerActive = true
                end
            end
        end

        --Update the player.
        if PlayerActive ~= PlayerAlreadyActive then
            if PlayerActive then
                if #self.Players:GetAll() < self.MaxPlayers then
                    self.Players:Add(Player)
                end
            else
                self.Players:Remove(Player)
            self.ReadyPlayers:Remove(Player)
            end
        end
    end
end

--[[
Updates the timer based on players
entering or leaving.
--]]
function LobbySelectionRound:UpdateTimer()
    if #self.Players:GetAll() >= self.RequiredPlayers then
        --Start the time.
        if self.Timer.State == "STOPPED" then
            self.Timer:SetDuration(ROUND_SELECTION_DURATION)
            self.Timer:Start()
        end

        --Reset the time if everyone is ready.
        if #self.Players:GetAll() == #self.ReadyPlayers:GetAll() and self.Timer:GetRemainingTime() > PLAYERS_READY_TIME then
            self.Timer:Stop()
            self.Timer:SetDuration(PLAYERS_READY_TIME)
            self.Timer:Start()
        end
    else
        --Stop the time.
        if self.Timer.State == "ACTIVE" then
            self.Timer:Stop()
        end
    end
end

--[[
Updates the animation parts.
--]]
function LobbySelectionRound:UpdateAnimationParts()
    --Return if there is no round selection part.
    if not self.SelectionPart then
        return
    end

    --Create the parts.
    if not self.OuterAnimationPart then
        self.OuterAnimationPart = Instance.new("Part")
        self.OuterAnimationPart.Color = Color3.new(0,170/255 * BORDER_COLOR_MULTIPLIER,255/255 * BORDER_COLOR_MULTIPLIER)
        self.OuterAnimationPart.Material = Enum.Material.Neon
        self.OuterAnimationPart.Anchored = true
        self.OuterAnimationPart.CanCollide = false
    end
    if not self.AnimatedBorderParts then
        self.AnimatedBorderParts = {}
        for _ = 1,4 do
            local Part = Instance.new("Part")
            Part.Material = Enum.Material.Neon
            Part.Anchored = true
            Part.CanCollide = false
            table.insert(self.AnimatedBorderParts,Part)
        end
    end

    --Update static border.
    self.OuterAnimationPart.Parent = self.SelectionPart
    self.OuterAnimationPart.CFrame = self.SelectionPart.CFrame
    self.OuterAnimationPart.Size = Vector3.new(self.SelectionPart.Size.X + (1.99 * PART_BORDER_SIZE),self.SelectionPart.Size.Y * 0.98,self.SelectionPart.Size.Z + (1.99 * PART_BORDER_SIZE))

    --Determine the border animation.
    local BorderAnimation = {}
    if self.Timer.State == "STOPPED" then
        local FillPercent = (tick() * BORDER_IDLE_ANIMATION_SPEED) % 2
        if FillPercent <= 1 then
            BorderAnimation[1] = {0,FillPercent}
            BorderAnimation[2] = {FillPercent,1}
        else
            BorderAnimation[1] = {FillPercent - 1,1}
            BorderAnimation[2] = {0,FillPercent - 1}
        end
        BorderAnimation[3] = BorderAnimation[1]
        BorderAnimation[4] = BorderAnimation[2]
        for _,Part in pairs(self.AnimatedBorderParts) do
            Part.Color = Color3.new(255/255 * BORDER_COLOR_MULTIPLIER,255/255 * BORDER_COLOR_MULTIPLIER,0)
        end
    else
        local FillPercent = ((ROUND_SELECTION_DURATION - self.Timer:GetRemainingTime())/ROUND_SELECTION_DURATION) * 4
        for i = 1,4 do
            BorderAnimation[i] = {0,math.clamp(FillPercent - (i - 1),0,1)}
        end
        for _,Part in pairs(self.AnimatedBorderParts) do
            Part.Color = Color3.new(0,255/255 * BORDER_COLOR_MULTIPLIER,0)
        end
    end

    --Update the animated border.
    local SideLength = self.SelectionPart.Size.X + (2 * PART_BORDER_SIZE) * 0.99
    for i,Animation in pairs(BorderAnimation) do
        local Length = SideLength * (Animation[2] - Animation[1])
        local Part = self.AnimatedBorderParts[i]
        if Length > 0 then
            Part.CFrame = self.SelectionPart.CFrame * CFrame.Angles(0,(math.pi/2) * i,0) * CFrame.new(0,0,(self.SelectionPart.Size.X/2) + (0.5 * PART_BORDER_SIZE)) * CFrame.new((-SideLength/2) + (SideLength * Animation[1]) + (Length/2),0,0)
            Part.Size = Vector3.new(Length,self.SelectionPart.Size.Y * 0.99,PART_BORDER_SIZE)
            Part.Parent = self.SelectionPart
        else
            Part.Parent = nil
        end
    end
end

--[[
Sets a player as ready.
--]]
function LobbySelectionRound:SetPlayerReady(Player)
    if not self.Players:Contains(Player) then return end
    if self.ReadyPlayers:Contains(Player) then return end
    self.ReadyPlayers:Add(Player)
    self:UpdateTimer()
end

--[[
Disposes of the object.
--]]
function LobbySelectionRound:Dispose()
    self.super:Dispose()

    --Disconnect the events.
    if self.PlayerRemovingEvent then
        self.PlayerRemovingEvent:Disconnect()
    end
    if self.RenderUpdateEvent then
        self.RenderUpdateEvent:Disconnect()
    end

    --Destroy the state.
    self.Timer:Destroy()
    self.Players:Destroy()

    --Destroy the parts.
    if self.OuterAnimationPart then
        self.OuterAnimationPart:Destroy()
    end
    if self.AnimatedBorderParts then
        for _,Part in pairs(self.AnimatedBorderParts) do
            Part:Destroy()
        end
    end
end



return LobbySelectionRound