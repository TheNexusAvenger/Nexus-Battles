--[[
TheNexusAvenger

Displays a reactive effect.
--]]

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

return function(StartPart,EndPart)
    if StartPart and StartPart.Parent and EndPart and EndPart.Parent then
        local Effect = Instance.new("Part")
        Effect.BrickColor = BrickColor.new("Really red")
        Effect.CFrame = StartPart.CFrame
        Effect.Transparency = 0
        Effect.Name = "Effect"
        Effect.Anchored = true
        Effect.CanCollide = false
        Effect.Size = Vector3.new(0,0,0)
        Effect.Shape = Enum.PartType.Ball
        Effect.Parent = Workspace.CurrentCamera

        local Mesh = Instance.new("SpecialMesh")
        Mesh.MeshType = "Sphere"
        Mesh.Parent = Effect

        TweenService:Create(Effect,TweenInfo.new(0.25),{
            Transparency = 1,
            CFrame = EndPart.CFrame,
            Size = Vector3.new(2,2,2),
        }):Play()
        wait(0.5)
        Effect:Destroy()
    end
end