--[[
TheNexusAvenger

Class for a Capture The Flag round.
--]]

local TEAM_COLOR_NAME_TO_NAME = {
    ["Bright red"] = "Red",
    ["Bright blue"] = "Blue",
}
local OPPOSITE_TEAM_COLOR_NAME_TO_NAME = {
    ["Bright red"] = "Blue",
    ["Bright blue"] = "Red",
}
local SCORE_TO_END = 3



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusReplication = require(ReplicatedStorage:WaitForChild("External"):WaitForChild("NexusReplication"))
local ObjectReplication = NexusReplication:GetObjectReplicator()

local CaptureTheFlag = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseTeamRound")):Extend()
CaptureTheFlag:SetClassName("CaptureTheFlag")
CaptureTheFlag:AddFromSerializeData("CaptureTheFlag")
NexusReplication:GetObjectReplicator():RegisterType("CaptureTheFlag",CaptureTheFlag)



--[[
Creates the round object.
--]]
function CaptureTheFlag:__new()
    self:InitializeSuper()
    self.Name = "CaptureTheFlag"

    --Add the flags stat.
    table.insert(self.RoundStats,1,{
        Name = "Flags",
        ValueType = "IntValue",
        DefaultValue = 0,
        ShowInLeaderstats = true,
        Prefer = "Higher",
    })

    --Set up the scores.
    if NexusReplication:IsServer() then
        self.TeamScores = ObjectReplication:CreateObject("ReplicatedTable")
        self.TeamScores:Set("Bright blue",0)
        self.TeamScores:Set("Bright red",0)
    end
    self:AddToSerialization("TeamScores")
end

--[[
Starts the round.
--]]
function CaptureTheFlag:RoundStarted()
    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword","Superball","Slingshot","Bomb","RocketLauncher","Reflector"})
    end

    --Set up the flags.
    local StatService = self:GetService("StatService")
    local CaptureTheFlagPositions = self.Map:WaitForChild("CaptureTheFlagPositions")
    self.BasesToFlags = {}
    self.PlayersToFlags = {}
    for _,PositionPart in pairs(CaptureTheFlagPositions:GetChildren()) do
        --Create the base.
        local FlagSpawnCenter = CFrame.new(PositionPart.Position)
        local OuterBaseCylinder = Instance.new("Part")
        OuterBaseCylinder.Material = "Neon"
        OuterBaseCylinder.BrickColor = PositionPart.BrickColor
        OuterBaseCylinder.Anchored = true
        OuterBaseCylinder.CanCollide = true
        OuterBaseCylinder.TopSurface = "Smooth"
        OuterBaseCylinder.BottomSurface = "Smooth"
        OuterBaseCylinder.Shape = "Cylinder"
        OuterBaseCylinder.Size = Vector3.new(0.2,10,10)
        OuterBaseCylinder.CFrame = FlagSpawnCenter * CFrame.new(0,-0.05,0) * CFrame.Angles(0,0,-math.pi/2)
        OuterBaseCylinder.Parent = PositionPart

        local InnerBaseCylinder = Instance.new("Part")
        InnerBaseCylinder.Material = "SmoothPlastic"
        InnerBaseCylinder.BrickColor = BrickColor.new("Medium stone grey")
        InnerBaseCylinder.Anchored = true
        InnerBaseCylinder.CanCollide = true
        InnerBaseCylinder.TopSurface = "Smooth"
        InnerBaseCylinder.BottomSurface = "Smooth"
        InnerBaseCylinder.Shape = "Cylinder"
        InnerBaseCylinder.Size = Vector3.new(0.2,8,8)
        InnerBaseCylinder.CFrame = FlagSpawnCenter * CFrame.Angles(0,0,-math.pi/2)
        InnerBaseCylinder.Parent = PositionPart

        --Create the flags.
        self:CreateFlag(InnerBaseCylinder,PositionPart.BrickColor)

        --Connect the inner base being touched with a capturing flag.
        local DB = true
        InnerBaseCylinder.Touched:Connect(function(TouchPart)
            if DB then
                DB = false
                local Character = TouchPart.Parent
                if Character then
                    local Player = Players:GetPlayerFromCharacter(Character)
                    if Player and Player.TeamColor.Name == PositionPart.BrickColor.Name then
                        local Humanoid = Character:FindFirstChild("Humanoid")
                        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                        if Humanoid and Humanoid.Health > 0 and HumanoidRootPart then
                            --Capture the flag for the player if they have a flag and the base has the flag.
                            local PlayerFlag = self.PlayersToFlags[Player]
                            if self.BasesToFlags[InnerBaseCylinder].State == "BASE" and PlayerFlag and PlayerFlag:Capture() then
                                DB = true

                                --Increase the stats.
                                StatService:GetPersistentStats(Player):Get("CapturedFlags"):Increment()
                                StatService:GetTemporaryStats(Player):Get("Flags"):Increment()
                                self.TeamScores:Set(Player.TeamColor.Name,self.TeamScores:Get(Player.TeamColor.Name) + 1)
                            end
                        end
                    end
                end
                DB = true
            end
        end)
    end

    --Connect a team getting 3 or more points.
    self.TeamScores.ItemChanged:Connect(function(Index)
        if self.TeamScores:Get(Index) >= SCORE_TO_END then
            self.Timer:Complete()
        end
    end)

    --Spawn the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)
    end

    --Wait for the timer to complete.
    while self.Timer.State ~= "COMPLETE" do
        self.Timer:GetPropertyChangedSignal("State"):Wait()
    end

    --End the round.
    self:End()
end

--[[
Creates a flag.
--]]
function CaptureTheFlag:CreateFlag(FlagBase,FlagTeamColor)
    local FlagTeamName = TEAM_COLOR_NAME_TO_NAME[FlagTeamColor.Name] or "(TEAM)"
    local OppositeFlagTeamName = OPPOSITE_TEAM_COLOR_NAME_TO_NAME[FlagTeamColor.Name] or "(TEAM)"

    --Create the flag parts.
    local PostCFrame = CFrame.new(FlagBase.Position) * CFrame.Angles(0,2 * math.pi * math.random(),0) * CFrame.new(0,2.4,0) * CFrame.Angles(0,0,math.pi/2)
    local Post = Instance.new("Part")
    Post.BrickColor = BrickColor.new("Medium stone grey")
    Post.Material = "SmoothPlastic"
    Post.Anchored = true
    Post.Shape = "Cylinder"
    Post.Size = Vector3.new(4.6,0.4,0.4)
    Post.CFrame = PostCFrame
    Post.Parent = FlagBase

    local Flag = Instance.new("Part")
    Flag.BrickColor = FlagTeamColor
    Flag.CanCollide = false
    Flag.Size = Vector3.new(1.2,1.6,0.2)
    Flag.TopSurface = "Smooth"
    Flag.BottomSurface = "Smooth"
    Flag.Parent = Post

    local IndicatorBillboardGui = Instance.new("BillboardGui")
    IndicatorBillboardGui.AlwaysOnTop = true
    IndicatorBillboardGui.LightInfluence = 0
    IndicatorBillboardGui.Size = UDim2.new(2,0,2,0)
    IndicatorBillboardGui.StudsOffset = Vector3.new(0,7,0)
    IndicatorBillboardGui.Adornee = Post
    IndicatorBillboardGui.Parent = Post

    local IndicatorFrame = Instance.new("Frame")
    IndicatorFrame.BorderSizePixel = 0
    IndicatorFrame.BackgroundColor3 = FlagTeamColor.Color
    IndicatorFrame.Size = UDim2.new(1,0,1,0)
    IndicatorFrame.Rotation = 45
    IndicatorFrame.Parent = IndicatorBillboardGui

    --[[
    Creates a new weld.
    --]]
    local function CreateWeld()
        local Weld = Instance.new("Motor6D")
        Weld.Part0 = Post
        Weld.Part1 = Flag
        Weld.C0 = CFrame.new(0,0,0,0,1,0,-1,0,0,0,0,1)
        Weld.C1 = CFrame.new(-1.5,-0.9,0,0,1,0,-1,0,0,0,0,1)
        Weld.Parent = Post

        Weld.Changed:Connect(function()
            if not Weld.Parent and Post.Parent then
                CreateWeld()
            end
        end)
    end
    CreateWeld()

    --Create the object.
    local FlagObject = {
        State = "BASE",
        PlayersToFlags = self.PlayersToFlags,
        BroadcastLocalEffect = function(_,...)
            self:BroadcastLocalEffect(...)
        end,
    }

    --[[
    Claims the flag.
    --]]
    function FlagObject:Claim(Player)
        local Character = Player.Character
        if not Character then return end
        local UpperTorso = Character:FindFirstChild("UpperTorso")
        if self.State ~= "CAPTURED" and UpperTorso and not self.PlayersToFlags[Player] then
            --Capture the flag.
            self.State = "CAPTURED"
            self:BroadcastLocalEffect("DisplayAlert","The "..FlagTeamName.." flag has been stolen!")
            self.PlayersToFlags[Player] = self
            self.Player = Player
            Post.Parent = Character

            --Weld the flag to the player.
            Flag.CanCollide = true
            Post.Anchored = false
            local PlayerWeld = Instance.new("Motor6D")
            PlayerWeld.Part0 = UpperTorso
            PlayerWeld.Part1 = Post
            PlayerWeld.C0 = CFrame.new(0,0,0,0,1,0,-1,0,0,0,0,1)
            PlayerWeld.C1 = CFrame.new(0,0.2,-0.5,-0.5,0.866024971,0,-0.866024971,-0.5,0,0,0,1)
            PlayerWeld.Parent = UpperTorso
            self.PlayerWeld = PlayerWeld

            --Connect the weld being destroyed.
            PlayerWeld:GetPropertyChangedSignal("Parent"):Connect(function()
                if not PlayerWeld.Parent and self.State == "CAPTURED" then
                    --Drop the flag.
                    self.State = "DROPPED"
                    self:BroadcastLocalEffect("DisplayAlert","The "..FlagTeamName.." flag has been dropped!")
                    if self.Player then
                        self.PlayersToFlags[self.Player] = nil
                        self.Player = nil
                    end
                    Post.Parent = FlagBase
                end
            end)
        end
    end

    --[[
    Resets the flag.
    --]]
    function FlagObject:Reset()
        self.State = "BASE"

        --Move the flag.
        if self.PlayerWeld then
            self.PlayerWeld:Destroy()
            self.PlayerWeld = nil
        end
        if self.Player then
            self.PlayersToFlags[self.Player] = nil
            self.Player = nil
        end
        Post.Parent = FlagBase
        Post.Anchored = true
        Post.CFrame = PostCFrame * CFrame.Angles(2 * math.pi * math.random(),0,0)
        Post.AssemblyLinearVelocity = Vector3.new(0,0,0)
        Post.AssemblyAngularVelocity = Vector3.new(0,0,0)
        Flag.CanCollide = false
    end

    --[[
    Returns the flag.
    --]]
    function FlagObject:Return()
        if self.State == "DROPPED" then
            self:BroadcastLocalEffect("DisplayAlert","The "..FlagTeamName.." flag has been returned!")
            self:Reset()
        end
    end

    --[[
    Captures the flag.
    --]]
    function FlagObject:Capture()
        if self.State == "CAPTURED" then
            self:BroadcastLocalEffect("DisplayAlert","The "..FlagTeamName.." flag has been captured! "..OppositeFlagTeamName.." scores a point!")
            self:Reset()
            return true
        end
        return false
    end

    --Connect the flag disappearing.
    Post.AncestryChanged:Connect(function()
        if not Post:IsDescendantOf(game) then
            if FlagObject.State ~= "BASE" then
                self:BroadcastLocalEffect("DisplayAlert","The "..FlagTeamName.." flag has been returned!")
            end
            if FlagObject.Player then
                self.PlayersToFlags[FlagObject.Player] = nil
            end
            self:CreateFlag(FlagBase,FlagTeamColor)
        end
    end)

    --Connect capturing and returning the flag.
    local DB = true
    Post.Touched:Connect(function(TouchPart)
        if DB then
            DB = false
            local Character = TouchPart.Parent
            if Character then
                local Player = Players:GetPlayerFromCharacter(Character)
                if Player then
                    local Humanoid = Character:FindFirstChild("Humanoid")
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    if Humanoid and Humanoid.Health > 0 and HumanoidRootPart then
                        if Player.TeamColor.Name == FlagTeamColor.Name then
                            FlagObject:Return()
                        else
                            FlagObject:Claim(Player)
                        end
                    end
                end
            end
            DB = true
        end
    end)

    --Store the object.
    self.BasesToFlags[FlagBase] = FlagObject
end

--[[
Disposes of the object.
--]]
function CaptureTheFlag:Dispose()
    self.super:Dispose()

    --Destroy the objects.
    self.TeamScores:Destroy()
end



return CaptureTheFlag