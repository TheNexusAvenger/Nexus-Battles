--[[
TheNexusAvenger

Plays a sound on the client.
--]]

local Workspace = game:GetService("Workspace")

return function (Id,Volume,Position)
    --Create the part and sound.
    local SoundPart = Instance.new("Part")
    SoundPart.Transparency = 1
    SoundPart.Anchored = true
    SoundPart.CanCollide = false
    SoundPart.Size = Vector3.new(0,0,0)
    SoundPart.CFrame = CFrame.new(Position)
    SoundPart.Parent = Workspace

    local Sound = Instance.new("Sound")
    Sound.SoundId = Id
    Sound.Volume = Volume
    Sound.Parent = SoundPart

    --Destroy the part after the sound finished.
    Sound.Ended:Connect(function()
        SoundPart:Destroy()
    end)
    Sound:Play()
end