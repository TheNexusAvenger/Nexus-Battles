--[[
TheNexusAvenger

Displays a 3D icon for a player with armor.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local Armor = ReplicatedStorageProject:GetResource("Data.Armor")
local ArmorModels = ReplicatedStorageProject:GetResource("Model.ArmorModels")
local BaseCharacter = ReplicatedStorageProject:GetResource("Model.BaseCharacter")

local PlayerIcon = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
PlayerIcon:SetClassName("PlayerIcon")



--[[
Creates the player icon.
--]]
function PlayerIcon:__new()
    self:InitializeSuper()

    --Create the frame.
    local ViewportFrame = Instance.new("ViewportFrame")
    ViewportFrame.BackgroundTransparency = 1
    self.ViewportFrame = ViewportFrame

    local CharacterWorldModel = Instance.new("WorldModel")
    CharacterWorldModel.Parent = ViewportFrame

    local Camera = Instance.new("Camera")
    Camera.CFrame = CFrame.new(0,-0.5,-11) * CFrame.Angles(0,math.pi,0)
    Camera.FieldOfView = 30
    Camera.Parent = ViewportFrame
    ViewportFrame.CurrentCamera = Camera
    self.Camera = Camera

    local Character = BaseCharacter:Clone()
    Character:WaitForChild("HumanoidRootPart").Anchored = true
    Character.Parent = CharacterWorldModel
    self.Character = Character
    self.CharacterArmor = {}

    --Connect changing the properties.
    self:GetPropertyChangedSignal("Parent"):Connect(function()
        ViewportFrame.Parent = self.Parent
    end)
    self:GetPropertyChangedSignal("Size"):Connect(function()
        ViewportFrame.Size = self.Size
    end)
    self:GetPropertyChangedSignal("SizeConstraint"):Connect(function()
        ViewportFrame.SizeConstraint = self.SizeConstraint
    end)
    self:GetPropertyChangedSignal("Position"):Connect(function()
        ViewportFrame.Position = self.Position
    end)
    self:GetPropertyChangedSignal("ZIndex"):Connect(function()
        ViewportFrame.ZIndex = self.ZIndex
    end)
end

--[[
Plays an animation for the character.
--]]
function PlayerIcon:PlayAnimation(AnimationId)
    --Create the animation.
    local Animation = Instance.new("Animation")
    Animation.AnimationId = AnimationId

    --Load and play the animation.
    self.Character:WaitForChild("Humanoid"):LoadAnimation(Animation):Play()
end

--[[
Clears the apperance of the character.
--]]
function PlayerIcon:ClearAppearance()
    for _,Ins in pairs(self.Character:GetDescendants()) do
        if Ins:IsA("BasePart") then
            Ins.BrickColor = BrickColor.new("Medium stone grey")
        elseif Ins:IsA("Decal") then
            Ins:Destroy()
        end
    end
end

--[[
Sets the armor for a given slot.
--]]
function PlayerIcon:SetArmor(Slot,Id)
    --Remove the existing armor.
    if self.CharacterArmor[Slot] and self.CharacterArmor[Slot].Id ~= Id then
        for _,Part in pairs(self.CharacterArmor[Slot].Parts) do
            Part:Destroy()
        end
        self.CharacterArmor[Slot] = nil
    end

    --Get the name of the armor.
    local ArmorModelName
    for Name,ArmorData in pairs(Armor) do
        if ArmorData.Id == Id then
            ArmorModelName = Name
            break
        end
    end
    if not ArmorModelName then return end

    --Equip the new armor.
    local EquippedArmorData = {
        Id = Id,
        Parts = {},
    }
    self.CharacterArmor[Slot] = EquippedArmorData
    local ArmorModel = ArmorModels:WaitForChild(ArmorModelName):Clone()
    for _,CharacterPart in pairs(self.Character:GetChildren()) do
        if CharacterPart:IsA("BasePart") then
            local ArmorBasePart = ArmorModel:FindFirstChild(CharacterPart.Name)
            if ArmorBasePart then
                for _,Weld in pairs(ArmorBasePart:GetChildren()) do
                    if Weld:IsA("JointInstance") then
                        --Weld the armor part to the character.
                        if Weld.Part1 == ArmorBasePart then
                            Weld.Part0,Weld.Part1 = Weld.Part1,Weld.Part0
                        end
                        if Weld.Part1 then
                            Weld.Part0 = CharacterPart
                            Weld.Part1.Parent = CharacterPart
                            Weld.Parent = Weld.Part1
                            table.insert(EquippedArmorData.Parts,Weld.Part1)
                        end
                    end
                end
            end
        end
    end
end



return PlayerIcon