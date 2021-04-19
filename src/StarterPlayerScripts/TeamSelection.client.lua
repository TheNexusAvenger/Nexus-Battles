--[[
TheNexusAvenger

User interface for selecting teams before rounds.
--]]

local BUTTON_BORDER_COLOR_OFFSET = Color3.new(-30/255,-30/255,-30/255)



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local TextButtonFactory = ReplicatedStorageProject:GetResource("External.NexusButton.Factory.TextButtonFactory")
local JoinTeamTextButtonFactory = ReplicatedStorageProject:GetResource("External.NexusButton.Factory.TextButtonFactory").CreateDefault(Color3.new(1,1,1))
JoinTeamTextButtonFactory:SetTextDefault("Font",Enum.Font.SourceSansBold)
JoinTeamTextButtonFactory:SetTextDefault("Text","JOIN")
JoinTeamTextButtonFactory:SetDefault("Size",UDim2.new(4,0,1,0))
JoinTeamTextButtonFactory:SetDefault("SizeConstraint",Enum.SizeConstraint.RelativeYY)



--Create the user interface.
local TeamSelectionGui = Instance.new("ScreenGui")
TeamSelectionGui.Name = "TeamSelectionGui"
TeamSelectionGui.ResetOnSpawn = false
TeamSelectionGui.Enabled = false
TeamSelectionGui.DisplayOrder = 5
TeamSelectionGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local SelectTeamText = Instance.new("TextLabel")
SelectTeamText.BackgroundTransparency = 1
SelectTeamText.Size = UDim2.new(1,0,0.06,0)
SelectTeamText.Position = UDim2.new(0.5,0,0.75,01)
SelectTeamText.AnchorPoint = Vector2.new(0.5,0)
SelectTeamText.Font = "SourceSansBold"
SelectTeamText.TextColor3 = Color3.new(0,0,0)
SelectTeamText.TextStrokeColor3 = Color3.new(1,1,1)
SelectTeamText.TextStrokeTransparency = 0
SelectTeamText.TextScaled = true
SelectTeamText.Text = "Select your team!"
SelectTeamText.Parent = TeamSelectionGui

local TeamPlayersView = Instance.new("Frame")
TeamPlayersView.BackgroundTransparency = 1
TeamPlayersView.Size = UDim2.new(1,0,0.5,0)
TeamPlayersView.Position = UDim2.new(0.5,0,0.5,0)
TeamPlayersView.AnchorPoint = Vector2.new(0.5,0.5)
TeamPlayersView.SizeConstraint = Enum.SizeConstraint.RelativeYY
TeamPlayersView.Parent = TeamSelectionGui

local TeamButtonView = Instance.new("Frame")
TeamButtonView.BackgroundTransparency = 1
TeamButtonView.Size = UDim2.new(0.065 * 4,0,0.065,0)
TeamButtonView.Position = UDim2.new(0.5,0,0.81,0)
TeamButtonView.AnchorPoint = Vector2.new(0.5,0)
TeamButtonView.SizeConstraint = Enum.SizeConstraint.RelativeYY
TeamButtonView.Parent = TeamSelectionGui

local TeamButtonList = Instance.new("UIListLayout")
TeamButtonList.Padding = UDim.new(0.1,0)
TeamButtonList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TeamButtonList.FillDirection = Enum.FillDirection.Horizontal
TeamButtonList.Parent = TeamButtonView



--[[
Adds two Color3s.
--]]
local function AddColor3(Color1,Color2)
	--Multiply the R,G,B values.
	local NewR,NewG,NewB = Color1.R + Color2.R,Color1.G + Color2.G,Color1.B + Color2.B

	--Clamp the values.
	NewR = math.clamp(NewR,0,1)
	NewG = math.clamp(NewG,0,1)
	NewB = math.clamp(NewB,0,1)

	--Return the color.
	return Color3.new(NewR,NewG,NewB)
end

--[[
Invoked when the round changes.
--]]
local function CurrentRoundChanged(CurrentRound)
    --Hide the user interface if there is no current round or there is no current team selection.
    if not CurrentRound or not CurrentRound.TeamSelection or CurrentRound.State ~= "LOADING" then
        TeamSelectionGui.Enabled = false
        return
    end

    --Set up the team selection.
    local Events = {}
    local PlayerImages = {}
    local JoinTeamButtons = {}
    TeamSelectionGui.Enabled = true
    --TODO: Implement rest

    --[[
    Updates the player grid layout.
    --]]
    local function UpdateGridLayout()
        --Determine the optimal rows to use.
        local ScreenSize = TeamSelectionGui.AbsoluteSize
        local PlayersViewHeight = ScreenSize.Y * 0.5
        local Rows = 1
        local LastHeight = 0
        while true do
            local NewRows = Rows + 1
            local CellsPerRow = math.ceil(#PlayerImages/NewRows)
            local CellHeight = ScreenSize.X/CellsPerRow
            if CellHeight > LastHeight and CellHeight <= PlayersViewHeight then
                LastHeight = CellHeight
                Rows = NewRows
            end
            if CellsPerRow * PlayersViewHeight * (1/NewRows) < ScreenSize.X then
                break
            end
        end

        --Reduce the scale if the current selected row is a bit too large.
        local FinalCellsPerRow = math.ceil(#PlayerImages/Rows)
        local FinalRowWidth = FinalCellsPerRow * (PlayersViewHeight/Rows)
        local Multiplier = 1
        if ScreenSize.X < FinalRowWidth then
            Multiplier = ScreenSize.X/FinalRowWidth
        end

        --Update the frames.
        for i,PlayerImage in pairs(PlayerImages) do
            local Container = PlayerImage.Container
            local FrameRow = math.ceil(i/FinalCellsPerRow)
            local FramesInRow = math.min(FinalCellsPerRow,#PlayerImages - ((FrameRow - 1) * FinalCellsPerRow))
            Container.Size = UDim2.new(0.95 * (1/Rows),0,0.95 * (1/Rows),0)
            Container.Position = UDim2.new((1 - FramesInRow/2) + (i % FramesInRow),0,(FrameRow - 0.5)/Rows,0)
        end
        TeamPlayersView.Size = UDim2.new(0,Multiplier * (PlayersViewHeight/Rows),0,Multiplier * PlayersViewHeight)

        --Update the size of the buttons.
        local TotalButtons = #JoinTeamButtons
        local ButtonsMultiplier = 1
        local RequiredButtonsWidth = TotalButtons * 1.1 * 0.065 * 4 * ScreenSize.Y
        if ScreenSize.X < RequiredButtonsWidth then
            ButtonsMultiplier = ScreenSize.X/RequiredButtonsWidth
        end
        TeamButtonView.Size = UDim2.new(0.065 * 4 * ButtonsMultiplier,0,0.065 * ButtonsMultiplier,0)
    end

    --[[
    Updates the join team buttons.
    --]]
    local function UpdateJoinButtons()
        --Create the additional buttons.
        local TeamColors = CurrentRound.TeamSelection.TeamColors
        for i = #JoinTeamButtons + 1,#TeamColors do
            --Create the button.
            local JoinTeamButton,JoinTeamText = JoinTeamTextButtonFactory:Create()
            JoinTeamButton.Parent = TeamButtonView
            table.insert(JoinTeamButtons,{
                Button = JoinTeamButton,
                Text = JoinTeamText,
            })

            --Connect the button.
            local DB = true
            JoinTeamButton.MouseButton1Down:Connect(function()
                if DB then
                    DB = false
                    CurrentRound.TeamSelection:SetPlayerTeam(Players.LocalPlayer,CurrentRound.TeamSelection.TeamColors[i])
                    wait()
                    DB = true
                end
            end)
        end

        --Remove extra buttons.
        for i = #JoinTeamButtons,#TeamColors + 1,-1 do
            JoinTeamButtons[i].Button:Destroy()
            JoinTeamButtons[i] = nil
        end

        --Update the buttons.
        for i,Color in pairs(TeamColors) do
            local JoinButtonData = JoinTeamButtons[i]
            local TeamFull = CurrentRound.TeamSelection:IsFull(Color)
            JoinButtonData.Button.BackgroundColor3 = Color.Color
            JoinButtonData.Button.BorderColor3 = AddColor3(Color.Color,BUTTON_BORDER_COLOR_OFFSET)
            JoinButtonData.Button.AutoButtonColor = not TeamFull
            JoinButtonData.Text.Text = (TeamFull and "FULL" or "JOIN")
        end
    end

    --[[
    Updates the visible players.
    --]]
    local function UpdatePlayersView()
        --Create the additional frames.
        local RoundPlayers = CurrentRound.Players:GetAll()
        for _ = #PlayerImages + 1,#RoundPlayers do
            local PlayerContainer = Instance.new("Frame")
            PlayerContainer.BackgroundColor3 = Color3.new(1,1,1)
            PlayerContainer.BorderSizePixel = 0
            PlayerContainer.AnchorPoint = Vector2.new(0.5,0.5)
            PlayerContainer.BackgroundTransparency = 0.5
            PlayerContainer.SizeConstraint = Enum.SizeConstraint.RelativeYY
            PlayerContainer.Parent = TeamPlayersView

            local PlayerContainerCorner = Instance.new("UICorner")
            PlayerContainerCorner.CornerRadius = UDim.new(0.2,0)
            PlayerContainerCorner.Parent = PlayerContainer

            local PlayerImage = Instance.new("ImageLabel")
            PlayerImage.BackgroundTransparency = 1
            PlayerImage.Size = UDim2.new(1,0,1,0)
            PlayerImage.Image = ""
            PlayerImage.Parent = PlayerContainer

            local PlayerImageCorner = Instance.new("UICorner")
            PlayerImageCorner.CornerRadius = UDim.new(0.2,0)
            PlayerImageCorner.Parent = PlayerImage

            table.insert(PlayerImages,{
                Container = PlayerContainer,
                Image = PlayerImage,
            })
        end

        --Remove extra frames.
        for i = #PlayerImages,#RoundPlayers + 1,-1 do
            PlayerImages[i].Container:Destroy()
            PlayerImages[i] = nil
        end

        --Sort the players and update the images.
        table.sort(RoundPlayers,function(a,b)
            return string.lower(a.Name) < string.lower(b.Name)
        end)
        for i,Player in pairs(RoundPlayers) do
            local PlayerTeamColor = CurrentRound.TeamSelection.PlayerTeams:Get(Player.Name)
            local PlayerFrame = PlayerImages[i]
            PlayerFrame.Container.BackgroundColor3 = (PlayerTeamColor and PlayerTeamColor.Color or Color3.new(1,1,1))
            PlayerFrame.Image.Image = "rbxthumb://type=AvatarHeadShot&id="..tostring(Player.UserId).."&w=420&h=420"
        end

        --Update the grid.
        UpdateGridLayout()

        --Update the join buttons.
        UpdateJoinButtons()
    end

    --Connect the change events.
    table.insert(Events,TeamSelectionGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateGridLayout))
    table.insert(Events,CurrentRound.Players.ItemAdded:Connect(UpdatePlayersView))
    table.insert(Events,CurrentRound.Players.ItemRemoved:Connect(UpdatePlayersView))
    table.insert(Events,CurrentRound.TeamSelection.PlayerTeams.ItemChanged:Connect(UpdatePlayersView))
    table.insert(Events,CurrentRound.TeamSelection:GetPropertyChangedSignal("TeamColors"):Connect(UpdateJoinButtons))
    UpdateJoinButtons()
    UpdatePlayersView()

    --Hide the user interface after the round starts.
    while CurrentRound.State == "LOADING" do
        CurrentRound:GetPropertyChangedSignal("State"):Wait()
    end
    for _,Event in pairs(Events) do
        Event:Disconnect()
    end
    for _,PlayerImage in pairs(PlayerImages) do
        PlayerImage.Container:Destroy()
    end
    for _,JoinButton in pairs(JoinTeamButtons) do
        JoinButton.Button:Destroy()
    end
    TeamSelectionGui.Enabled = false
end



--Connect the current round changing.
CurrentRoundState.CurrentRoundChanged:Connect(CurrentRoundChanged)
CurrentRoundChanged(CurrentRoundState.CurrentRound)