--[[
TheNexusAvenger

Provides a client buffer for launching projectiles.
This uses an exploit of network ownership where clients can change the physics
of parts locally without needing to handle anything on the server.
--]]

local Workspace = game:GetService("Workspace")

local BufferCreator = {}
local Tool = script.Parent



--[[
Creates a buffer class.
--]]
local function CreateBuffer(Folder)
    local Buffer = {}

    --Removes an item from the buffer.
    function Buffer:PopItem()
        local NextItem = Folder:GetChildren()[1]

        if NextItem then
            --Remove the position lock.
            local BufferPositionLock = NextItem:FindFirstChild("BufferPositionLock",true)
            if BufferPositionLock then
                BufferPositionLock:Destroy()
            end

            --Reparent it to Workspace.
            NextItem.Parent = Workspace

            --Return the item.
            return NextItem
        end
    end

    --Return the buffer class.
    return Buffer
end



--[[
Creates a server-side buffer. Inherits the base buffer class.
--]]
function BufferCreator:CreateServerBuffer(BufferName)
    local BufferFolder = Instance.new("Folder")
    BufferFolder.Name = BufferName
    BufferFolder.Parent = Tool

    local Buffer = CreateBuffer(BufferFolder)
    local Player

    --Adds an item to the buffer.
    function Buffer:AddItem(NewItem)
        NewItem.Parent = BufferFolder

        local Part = (NewItem:IsA("BasePart") and NewItem) or NewItem:FindFirstChildWhichIsA("BasePart",true)
        if Part then
            --Add a position lock.
            local HoldPos = Vector3.new(math.random(-1000,1000),100000,math.random(-1000,1000))
            Part.CFrame = CFrame.new(HoldPos)
            local PositionLock = Instance.new("BodyPosition")
            PositionLock.Position = HoldPos
            PositionLock.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            PositionLock.Name = "BufferPositionLock"
            PositionLock.Parent = Part

            --Set the network ownership to the client so it can control physics.
            if Part:IsDescendantOf(Workspace) and not Part.Anchored and Player then
                Part:SetNetworkOwner(Player)
            end
        end
    end

    --Sets the network ownership of the buffer.
    function Buffer:SetCurrentPlayer(NewPlayer)
        Player = NewPlayer

        for _,Item in pairs(BufferFolder:GetChildren()) do
            local Part = (Item:IsA("BasePart") and Item) or Item:FindFirstChildWhichIsA("BasePart",true)

            if Part and Part:IsDescendantOf(Workspace) and not Part.Anchored and Player then
                Part:SetNetworkOwner(NewPlayer)
            end
        end
    end

    --Return the buffer class.
    return Buffer
end

--[[
Creates a client-side buffer.
--]]
function BufferCreator:CreateClientBuffer(BufferName)
    return CreateBuffer(Tool:WaitForChild(BufferName))
end



return BufferCreator
