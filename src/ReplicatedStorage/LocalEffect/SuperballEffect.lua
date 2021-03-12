--[[
TheNexusAvenger

Performs the Superball bounce effect on the client.
--]]

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

return function(Superball)
    local LastSoundTime = 0
    local SuperballMesh = Superball:WaitForChild("SuperballMesh")
    local BoingSound = Superball:WaitForChild("BoingSound")

    --[[
    Returns the character and humanoid for the given descendants.
    --]]
    local function FindCharacterAncestor(Ins)
        if Ins and Ins ~= Workspace then
            local Humanoid = Ins:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                return Ins,Humanoid
            else
                return FindCharacterAncestor(Ins.Parent)
            end
        end
    end

    --[[
    Creates the superball effect.
    --]]
    local function CreateBounceEffect(Position)
        local VertexColor = SuperballMesh.VertexColor
        local SuperballSize = Superball.Size
        local SuperballScale = SuperballSize * 0.6

        local BounceEffect = Instance.new("Part")
        BounceEffect.Color = Color3.new(VertexColor.X,VertexColor.Y,VertexColor.Z)
        BounceEffect.Anchored = true
        BounceEffect.CanCollide = false
        BounceEffect.Transparency = 0.5
        BounceEffect.Reflectance = 0
        BounceEffect.Size = SuperballSize
        BounceEffect.CFrame = CFrame.new(Position)
        BounceEffect.BottomSurface = "Smooth"
        BounceEffect.TopSurface = "Smooth"
        BounceEffect.Name = "Bounce Spot"
        BounceEffect.Parent = Workspace
        Debris:AddItem(BounceEffect,2)

        local BounceMesh = Instance.new("SpecialMesh")
        BounceMesh.Name = "BounceMesh"
        BounceMesh.MeshType = "Sphere"
        BounceMesh.Scale = Vector3.new(1,1,1)
        BounceMesh.Parent = BounceEffect

        TweenService:Create(BounceMesh,TweenInfo.new(0.3),{
            Scale = SuperballSize * SuperballScale * 0.5,
        }):Play()
        TweenService:Create(BounceEffect,TweenInfo.new(0.6),{
            Transparency = 1,
        }):Play()
        wait(0.3)
        TweenService:Create(BounceMesh,TweenInfo.new(0.3),{
            Scale = Vector3.new(0,0,0),
        }):Play()
        wait(0.3)
        BounceEffect:Destroy()
    end

    --[[
    Registers a superball hit.
    --]]
    local function SuperballHit(TouchPart,Position)
        local _,HitHumanoid = FindCharacterAncestor(TouchPart)
        if not HitHumanoid then
            --If it hit something else, decrease the damage if it was last hit 0.32 seconds ago.
            local CurrentTime = tick()
            if CurrentTime - LastSoundTime > 0.32 then
                LastSoundTime = CurrentTime
                BoingSound:Play()
                CreateBounceEffect(Position)
            end
        end
    end

    --Set up touched event.
    Superball.Touched:Connect(function(TouchPart)
        SuperballHit(TouchPart,Superball.Position)
    end)
end