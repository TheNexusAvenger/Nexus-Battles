--[[
TheNexusAvenger

Displays the team scores for the current round.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")



--Connect creating the uesr interface.
CurrentRoundState:ConnectTo("CurrentRound",{
    Start = function(self,CurrentRound)
        if not CurrentRound.TeamScores then
            return
        end

        --Wait for the round to start.
        while CurrentRound.State == "LOADING" do
            CurrentRound:GetPropertyChangedSignal("State"):Wait()
        end
        if not self:IsActive() then return end

        --Create the score view.
        local ScoreContainer = Instance.new("ScreenGui")
        ScoreContainer.Name = "TeamScores"
        ScoreContainer.ResetOnSpawn = false
        ScoreContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        self.CurretScoreContainer = ScoreContainer

        local ScoreText = Instance.new("TextLabel")
        ScoreText.BackgroundTransparency = 1
        ScoreText.Size = UDim2.new(1,0,0.05,0)
        ScoreText.Position = UDim2.new(0.5,0,0.125,0)
        ScoreText.AnchorPoint = Vector2.new(0.5,0)
        ScoreText.Font = "SourceSansBold"
        ScoreText.TextColor3 = Color3.new(1,1,1)
        ScoreText.TextStrokeColor3 = Color3.new(0,0,0)
        ScoreText.TextStrokeTransparency = 0
        ScoreText.TextScaled = true
        ScoreText.RichText = true
        ScoreText.Parent = ScoreContainer

        --[[
        Updates the score text.
        --]]
        local function UpdateScores()
            --Build the scores.
            local TeamScores = {}
            for TeamColorName,Score in pairs(CurrentRound.TeamScores.Table) do
                local TeamColor = BrickColor.new(TeamColorName).Color
                table.insert(TeamScores,"<font color=\"rgb("..tostring(math.ceil(TeamColor.R * 255))..","..tostring(math.ceil(TeamColor.G * 255))..","..tostring(math.ceil(TeamColor.B * 255))..")\">"..tostring(Score).."</font>")
            end

            --Set the scores.
            ScoreText.Text = table.concat(TeamScores," vs ")
        end

        --Connect updating the scores.
        CurrentRound.TeamScores.ItemAdded:Connect(UpdateScores)
        CurrentRound.TeamScores.ItemChanged:Connect(UpdateScores)
        UpdateScores()

        --Wait for the round to end and destroy the player list.
        while CurrentRoundState.CurrentRound == CurrentRound and CurrentRound.State ~= "ENDED" do
            CurrentRound:GetPropertyChangedSignal("State"):Wait()
        end
        if CurrentRoundState.CurrentRound ~= CurrentRound then return end
        self:Clear()
    end,
    Clear = function(self)
        if self.CurretScoreContainer then
            self.CurretScoreContainer:Destroy()
            self.CurretScoreContainer = nil
        end
    end,
})