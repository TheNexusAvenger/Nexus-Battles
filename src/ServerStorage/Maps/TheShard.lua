--[[
TheNexusAvenger

Generates the "The Shard" map.
The code is mostly legacy from Roblox Battle.
--]]

return function(MapModel,MapCenter,Round)
    local INNER_RADIUS = 30
    local RADIUS = 200
    local RADIAL_STEPS = 9
    local RING_STEPSIZE = 14
    local BASE_CFRAME = CFrame.new(MapCenter) * CFrame.Angles(0,0,0.1)

    local SPAWNSIZE = 60
    local SPAWNHEIGHT = 20
    local BEAMWIDTH = 10

    local SPIKE_FADE_IN_TIME = 0.5



    local ShardList = {}
    local BasePartList = {}

    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Debris = game:GetService("Debris")

    local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

    local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")

    local KillablePartsModel = Instance.new("Model")
    KillablePartsModel.Name = "KillableParts"
    KillablePartsModel.Parent = MapModel



    --Returns a CFrame based on the position, top normal, and back vector.
    local function CFrameFromTopBack(Postion,TopNormal,BackNormal)
        local RightNormal = TopNormal:Cross(BackNormal)
        return CFrame.new(Postion.X,Postion.Y,Postion.Z,
                        RightNormal.X,TopNormal.X,BackNormal.X,
                        RightNormal.Y,TopNormal.Y,BackNormal.Y,
                        RightNormal.Z,TopNormal.Z,BackNormal.Z)
    end

    --Creates a triangle between 3 points. Assumes the triangle has a non-zero area.
    local function FillTriangle(PointA,PointB,PointC)
        --Make line AB the longest.
        local ABLength = (PointA - PointB).Magnitude
        local ACLength = (PointA - PointC).Magnitude
        local BCLength = (PointB - PointC).Magnitude
        if ACLength > ABLength then
            if ACLength > BCLength then
                --Turn line AC to the longest.
                PointA,PointB,PointC = PointA,PointC,PointB
            else
                --Turn line BC to the longest.
                PointA,PointB,PointC = PointB,PointC,PointA
            end
        elseif BCLength > ABLength then
            if BCLength > ACLength then
                --Turn line BC to the longest.
                PointA,PointB,PointC = PointB,PointC,PointA
            else
                --Turn line AC to the longest.
                PointA,PointB,PointC = PointA,PointC,PointB
            end
        end

        --Rearrange to make right angle triangels fill right.
        local Edge1 = (PointC - PointA):Dot((PointB - PointA).Unit)
        local Edge2 = (PointA - PointB):Dot((PointC - PointB).Unit)
        local Edge3 = (PointB - PointC):Dot((PointA - PointC).Unit)
        if Edge1 <= (PointB - PointA).Magnitude and Edge1 >= 0 then
            PointA,PointB,PointC = PointA,PointB,PointC
        elseif Edge2 <= (PointC - PointB).Magnitude and Edge2 >= 0 then
            PointA,PointB,PointC = PointB,PointC,PointA
        elseif Edge3 <= (PointA - PointC).Magnitude and Edge3 >= 0 then
            PointA,PointB,PointC = PointC,PointA,PointB
        else 
            assert(false, "unreachable")
        end

        --Calculate lengths of base and height.
        local Length1 = (PointC - PointA):Dot((PointB - PointA).Unit)
        local Length2 = (PointB - PointA).Magnitude - Length1
        local Width = (PointA + ((PointB - PointA).Unit * Length1) - PointC).Magnitude

        --Calculate "base" CFrame to pasition parts by.
        local MainCFrame = CFrameFromTopBack(PointA,(PointB - PointA):Cross(PointC - PointB).Unit,(-(PointB - PointA)).Unit)

        --Create wedges.
        local Wedge1,Wedge2
        local WedgeMaterial = "Slate"
        if Length1 > 0 then
            Wedge1 = Instance.new("WedgePart")
            Wedge1.Material = WedgeMaterial
            Wedge1.Anchored = true
            Wedge1.Size = Vector3.new(0,Width,Length1)
            Wedge1.CFrame = MainCFrame * CFrame.Angles(math.pi,0,math.pi/2) * CFrame.new(0,Width/2,Length1/2)
        end

        if Length2 > 0 then
            Wedge2 = Instance.new("WedgePart")
            Wedge2.Material = WedgeMaterial
            Wedge2.Anchored = true
            Wedge2.Size = Vector3.new(0, Width, Length2)
            Wedge2.CFrame = MainCFrame * CFrame.Angles(math.pi,math.pi,-math.pi/2) * CFrame.new(0,Width/2,-Length1 - Length2/2)
        end

        --Return wedges.
        if Wedge1 and Wedge2 then
            return Wedge1,Wedge2
        elseif Wedge1 then
            return Wedge1
        elseif Wedge2 then
            return Wedge2
        end
    end

    --Generates the level.
    local function GenerateLevel()
        local Seed = math.random(1,100)
        
        local function BaseNoise(Coordinate,Lambda)
            return 0.5 + (0.5 * math.noise(Coordinate.X/Lambda,Coordinate.Z/Lambda,Seed))
        end
        
        local function Noise(Coordinate)
            return (BaseNoise(Coordinate,90) * 30) + (BaseNoise(Coordinate,60) * 30) + (BaseNoise(Coordinate,30) * 10)
        end
        
        local function Modify(Coordinate,Radius,Theta)
            local Fraction = (Radius - INNER_RADIUS)/(RADIUS - INNER_RADIUS)
            Fraction = ((Fraction * 2 - 1) ^ 2) ^ 0.8
            return Coordinate + Vector3.new(0, -80 + (Fraction*  70) + (1 - Fraction) * Noise(Coordinate) * 2, 0)
        end
        
        --Sets up a part to be rocket destructible.
        local function RocketDestructible(Part)
            local Value = Instance.new("BoolValue")
            Value.Name = "RocketDestructible"
            Value.Value = true
            Value.Parent = Part
        end
        
        local RingWidth = (RADIUS - INNER_RADIUS)/RADIAL_STEPS
        local PreviousRingThetas = {0}
        local PreviousRingRadius = 0
        local PreviousRingOffset = CFrame.new()
        
        local function Wrap(PrevRingIndex)
            return 1 + ((PrevRingIndex - 1) % (#PreviousRingThetas))
        end
        
        --Create the ground rings.
        for RadiusStep = 1,RADIAL_STEPS - 1 do
            local RingRadius = (RadiusStep + 1) * RingWidth + INNER_RADIUS
            local RingOffset = CFrame.new(0,0,-RingRadius)
            local RingStepCount = math.floor(2*math.pi * RingRadius/RING_STEPSIZE)
            local RingStepTheta = 2 * math.pi/RingStepCount
            
            local function CreateTriangle(PointA,PointB,PointC)
                local TriangleParts = {FillTriangle(PointA,PointB,PointC)}
                for _,Part in pairs(TriangleParts) do
                    Part.BrickColor = BrickColor.new("Dark stone grey")
                    Part.Name = "LevelPart"
                    Part.Parent = KillablePartsModel
                    RocketDestructible(Part)
                    BasePartList[#BasePartList + 1] = Part
                end
            end
            
            local RingThetas = {0}
            local LastTheta = 0
            local LastRingIndex = 1

            for i = 1,RingStepCount do
                local CurrentTheta = i * RingStepTheta
                RingThetas[#RingThetas + 1] = CurrentTheta
                
                --Create triangles.
                if CurrentTheta > PreviousRingThetas[Wrap(LastRingIndex + 1)] or i == RingStepCount then
                    local PointA = (BASE_CFRAME * CFrame.Angles(0,LastTheta,0) * RingOffset).Position
                    local PointB = (BASE_CFRAME * CFrame.Angles(0,PreviousRingThetas[LastRingIndex],0) * PreviousRingOffset).Position
                    local PointC = (BASE_CFRAME * CFrame.Angles(0,PreviousRingThetas[Wrap(LastRingIndex + 1)], 0) * PreviousRingOffset).Position
                    PointA = Modify(PointA,RingRadius,LastTheta)
                    PointB = Modify(PointB,PreviousRingRadius,PreviousRingThetas[LastRingIndex])
                    PointC = Modify(PointC,PreviousRingRadius,PreviousRingThetas[Wrap(LastRingIndex+1)])
                    CreateTriangle(PointA,PointB,PointC)

                    PointA = (BASE_CFRAME * CFrame.Angles(0,LastTheta,0) * RingOffset).Position
                    PointB = (BASE_CFRAME * CFrame.Angles(0,PreviousRingThetas[Wrap(LastRingIndex + 1)],0) * PreviousRingOffset).Position
                    PointC = (BASE_CFRAME * CFrame.Angles(0,CurrentTheta,0) * RingOffset).Position
                    PointA = Modify(PointA,RingRadius,LastTheta)
                    PointB = Modify(PointB, PreviousRingRadius,PreviousRingThetas[Wrap(LastRingIndex + 1)])
                    PointC = Modify(PointC, RingRadius, CurrentTheta)
                    CreateTriangle(PointA,PointB,PointC)

                    LastRingIndex = Wrap(LastRingIndex + 1)
                else
                    local PointA = (BASE_CFRAME * CFrame.Angles(0,LastTheta,0) * RingOffset).Position
                    local PointB = (BASE_CFRAME * CFrame.Angles(0,CurrentTheta,0) * RingOffset).Position
                    local PointC = (BASE_CFRAME * CFrame.Angles(0,PreviousRingThetas[LastRingIndex],0) * PreviousRingOffset).Position
                    PointA = Modify(PointA, RingRadius,LastTheta)
                    PointB = Modify(PointB,RingRadius,CurrentTheta)
                    PointC = Modify(PointC,PreviousRingRadius,PreviousRingThetas[LastRingIndex])
                    CreateTriangle(PointA,PointB,PointC)
                end
                
                --Create brim.
                if RadiusStep == RADIAL_STEPS - 1 then
                    local PointB = (BASE_CFRAME * CFrame.Angles(0,LastTheta,0) * CFrame.new(0,0,-RingRadius)).Position
                    local PointC = (BASE_CFRAME * CFrame.Angles(0,CurrentTheta,0) * CFrame.new(0,0,-RingRadius)).Position
                    PointB = Modify(PointB,RingRadius,LastTheta)
                    PointC = Modify(PointC,RingRadius,CurrentTheta)
                    
                    local EdgePart = Instance.new("Part", MapModel)
                    EdgePart.Name = "LevelPart"
                    EdgePart.Anchored = true
                    EdgePart.BrickColor = BrickColor.new("Really black")
                    EdgePart.TopSurface = "Inlet"
                    EdgePart.Size = Vector3.new(3,2,(PointB - PointC).Magnitude + 0.1)
                    EdgePart.CFrame = CFrame.new(PointB,PointC) * CFrame.new(1.3,0, -(PointB - PointC).Magnitude/2)
                end
                
                LastTheta = CurrentTheta
            end
            
            PreviousRingOffset = RingOffset
            PreviousRingRadius = RingRadius
            PreviousRingThetas = RingThetas
        end

        --Create spawns.
        local SpawnPoints = Instance.new("Model")
        SpawnPoints.Name = "SpawnPoints"
        SpawnPoints.Parent = MapModel

        local TeamSpawnPoints = Instance.new("Model")
        TeamSpawnPoints.Name = "TeamSpawnPoints"
        TeamSpawnPoints.Parent = SpawnPoints
        
        for i = 0,5 do
            local Theta = i * math.pi * 1/3 + math.pi/6
            local CF = BASE_CFRAME * CFrame.Angles(0,Theta,0) * CFrame.new(0,-SPAWNHEIGHT/2-8.5,-RADIUS-SPAWNSIZE/2-1)
            
            local PointA = (BASE_CFRAME * CFrame.Angles(0,Theta,0) * CFrame.new(-SPAWNSIZE/2,-SPAWNHEIGHT/2-8.5,-RADIUS-SPAWNSIZE-1)).Position
            local PointB = (BASE_CFRAME * CFrame.Angles(0,Theta + math.pi/6,0) * CFrame.new(0, -SPAWNHEIGHT/2-8.5, -RADIUS)).Position
            local PointC = (BASE_CFRAME * CFrame.Angles(0,Theta,0) * CFrame.new(SPAWNSIZE/2,-SPAWNHEIGHT/2-8.5,-RADIUS-SPAWNSIZE-1)).Position
            local PointD = (BASE_CFRAME * CFrame.Angles(0,Theta - math.pi/6, 0) * CFrame.new(0,-SPAWNHEIGHT/2-8.5,-RADIUS)).Position
            
            local SpawnLocation = Instance.new("Part")
            SpawnLocation.TopSurface = "Inlet"
            SpawnLocation.BrickColor = BrickColor.new("Really black")
            SpawnLocation.Anchored = true
            SpawnLocation.Size = Vector3.new(SPAWNSIZE,SPAWNHEIGHT,SPAWNSIZE)
            SpawnLocation.CFrame = CF
            SpawnLocation.Parent = MapModel
            
            local ActualSpawn = Instance.new("Part")
            ActualSpawn.Transparency = 1
            ActualSpawn.Name = "Spawn"
            ActualSpawn.Anchored = true
            ActualSpawn.CanCollide = false
            ActualSpawn.BrickColor = BrickColor.new("Bright violet")
            ActualSpawn.Size = Vector3.new(SPAWNSIZE-2,0.2,SPAWNSIZE-2)
            ActualSpawn.CFrame = SpawnLocation.CFrame * CFrame.new(0,SPAWNHEIGHT/2,0) * CFrame.Angles(0,math.pi,0)
            ActualSpawn.Parent = SpawnPoints
            
            if i == 0 or i == 3 then
                local TeamSpawn = ActualSpawn:Clone()
                if i == 0 then
                    TeamSpawn.Name = "Team1"
                    TeamSpawn.BrickColor = BrickColor.new("Bright red")
                else
                    TeamSpawn.Name = "Team2"
                    TeamSpawn.BrickColor = BrickColor.new("Bright blue")
                end
                TeamSpawn.Parent = TeamSpawnPoints
            end
            
            local Beam1 = Instance.new("Part")
            Beam1.TopSurface = "Inlet"
            Beam1.BrickColor = BrickColor.new("Really black")
            Beam1.Anchored = true
            Beam1.Size = Vector3.new(BEAMWIDTH, SPAWNHEIGHT/2,(PointA - PointB).Magnitude)
            Beam1.CFrame = CFrame.new(PointA,PointB)*CFrame.new(-BEAMWIDTH/2, SPAWNHEIGHT/5, -(PointA - PointB).Magnitude/2)
            Beam1.Parent = MapModel
            
            local Beam2 = Instance.new("Part")
            Beam2.TopSurface = "Inlet"
            Beam2.BrickColor = BrickColor.new("Really black")
            Beam2.Anchored = true
            Beam2.Size = Vector3.new(BEAMWIDTH, SPAWNHEIGHT/2,(PointC - PointD).Magnitude)
            Beam2.CFrame = CFrame.new(PointC,PointD)*CFrame.new(BEAMWIDTH/2,SPAWNHEIGHT/5,-(PointC - PointD).Magnitude/2)
            Beam2.Parent = MapModel
        end

        --Create shards.
        local CenterLocations = {{Position = CFrame.new(MapCenter),Size = 1.8}}
        for i = 0, 5 do
            local Position = BASE_CFRAME * CFrame.Angles(0,math.pi * 1/3 * i,0) * CFrame.new(0,0,-RADIUS)
            local Size = 1.1
            CenterLocations[#CenterLocations + 1] = {Position = Position,Size = Size}
        end
        
        for _,LocationData in pairs(CenterLocations) do
            local Position = LocationData.Position
            local Size = LocationData.Size
            for i = 1,27 do
                local RadialFraction = math.random()
                local InverseRadialFraction = (1 - RadialFraction)
                local Radius = RadialFraction * (INNER_RADIUS * 3)
                local Rotation = math.pi * 2 * math.random()
                
                local Shard = Instance.new("Part")
                Shard.Name = "BlackDecoration"
                Shard.BrickColor = BrickColor.new("Really black")
                Shard.Size = Vector3.new(6 + (math.random() * InverseRadialFraction * 12),
                                        20 + (math.random() * 40 * Size) + (math.random() * InverseRadialFraction * 400 * Size),
                                        6 + (math.random() * InverseRadialFraction * 12 * Size))
                Shard.CFrame = CFrame.new((Position * CFrame.Angles(0,Rotation,0) * 
                                        CFrame.new(0,0,-Radius * Size + 20) * 
                                        CFrame.Angles(0, math.random()*2*math.pi, 0)).p)
                Shard.Anchored = true
                Shard.Parent = MapModel
                ShardList[#ShardList + 1] = Shard
            end
        end

        local LoadingCameraPosition = Instance.new("Part")
        LoadingCameraPosition.Name = "LoadingCameraPosition"
        LoadingCameraPosition.CFrame = CFrame.new(MapCenter) * CFrame.Angles(0,math.rad(30),0) * CFrame.new(0,20,250) * CFrame.Angles(math.rad(-10),0,0)
        LoadingCameraPosition.Transparency = 1
        LoadingCameraPosition.Anchored = true
        LoadingCameraPosition.CanCollide = false
        LoadingCameraPosition.Parent = MapModel
    end

    GenerateLevel()
    
    local function RandomFloat(Min,Max)
        return Min + (math.random() * (Max - Min))
    end
    
    coroutine.wrap(function()
        while Round.State == "LOADING" do
            Round:GetPropertyChangedSignal("State"):Wait()
        end

        --Falling spike loop.
        while Round.State ~= "ENDED" do
            wait(RandomFloat(2,5))
            local TargetPosition = (BASE_CFRAME * CFrame.Angles(0,math.random() * math.pi * 2,0) * CFrame.new(0,0,-RandomFloat(30,RADIUS - 10))).Position
            
            local FallingSpike = Instance.new("Part")
            FallingSpike.BrickColor = BrickColor.new("Really black")
            FallingSpike.Size = Vector3.new(RandomFloat(10,20),RandomFloat(40,80),RandomFloat(10,20))
            FallingSpike.CFrame = CFrame.new(TargetPosition + Vector3.new(0,100,0)) * CFrame.Angles(0,RandomFloat(0,math.pi*2),0)
            FallingSpike.Transparency = 1
            FallingSpike.CanCollide = false
            FallingSpike.Parent = MapModel
            
            local DownForce = Instance.new("BodyVelocity")
            DownForce.Parent = FallingSpike
            DownForce.MaxForce = Vector3.new(0,10000000,0)
            DownForce.Velocity = Vector3.new(0,-10,0)
            
            FallingSpike.Touched:Connect(function(TouchPart)
                local RocketDestructible = TouchPart:FindFirstChild("RocketDestructible")
                if RocketDestructible then
                    RocketDestructible:Destroy()
                    TouchPart.CanCollide = false
                    TouchPart.Anchored = false
                    
                    local FloatForce = Instance.new("BodyForce")
                    FloatForce.Force = Vector3.new(0,Workspace.Gravity * TouchPart:GetMass(), 0)
                    FloatForce.Parent = TouchPart
                    
                    local DeltaPosition = TouchPart.Position - FallingSpike.Position
                    DeltaPosition = Vector3.new(DeltaPosition.X,0,DeltaPosition.Z).unit
                    TouchPart.AssemblyLinearVelocity = DeltaPosition * 4 + Vector3.new(RandomFloat(-2,2),RandomFloat(-2,2),RandomFloat(-2,2))
                    TouchPart.AssemblyAngularVelocity = Vector3.new(RandomFloat(-5,5),0,RandomFloat(-5,5))
                    
                    local Players = Round.Players:GetAll()
                    if #Players >= 1 then
                        LocalEffectService:BroadcastLocalEffect(Players[1],"FadePart",TouchPart)
                    end
                    Debris:AddItem(TouchPart,3)
                end
            end)
            
            spawn(function()
                local StartTime = tick()
                while tick() - StartTime < SPIKE_FADE_IN_TIME do
                    FallingSpike.Transparency = 1 - ((tick() - StartTime)/SPIKE_FADE_IN_TIME)
                    wait()
                end
                FallingSpike.Transparency = 0
            end)
        end
    end)()
end