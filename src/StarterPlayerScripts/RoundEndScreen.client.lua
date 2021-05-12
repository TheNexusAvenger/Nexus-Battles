--[[
TheNexusAvenger

Controls the end screen of rounds.
--]]

local STAT_TEXT_ASPECT_RATIO = 1.8
local USERNAME_SIZE_ASPECT_RATIO = 8
local LEADERBOARD_ENTRY_HEIGHT_RELATIVE = 0.045



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local LeaveRound = ReplicatedStorageProject:GetResource("Replication.Round.LeaveRound")
local CurrentRoundState = ReplicatedStorageProject:GetResource("State.CurrentRound")
local ContinueTextButtonFactory = ReplicatedStorageProject:GetResource("UI.AudibleTextButtonFactory").CreateDefault(Color3.new(0,170/255,0))
local RoundEndPlayerlist = ReplicatedStorageProject:GetResource("UI.PlayerList.RoundEndPlayerlist")



--[[
Invoked when the round changes.
--]]
local function CurrentRoundChanged(CurrentRound)
    --Return if there is no current round.
    if not CurrentRound then
        return
    end

    --Wait for the round to end.
    while CurrentRoundState.CurrentRound == CurrentRound and CurrentRound.State ~= "ENDED" do
        CurrentRound:GetPropertyChangedSignal("State"):Wait()
    end
    if CurrentRoundState.CurrentRound ~= CurrentRound then return end

    --Get the visible stats.
    local Stats = {}
    for _,StatData in pairs(CurrentRound.RoundStats) do
        if StatData.ShowInLeaderstats then
            table.insert(Stats,StatData)
        end
    end

    --Create the end screen.
    local EndScreeenContainer = Instance.new("ScreenGui")
    EndScreeenContainer.Name = "RoundEndScreen"
    EndScreeenContainer.ResetOnSpawn = false
    EndScreeenContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    --TODO: Implement later
    local Placeholder = Instance.new("Frame")
    Placeholder.BackgroundTransparency = 0.5
    Placeholder.Parent = EndScreeenContainer

    local PlayerListAdorn = Instance.new("Frame")
    PlayerListAdorn.BackgroundTransparency = 1
    PlayerListAdorn.Parent = EndScreeenContainer

    local ContinueButton,ContinueText = ContinueTextButtonFactory:Create()
    ContinueButton.AnchorPoint = Vector2.new(0.5,0)
    ContinueButton.Parent = EndScreeenContainer
    ContinueText.Text = "CONTINUE"

    local Playerlist = RoundEndPlayerlist.new(CurrentRound.Players)
    Playerlist.Stats = Stats
    Playerlist.MVPs = CurrentRound.MVPs
    Playerlist.Parent = PlayerListAdorn

    --[[
    Updates the size of the frames.
    --]]
    local function UpdateSize()
        local ScreenSize = EndScreeenContainer.AbsoluteSize
        if ScreenSize.X > ScreenSize.Y * 0.8 then
            --Update the user interface for landscape mode.
            local LeaderstatsEntrySizeY = ScreenSize.Y * LEADERBOARD_ENTRY_HEIGHT_RELATIVE
            local StatsWidth,UsernameWidth = LeaderstatsEntrySizeY * #Stats * STAT_TEXT_ASPECT_RATIO,LeaderstatsEntrySizeY * USERNAME_SIZE_ASPECT_RATIO
            local TotalLeaderstatsWidth = StatsWidth + UsernameWidth
            local LeaderstatsHeight = 0.6 * ScreenSize.Y
            local UsableLeaderstatsArea = math.min(ScreenSize.X - LeaderstatsHeight,TotalLeaderstatsWidth)

            Placeholder.Position = UDim2.new(0.5,(-UsableLeaderstatsArea/2) - (LeaderstatsHeight/2),0.15,0)
            Placeholder.Size = UDim2.new(0,LeaderstatsHeight,0,LeaderstatsHeight)
            PlayerListAdorn.Position = UDim2.new(0.5,(-UsableLeaderstatsArea/2) + (LeaderstatsHeight/2),0.15,0)
            PlayerListAdorn.Size = UDim2.new(0,UsableLeaderstatsArea,0,LeaderstatsEntrySizeY)
            Playerlist.MaxEntries = math.floor(LeaderstatsHeight/LeaderstatsEntrySizeY) - 1

            ContinueButton.Size = UDim2.new(0.3,0,0.065,0)
            ContinueButton.Position = UDim2.new(0.5,0,0.8,0)
            ContinueButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
        else
            --Update the user interface for landscape mode.
            local ButtonStartPosition = 0.9 * ScreenSize.Y - (ScreenSize.X * (0.4 * (0.065/0.3) * 1.3))
            local PlaceholderStartPosition = ButtonStartPosition - (0.625 * ScreenSize.X)-- TODO: Rename variable
            local LeaderstatsHeight = PlaceholderStartPosition - (0.15 * ScreenSize.Y)
            local LeaderstatsEntrySizeY = 0.8 * ScreenSize.X * (1 / (USERNAME_SIZE_ASPECT_RATIO + (#Stats * STAT_TEXT_ASPECT_RATIO)))

            Placeholder.Position = UDim2.new(0.5,-(ScreenSize.X * 0.6)/2,0,PlaceholderStartPosition)
            Placeholder.Size = UDim2.new(0,ScreenSize.X * 0.6,0,ScreenSize.X * 0.6)
            PlayerListAdorn.Position = UDim2.new(0.1,0,0.125,0)
            PlayerListAdorn.Size = UDim2.new(0.8,0,0,LeaderstatsEntrySizeY)
            Playerlist.MaxEntries = math.floor(LeaderstatsHeight/LeaderstatsEntrySizeY) - 1

            ContinueButton.Size = UDim2.new(0.4,0,0.4 * (0.065/0.3),0)
            ContinueButton.Position = UDim2.new(0.5,0,0,ButtonStartPosition)
            ContinueButton.SizeConstraint = Enum.SizeConstraint.RelativeXX
        end
    end

    --Connect the events.
    CurrentRound:GetPropertyChangedSignal("MVPs"):Connect(function()
        Playerlist.MVPs = CurrentRoundState.MVPs
    end)
    ContinueButton.MouseButton1Down:Connect(function()
        LeaveRound:FireServer()
    end)
    EndScreeenContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    UpdateSize()

    --Wait for the current round to change.
    CurrentRoundState.CurrentRoundChanged:Wait()

    --Clear the end screen.
    EndScreeenContainer:Destroy()
end



--Connect the current round changing.
CurrentRoundState.CurrentRoundChanged:Connect(CurrentRoundChanged)
CurrentRoundChanged(CurrentRoundState.CurrentRound)