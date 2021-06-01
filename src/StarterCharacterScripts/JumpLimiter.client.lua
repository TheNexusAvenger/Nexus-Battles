--[[
TheNexusAvenger

Limits jumps to prevent bunny-hopping.
--]]

local SEQUENTIAL_JUMP_LIMIT = 4
local PENALTY_DURATION = 3
local JUMP_TIME = 0.75
local NO_FADE_TIME = 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local LastJumpTime = 0
local SequentialJumps = 0
local LastPenaltyTime = 0



--[[
Displays a GUI for the jumping too much.
--]]
local function AnimatePenaltyLabel()
    local JumpPenaltyContainer = Instance.new("ScreenGui")
    JumpPenaltyContainer.Name = "JumpPenalty"
    JumpPenaltyContainer.ResetOnSpawn = true
    JumpPenaltyContainer.Parent = PlayerGui

    local ExhaustedText = Instance.new("TextLabel")
    ExhaustedText.BackgroundTransparency = 1
    ExhaustedText.Size = UDim2.new(1,0,0.075,0)
    ExhaustedText.Position = UDim2.new(0,0,0.75,0)
    ExhaustedText.Font = "ArialBold"
    ExhaustedText.Text = "Exhausted!"
    ExhaustedText.TextColor3 = Color3.new(0,0,0)
    ExhaustedText.TextScaled = true
    ExhaustedText.TextStrokeColor3 = Color3.new(1,1,1)
    ExhaustedText.TextStrokeTransparency = 0
    ExhaustedText.Parent = JumpPenaltyContainer

    wait(NO_FADE_TIME)
    TweenService:Create(ExhaustedText,TweenInfo.new(PENALTY_DURATION - NO_FADE_TIME),{
        TextStrokeTransparency = 1,
        TextTransparency = 1,
    }):Play()
    wait(PENALTY_DURATION - NO_FADE_TIME)
    JumpPenaltyContainer:Destroy()
end



--Return if the game mode is Rocket Race.
if CurrentRoundState.CurrentRound and CurrentRoundState.CurrentRound.Name == "RocketRace" then
    wait()
    script:Destroy()
	return
end

--Connect the player jumping.
Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
    local CurrentTime = tick()
    if CurrentTime - LastPenaltyTime <= PENALTY_DURATION then
        --Stop the jump if the penalty is active.
        Humanoid.Jump = false
    else
        --Store how many jumps occured recently.
        if CurrentTime - LastJumpTime > 0.25 then
            SequentialJumps = (CurrentTime - LastJumpTime < JUMP_TIME) and SequentialJumps + 1 or 0
        end

        --Start the penalty if the threshold was reached.
        if SequentialJumps >= SEQUENTIAL_JUMP_LIMIT then
            LastPenaltyTime = CurrentTime
            coroutine.wrap(AnimatePenaltyLabel)()
        end
        LastJumpTime = CurrentTime
    end
end)
