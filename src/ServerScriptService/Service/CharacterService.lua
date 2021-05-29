--[[
TheNexusAvenger

Service for managing character loading.
--]]

local CHARACTER_ARMOR_SLOTS = {
    "Head",
    "Body",
    "Legs",
}



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))
local ServerScriptServiceProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ServerScriptService"))

local ArmorService = ServerScriptServiceProject:GetResource("Service.ArmorService")
local InventoryService = ServerScriptServiceProject:GetResource("Service.InventoryService")

local CharacterService = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
CharacterService:SetClassName("CharacterService")
CharacterService.LastTools = {}
CharacterService.LastCFrames = {}



--[[
Spawns a character for the given player.
Returns the character that was spawned in.
--]]
function CharacterService:SpawnCharacter(Player)
    --Return if the player is not in the game.
    if not Player or not Player.Parent then return end

    --Load the character.
    Player:LoadCharacter()
    local Character = Player.Character
    local Humanoid = Character:WaitForChild("Humanoid")

    --Set the character colors.
    local BodyColors = Instance.new("BodyColors")
    BodyColors.HeadColor = BrickColor.new("Bright yellow")
    BodyColors.LeftArmColor = BrickColor.new("Bright yellow")
    BodyColors.RightArmColor = BrickColor.new("Bright yellow")
    BodyColors.TorsoColor = BrickColor.new("Light stone grey")
    BodyColors.LeftLegColor = BrickColor.new("Dark green")
    BodyColors.RightLegColor = BrickColor.new("Dark green")
    BodyColors.Parent = Character

    --Add the armor.
    local Inventory = InventoryService:GetInventory(Player)
    for _,Slot in pairs(CHARACTER_ARMOR_SLOTS) do
        local Item = Inventory:GetItemAtSlot(Slot)
        if Item then
            ArmorService:Equip(Player,Item.Id)
        end
    end

    --Connect the inventory changing.
    local InventoryChangedEvent
    InventoryChangedEvent = Inventory.InventoryChanged:Connect(function()
        --Disconnect the event if the character changed.
        if Player.Character ~= Character then
            InventoryChangedEvent:Disconnect()
            InventoryChangedEvent = nil
            return
        end

        --Update the armor.
        for _,Slot in pairs(CHARACTER_ARMOR_SLOTS) do
            local Item = Inventory:GetItemAtSlot(Slot)
            if Item then
                ArmorService:Equip(Player,Item.Id)
            else
                ArmorService:Unequip(Player,Slot)
            end
        end
    end)

    --Add the team indicator.
    local TeamIndicator = Instance.new("Part")
    TeamIndicator.Transparency = (Player.Neutral and 1 or 0.2)
    TeamIndicator.BrickColor = Player.TeamColor
    TeamIndicator.Material = "Neon"
    TeamIndicator.Size = Vector3.new(0.2,0.2,0.2)
    TeamIndicator.CanCollide = false
    TeamIndicator.Name = "TeamIndicator"
    TeamIndicator.Parent = Character

    local Mesh = Instance.new("SpecialMesh")
    Mesh.MeshType = Enum.MeshType.Brick
    Mesh.Scale = Vector3.new(5.5,5.5,5.5)
    Mesh.Parent = TeamIndicator

    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local TeamIndicatorJoint = Instance.new("Motor6D")
    TeamIndicatorJoint.Name = "TeamIndicatorJoint"
    TeamIndicatorJoint.Part0 = HumanoidRootPart
    TeamIndicatorJoint.Part1 = TeamIndicator
    TeamIndicatorJoint.C0 = CFrame.new(0,4.5,0) * CFrame.Angles(0.5,0,0)
    TeamIndicatorJoint.C1 = CFrame.Angles(0.5,0,0.5)
    TeamIndicatorJoint.DesiredAngle = 10^10
    TeamIndicatorJoint.MaxVelocity = 0.12
    TeamIndicatorJoint.Parent = HumanoidRootPart

    Player:GetPropertyChangedSignal("Neutral"):Connect(function()
        TeamIndicator.Transparency = (Player.Neutral and 1 or 0.2)
    end)
    Player:GetPropertyChangedSignal("TeamColor"):Connect(function()
        TeamIndicator.BrickColor = Player.TeamColor
    end)

    --Connect setting the last tools.
    Character.ChildAdded:Connect(function(Tool)
        if not Tool:IsA("Tool") then return end
        self.LastTools[Player] = Tool.Name
    end)

    --Equip a tool automatically.
    delay(1,function()
        --Return if there is a tool equipped.
        if not Character.Parent then return end
        if Character:FindFirstChildOfClass("Tool") then return end

        --Equip a tool.
        local Backpack = Player:FindFirstChild("Backpack")
        if not Backpack then return end
        local Tool = (self.LastTools[Player] and Backpack:FindFirstChild(self.LastTools[Player])) or Backpack:GetChildren()[1]
        Humanoid:EquipTool(Tool)
    end)

    --Set the last CFrame.
    if self.LastCFrames[Player] then
        HumanoidRootPart.CFrame = self.LastCFrames[Player]
        self.LastCFrames[Player] = nil
    end

    --Return the character.
    return Character
end

--[[
Despawns the character for the given player.
--]]
function CharacterService:DespawnCharacter(Player)
    --Return if the player is not in the game.
    if not Player or not Player.Parent then return end
    if not Player.Character then return end

    --Destroy the character and clear the backpack.
    local CurrentTool = Player.Character:FindFirstChildOfClass("Tool")
    if CurrentTool then
        CurrentTool:Destroy()
    end
    Player.Character:Destroy()
    local Backpack = Player:FindFirstChild("Backpack")
    if not Backpack then return end
    Backpack:ClearAllChildren()
end

--[[
Stores the last character CFrame to use when
spawning later.
--]]
function CharacterService:StoreCharacterCFramne(Player)
    local Character = Player.Character
    if not Character then return end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    self.LastCFrames[Player] = HumanoidRootPart.CFrame
end

--[[
Add a forcefield to the player for a
specified period of time, or until 1 second
after equipping a tool.
--]]
function CharacterService:AddForceField(Player,Duration)
    --Return if there is no character.
    local Character = Player.Character
    if not Character then return end

    --Create the forcefield.
    local ForceField = Instance.new("ForceField")
    ForceField.Parent = Character

    --Set up removing.
    Character.ChildAdded:Connect(function(Ins)
        if Ins:IsA("Tool") then
            wait(1)
            ForceField:Destroy()
        end
    end)
    delay(Duration or 10,function()
        ForceField:Destroy()
    end)
end



--Connect players leaving.
Players.PlayerRemoving:Connect(function(Player)
    CharacterService.LastTools[Player] = nil
    CharacterService.LastCFrames[Player] = nil
end)



return CharacterService