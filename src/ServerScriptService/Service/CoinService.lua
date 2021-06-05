--[[
TheNexusAvenger

Service for managing player coins.
--]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local LocalEffectService = ServerScriptServiceProject:GetResource("Service.LocalEffectService")
local StatService = ServerScriptServiceProject:GetResource("Service.StatService")

local CoinService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
CoinService:SetClassName("CoinService")



--[[
Returns a random number.
--]]
local function RandomNumber(Start,End)
    return Start + ((End - Start) * math.random())
end



--[[
Awards coins to a player.
Returns true if it was successful and false if there
was not enough coins.
--]]
function CoinService:GiveCoins(Player,Total,WorldPosition)
    Total = math.floor((Total or 1) + 0.5)

    --Get the stats and coins.
    local Stats = StatService:GetPersistentStats(Player)
    local CurrentCoins = Stats:Get("Coins"):Get()

    --Return if there is not enough coins.
    if Total + CurrentCoins < 0 then
        return false
    end

    --Add the coins.
    Stats:Get("Coins"):Increment(Total)
    Stats:Get("TotalCoins"):Increment(Total)

    --Play the animation on the client.
    if WorldPosition then
        LocalEffectService:PlayLocalEffect(Player,"DisplayWorldSpaceCoin",Total,WorldPosition)
    else
        LocalEffectService:PlayLocalEffect(Player,"DisplayCoinsUpdate",Total)
    end

    --Return true.
    return true
end

--[[
Drops a coin in Workspace.
--]]
function CoinService:DropCoin(SpawnPosition,Parent)
    --Create the coin.
    local Coin = Instance.new("Part")
    Coin.Name = "Coin"
    Coin.BrickColor = BrickColor.new("Bright yellow")
    Coin.Material = "SmoothPlastic"
    Coin.Size = Vector3.new(1.5,0.2,1.5)

    local TopFace = Instance.new("Decal")
    TopFace.Texture = "http://www.roblox.com/asset/?id=121148238"
    TopFace.Face = "Top"
    TopFace.Parent = Coin

    local BottomFace = Instance.new("Decal")
    BottomFace.Texture = "http://www.roblox.com/asset/?id=121148238"
    BottomFace.Face = "Bottom"
    BottomFace.Parent = Coin

    --Creates a coin and set up the touched event.
    Coin.Touched:Connect(function(TouchPart)
        --Return if the touch part is a handle.
        if not TouchPart.Parent then return end
        if TouchPart.Name == "Handle" then return end

        --Add the coin for the player.
        local Humanoid = TouchPart.Parent:FindFirstChild("Humanoid")
        if Humanoid and Humanoid.Health > 0 then
            local Player = game.Players:GetPlayerFromCharacter(TouchPart.Parent)
            if Player then
                local CoinPosition = Coin.Position
                Coin:Destroy()
                CoinService:GiveCoins(Player,1,CoinPosition)
            end
        end
    end)

    --Set the position and velocity.
    Coin.CFrame = CFrame.new(SpawnPosition) * CFrame.Angles(RandomNumber(0,math.pi),RandomNumber(0,math.pi),RandomNumber(0,math.pi))
    Coin.AssemblyLinearVelocity = Vector3.new(RandomNumber(-1,1),RandomNumber(1,2), RandomNumber(-1,1)).Unit * 20
    Coin.AssemblyAngularVelocity = Vector3.new(RandomNumber(-10,10),RandomNumber(-10,10),RandomNumber(-10,10))
    Coin.Parent = Parent or Workspace

    --Make the coin decay between 13 and 18 seconds.
    Debris:AddItem(Coin,13 + (math.random() * 5))
end



return CoinService