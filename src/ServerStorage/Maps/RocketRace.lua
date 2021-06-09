--[[
TheNexusAvenger

Generates the "Rocket Racce" map.
The code is mostly legacy from Roblox Battle.
--]]

return function(MapModel,MapCenter,Round)
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
    
    local LEVEL_ORIGIN = MapCenter
    local LEVEL_BASE_RADIUS = 100
    local LEVEL_TOP_RADIUS = 20
    local LEVEL_HEIGHT = 500
    local LEVEL_SLANT_OFFSET = 500
    local LEVEL_PART_COUNT = 1400
    
    local SPAWN_BASE_RADIUS = LEVEL_BASE_RADIUS - 25
    local SPAWN_PART_DEPTH = 30
    local SPAWN_RING_SEPERATION = 5
    local SPAWN_RINGS = 2
    
    
    
    --[[
    Generates a random number from [Base,Base + Addtion].
    --]]
    local function RandomAdd(Base,Addtion)
        return Base + (Addtion * math.random())
    end
    
    --[[
    Generates the map.
    --]]
    local function GenerateMap()
        local SpawnParts = {}
        local OtherParts = {}
        
        local LevelTopPos = LEVEL_ORIGIN + Vector3.new(0,LEVEL_HEIGHT,LEVEL_SLANT_OFFSET)
        local PlayerCount = #TEAM_COLORS
        
        --[[
        Marks a part as destructible.
        --]]
        local function SetDestructible(Part)
            local BoolValue = Instance.new("BoolValue")
            BoolValue.Name = "RocketDestructible"
            BoolValue.Value = true
            BoolValue.Parent = Part
        end
    
        --Create the spawns.
        local SpawnPoints = Instance.new("Model")
        SpawnPoints.Name = "SpawnPoints"
        SpawnPoints.Parent = MapModel

        local TeamSpawnPoints = Instance.new("Model")
        TeamSpawnPoints.Name = "TeamSpawnPoints"
        TeamSpawnPoints.Parent = SpawnPoints

        local BaseCFrame = CFrame.new(LEVEL_ORIGIN)
        for i,PlayerColor in pairs(TEAM_COLORS) do
            local RingId = math.floor((i - 1) / (PlayerCount/SPAWN_RINGS)) + 1
            local InnerRadius = SPAWN_BASE_RADIUS + ((RingId - 1) * (SPAWN_PART_DEPTH + SPAWN_RING_SEPERATION))
            local OuterRadius = InnerRadius + SPAWN_PART_DEPTH
            local AngleSeperation = math.pi/(PlayerCount/SPAWN_RINGS)
            
            --tan(AngleSeperation) = Width/Radius
            local InnerWidth = (InnerRadius * math.tan(AngleSeperation/2)) * 2
            local OuterWidth = (OuterRadius * math.tan(AngleSeperation/2)) * 2
            
            --Create the spawn part.
            local SpawnPartCF = BaseCFrame * 
                           CFrame.Angles(0,-math.pi/2 + ((((i - 1) % (PlayerCount/SPAWN_RINGS)) + 0.5) * AngleSeperation),0) * 
                           CFrame.new(0,60,-(InnerRadius + (SPAWN_PART_DEPTH/2)))
            local SpawnPart = Instance.new("Part")
            SpawnPart.BrickColor = PlayerColor
            SpawnPart.Name = "LevelPart"
            SpawnPart.TopSurface = "Smooth"
            SpawnPart.BottomSurface = "Smooth"
            SpawnPart.Material = "Plastic"
            SpawnPart.Anchored = true
            SpawnPart.Size = Vector3.new(InnerWidth,2,SPAWN_PART_DEPTH)
            SpawnPart.CFrame = SpawnPartCF * CFrame.Angles(0,math.pi,0)
            SpawnPart.Parent = TeamSpawnPoints
            
            --Create the side wedges.
            local WedgeWidth = (OuterWidth - InnerWidth)/2
            local Wedge1 = Instance.new("WedgePart")
            Wedge1.BrickColor = PlayerColor
            Wedge1.Name = "LevelPart"
            Wedge1.TopSurface = "Smooth"
            Wedge1.BottomSurface = "Smooth"
            Wedge1.Material = "Plastic"
            Wedge1.Anchored = true
            Wedge1.Size = Vector3.new(2,WedgeWidth,SPAWN_PART_DEPTH)
            Wedge1.CFrame = SpawnPartCF * CFrame.new(-((WedgeWidth/2) + (InnerWidth/2)),0,0) * CFrame.Angles(math.pi,0,math.pi/2)
            Wedge1.Parent = MapModel
            
            local Wedge2 = Instance.new("WedgePart")
            Wedge2.BrickColor = PlayerColor
            Wedge2.Name = "LevelPart"
            Wedge2.TopSurface = "Smooth"
            Wedge2.BottomSurface = "Smooth"
            Wedge2.Material = "Plastic"
            Wedge2.Anchored = true
            Wedge2.Size = Vector3.new(2,WedgeWidth,SPAWN_PART_DEPTH)
            Wedge2.CFrame = SpawnPartCF * CFrame.new((WedgeWidth/2) + (InnerWidth/2),0,0) * CFrame.Angles(math.pi,0,-math.pi/2)
            Wedge2.Parent = MapModel
        end
    
        --Generate the main parts.
        for i = 1,LEVEL_PART_COUNT do
            --Determine the base position.
            local HeightFraction = i/LEVEL_PART_COUNT
            local Height = HeightFraction * LEVEL_HEIGHT
            local Radius = LEVEL_BASE_RADIUS * (1 - HeightFraction) + (LEVEL_TOP_RADIUS * HeightFraction)
            local Position = LEVEL_ORIGIN * (1 - HeightFraction) + (LevelTopPos * HeightFraction)
            
            --Randomize the position.
            Radius = Radius - RandomAdd(0,1.5 * RandomAdd(-Radius * 0.5,Radius * 1.5))
            Position = Vector3.new(Position.X,math.max(1,Position.Y + RandomAdd(-4,4)),Position.Z)
            
            --Create the part.
            local LevelPart = Instance.new("Part")
            LevelPart.Name = "LevelPart"
            LevelPart.TopSurface = "Smooth"
            LevelPart.BottomSurface = "Smooth"
            LevelPart.Material = "Slate"
            LevelPart.Anchored = true
            LevelPart.Size = Vector3.new(RandomAdd(4,8),RandomAdd(2,5),RandomAdd(4,8)) * (((LEVEL_TOP_RADIUS * 2.1 / LEVEL_BASE_RADIUS) * HeightFraction) + (1 - HeightFraction)) * 2.8
            LevelPart.CFrame = CFrame.new(Position) * 
                          CFrame.Angles(0,RandomAdd(0, math.pi*2),0) * 
                          CFrame.new(0,0,-Radius) * 
                          CFrame.Angles(RandomAdd(-0.5,0.5),RandomAdd(0,math.pi*2),RandomAdd(-0.5,0.5))
            LevelPart.Parent = MapModel
            table.insert(OtherParts,LevelPart)
        end
        
        --Create the end part.
        local LevelEndPart = Instance.new("Part")
        LevelEndPart.BrickColor = BrickColor.new("Really black")
        LevelEndPart.Material = "Foil"
        LevelEndPart.Name = "EndPart"
        LevelEndPart.TopSurface = "Smooth"
        LevelEndPart.BottomSurface = "Smooth"
        LevelEndPart.Anchored = true
        LevelEndPart.Size = Vector3.new(10,1,10)
        LevelEndPart.Position = LevelTopPos + Vector3.new(0,2,0)
        LevelEndPart.Parent = MapModel
        
        --Determine the candidates for colored parts.
        local ColorCandidates = {}
        for _,Part in pairs(OtherParts) do
            local HeightFraction = (Part.Position.y - LEVEL_ORIGIN.Y) / LEVEL_HEIGHT
            if math.random() > HeightFraction then
                table.insert(ColorCandidates,Part)
            end
        end
    
        --Set the color of random parts.
        for _ = 1,LEVEL_PART_COUNT/math.max(PlayerCount,4)/2 do
            for _,PlayerColor in pairs(TEAM_COLORS) do
                if #ColorCandidates > 0 then
                    --Color a random part.
                    local RandomPartIndex = (#ColorCandidates == 1 and 1 or math.random(1,#ColorCandidates))
                    local RandomPart = ColorCandidates[RandomPartIndex]
                    RandomPart.Name = "CheckpointPart"
                    RandomPart.BrickColor = PlayerColor
                    table.remove(ColorCandidates,RandomPartIndex)
                    table.insert(SpawnParts,RandomPart)
                    
                    --Remove the part from the other parts.
                    for i,Part in pairs(OtherParts) do
                        if Part == RandomPart then
                            table.remove(OtherParts,i)
                            break
                        end
                    end
                end
            end
        end
        
        --Make other parts destructible.
        for _,Part in pairs(OtherParts) do
            SetDestructible(Part)
        end

        local LoadingCameraPosition = Instance.new("Part")
        LoadingCameraPosition.Name = "LoadingCameraPosition"
        LoadingCameraPosition.CFrame = CFrame.new(MapCenter) * CFrame.Angles(0,math.pi,0) * CFrame.new(0,65,150) * CFrame.Angles(math.rad(15),0,0)
        LoadingCameraPosition.Transparency = 1
        LoadingCameraPosition.Anchored = true
        LoadingCameraPosition.CanCollide = false
        LoadingCameraPosition.Parent = MapModel
    end
    
    GenerateMap()
end