--[[
TheNexusAvenger

Class for a Juggernaut round.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local NexusRoundSystem = require(ReplicatedStorage:WaitForChild("NexusRoundSystem"))

local Juggernaut = require(ReplicatedStorage:WaitForChild("Round"):WaitForChild("BaseRound")):Extend()
Juggernaut:SetClassName("Juggernaut")
Juggernaut:AddFromSerializeData("Juggernaut")
NexusRoundSystem:GetObjectReplicator():RegisterType("Juggernaut",Juggernaut)



--[[
Creates the round object.
--]]
function Juggernaut:__new()
    self:InitializeSuper()
    self.Name = "Juggernaut"
end

--[[
Starts the round.
--]]
function Juggernaut:RoundStarted()
    local RoundEvents = {}
    local CurrentJuggernaut

    --Create the initial teams to prevent team-killing.
    local TeamService = self:GetService("TeamService")
    TeamService:GetTeam(BrickColor.new("Bright blue"))
    TeamService:GetTeam(BrickColor.new("Bright red"))

    --Set the starter inventories of the players.
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetStarterTools(Player,{"Sword","Superball","Slingshot"})
    end

    --[[
    Returns if a character is valid.
    --]]
    local function PlayerValid(Player)
        if not self.Players:Contains(Player) then return false end
        local Character = Player.Character
        if not Character then return false end
        if not Player:FindFirstChild("Backpack") then return false end
        local Humanoid = Character:FindFirstChild("Humanoid")
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        local Head = Character:FindFirstChild("Head")
        if not Humanoid or not HumanoidRootPart or not Head then return false end
        if Humanoid.Health <= 0 then return false end
        return true
    end

    --[[
    Sets the Juggernaut.
    --]]
    local function SetJuggernaut(NewJuggernaut)
        --Clear the existing juggernaut.
        if CurrentJuggernaut and self.Players:Contains(CurrentJuggernaut) then
            CurrentJuggernaut.TeamColor = BrickColor.new("Bright blue")
            CurrentJuggernaut = nil
        end

        --Randomize the Juggernaut if none is specified.
        if not NewJuggernaut or not PlayerValid(NewJuggernaut) then
            NewJuggernaut = nil
            while not NewJuggernaut do 
                local Players = self.Players:GetAll()
                local NewPlayer = Players[math.random(1,#Players)]
                if PlayerValid(NewPlayer) then
                    NewJuggernaut = NewPlayer
                end
                wait()
            end
        end
        CurrentJuggernaut = NewJuggernaut

        --Echo the message and create the Juggernaut arrow.
        local Character = CurrentJuggernaut.Character
        local Head = Character:WaitForChild("Head")
        local Humanoid = Character:WaitForChild("Humanoid")
        local LocalEffectService = self:GetService("LocalEffectService")
        for _,Player in pairs(self.Players:GetAll()) do
            if Player == CurrentJuggernaut then
                LocalEffectService:PlayLocalEffect(Player,"DisplayAlert","YOU ARE THE JUGGERNAUT!")
            else
                LocalEffectService:PlayLocalEffect(Player,"DisplayAlert",string.upper(CurrentJuggernaut.DisplayName).." IS THE JUGGERNAUT!")
            end
        end
        LocalEffectService:BroadcastLocalEffect(CurrentJuggernaut,"CreateJuggernautArrow",Head)

        --Create the helmet.
        local JuggernautHat = Instance.new("Part")
        JuggernautHat.Anchored = false
        JuggernautHat.Name = "JuggernautHat"
        JuggernautHat.Size = Vector3.new(1.4,1.4,1.6)
        JuggernautHat.BottomSurface = "Smooth"
        JuggernautHat.TopSurface = "Smooth"
        JuggernautHat.Locked = true
        JuggernautHat.Parent = Character

        local Mesh = Instance.new("SpecialMesh")
        Mesh.MeshType = Enum.MeshType.FileMesh
        Mesh.Scale = Vector3.new(1.4,1.4,1.4)
        Mesh.MeshId = "http://www.roblox.com/asset/?id=84387239"
        Mesh.TextureId = "http://www.roblox.com/asset/?id=84387217"
        Mesh.Parent = JuggernautHat

        local HatWeld = Instance.new("Weld")
        HatWeld.Part0 = Head
        HatWeld.Part1 = JuggernautHat
        HatWeld.C0 = CFrame.new(Vector3.new(0,0.1,-0.2))
        HatWeld.Parent = Head

        --Create a forcefield and increase the health.
        local ForceField = Instance.new("ForceField")
        ForceField.Parent = Character
        Debris:AddItem(ForceField,2)
        Humanoid.MaxHealth = 400
        Humanoid.Health = 400

        --Change the team.
        NewJuggernaut.TeamColor = BrickColor.new("Bright red")

        --Set the tools.
        self:SetTools(CurrentJuggernaut,{"Sword","Superball","Slingshot","RocketLauncher"})
        Humanoid:EquipTool(CurrentJuggernaut:WaitForChild("Backpack"):WaitForChild("RocketLauncher"))
    end

    --Spawn the players.
    local DamageService = self:GetService("DamageService")
    for _,Player in pairs(self.Players:GetAll()) do
        self:SetSpawningEnabled(Player,true)
        self:SpawnPlayer(Player)
        Player.Neutral = false
        Player.TeamColor = BrickColor.new("Bright blue")

        --Connect the events.
        table.insert(RoundEvents,DamageService:GetWOEvent(Player):Connect(function(KillingPlayer)
            if Player == CurrentJuggernaut then
                SetJuggernaut(KillingPlayer)
            end
        end))
    end

    --Assign an initial Juggernaut.
    SetJuggernaut()

    --Connect the Juggernaut leaving.
    self.Players.ItemRemoved:Connect(function(Player)
        if Player == CurrentJuggernaut then
            SetJuggernaut()
        end
    end)

    --Wait for the timer to complete.
    while self.Timer.State ~= "COMPLETE" do
        self.Timer:GetPropertyChangedSignal("State"):Wait()
    end

    --End the round.
    for _,Event in pairs(RoundEvents) do
        Event:Disconnect()
    end
    self:End()
end



return Juggernaut