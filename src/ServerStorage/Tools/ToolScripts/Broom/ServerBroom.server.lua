--[[
TheNexusAvenger

Handles the server-side broom.
--]]

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local SwingSound = Handle:WaitForChild("SwingSound")
local WhackSound = Handle:WaitForChild("WhackSound")

local RemoteEventCreator = require(Tool:WaitForChild("RemoteEventCreator"))
local PlayerDamager = require(Tool:WaitForChild("PlayerDamager"))
local Configuration = require(Tool:WaitForChild("Configuration"))

local WALK_SPEED_BUFF = Configuration.WALK_SPEED_BUFF
local BROOM_DAMAGE = Configuration.BROOM_DAMAGE
local BROOM_COOLDOWN = Configuration.BROOM_COOLDOWN
local BLOWBACK_VELOCITY = Configuration.BLOWBACK_VELOCITY
local BLOWBACK_TIME = Configuration.BLOWBACK_TIME
local BROOM_WHACK_SPEED = Configuration.BROOM_WHACK_SPEED

local SwingBroomEvent = RemoteEventCreator:CreateRemoteEvent("SwingBroom")

local CurrentPlayer,CurrentCharacter,CurrentHumanoid
local HitCharacters
local Equipped = false
local ToolEnabled = true



--[[
Registers a hit with the broom.
--]]
function BroomHit(TouchPart)
    --Check if there is a current character and the hit exists.
    if not TouchPart.Parent then return end
    if not CurrentPlayer then return end
    if not CurrentCharacter then return end
    if not CurrentHumanoid then return end

    --Check if it is curringly being swinged.
    if HitCharacters then
        local HitCharacter = TouchPart.Parent
        local HitHumanoid = HitCharacter:FindFirstChildOfClass("Humanoid")

        --If the hit character isn't the weilder, damage the character.
        if HitHumanoid and HitCharacter and HitCharacter ~= CurrentCharacter and CurrentHumanoid.Health > 0 and not HitCharacters[HitCharacter] then
            if PlayerDamager:CanDamageHumanoid(CurrentPlayer,HitHumanoid) then
                HitCharacters[HitCharacter] = true
                PlayerDamager:DamageHumanoid(CurrentPlayer,HitHumanoid,BROOM_DAMAGE,"Broom")
                WhackSound:Play()

                --Force the character back if it has a HumanoidRootPart.
                local HumanoidRootPart = HitCharacter:FindFirstChild("HumanoidRootPart")
                local CurrentHumanoidRootPart = CurrentCharacter:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart and CurrentHumanoidRootPart and not HitCharacter:FindFirstChildOfClass("ForceField") then
                    local BodyVelocity = Instance.new("BodyVelocity")
                    BodyVelocity.MaxForce = Vector3.new(50000, 50000, 50000)
                    BodyVelocity.P = 25000
                    BodyVelocity.Velocity = (CurrentHumanoidRootPart.CFrame * CFrame.Angles(-math.pi * 0.25,math.pi * 0.25,0)).lookVector * BLOWBACK_VELOCITY
                    Debris:AddItem(BodyVelocity,BLOWBACK_TIME)
                    BodyVelocity.Parent = HumanoidRootPart
                end
            end
        end
    end
end



--Set up broom swing.
SwingBroomEvent.OnServerEvent:Connect(function(Player)
    if Player == CurrentPlayer and ToolEnabled then
        --Disable the tool.
        ToolEnabled = false
        Tool.Enabled = false
        HitCharacters = {[Player.Character] = true}

        --Play the swing sound.
        SwingSound.Pitch = 1.2 + (math.random() * 0.2)
        SwingSound:Play()

        spawn(function()
            --Extend and retract the broom.
            TweenService:Create(Tool,TweenInfo.new(1/BROOM_WHACK_SPEED),{
                GripPos = Vector3.new(0,2,0)
            }):Play()
            wait(0.5/BROOM_WHACK_SPEED)
            TweenService:Create(Tool,TweenInfo.new(1/BROOM_WHACK_SPEED),{
                GripPos = Vector3.new(0,0,0)
            }):Play()
        end)
        wait(0.15 + BROOM_COOLDOWN)

        --enable the tool.
        HitCharacters = nil
        ToolEnabled = true
        Tool.Enabled = true
    end
end)

--Set up tool equipping and unequipping.
Tool.Equipped:Connect(function()
    if not Equipped then
        Equipped = true

        --Set current player and increase walkspeed.
        CurrentCharacter = Tool.Parent
        CurrentHumanoid = CurrentCharacter:FindFirstChildOfClass("Humanoid")
        CurrentPlayer = Players:GetPlayerFromCharacter(CurrentCharacter)

        CurrentHumanoid.WalkSpeed = CurrentHumanoid.WalkSpeed + WALK_SPEED_BUFF
    end
end)

Tool.Unequipped:Connect(function()
    if Equipped then
        Equipped = false

        --Reset current player and reset walkspeed buff.
        CurrentHumanoid.WalkSpeed = CurrentHumanoid.WalkSpeed - WALK_SPEED_BUFF
        CurrentCharacter = nil
        CurrentHumanoid = nil
        CurrentPlayer = nil
        SwingSound:Stop()
        WhackSound:Stop()
    end
end)

Handle.Touched:connect(BroomHit)