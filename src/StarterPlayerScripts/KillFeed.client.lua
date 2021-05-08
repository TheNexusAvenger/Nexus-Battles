--[[
TheNexusAvenger

Displays kills on the client.
--]]

local KILL_FEED_MESSGAE_DURATION = 5
local MAX_KILLFEED_MESSAGES = 3
local KILL_FEED_START_POSITION = 0.6
local KILL_FEED_MESSAGE_HEIGHT_RELATIVE = 0.05



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local KillFeedMessage = ReplicatedStorageProject:GetResource("UI.KillFeedMessage")

local MessagesQueue = {}



local DisplayMessageEvent = Instance.new("BindableEvent")
DisplayMessageEvent.Name = "DisplayMessage"
DisplayMessageEvent.Parent = script

local KillfeedContainer = Instance.new("ScreenGui")
KillfeedContainer.Name = "Killfeed"
KillfeedContainer.ResetOnSpawn = false
KillfeedContainer.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")



--[[
Updates the message positions.
--]]
local function UpdateMessagePositions()
    for i,Message in pairs(MessagesQueue) do
        Message:SetYPosition(KILL_FEED_START_POSITION + ((i - 1) * KILL_FEED_MESSAGE_HEIGHT_RELATIVE))
    end
end

--[[
Removes a killfeed message.
--]]
local function RemoveMessage(KillFeedMessage)
    --Get the index.
    local MessageIndex
    for i,Message in pairs(MessagesQueue) do
        if Message == KillFeedMessage then
            MessageIndex = i
            break
        end
    end
    if not MessageIndex then return end

    --Remove the message and update the positions.
    table.remove(MessagesQueue,MessageIndex)
    KillFeedMessage:Hide()
    UpdateMessagePositions()
end

--[[
Creates a killfeed message.
--]]
local function CreateMessage(KillFeedData)
    --Create the message.
    local Message = KillFeedMessage.new(KillFeedData)
    Message.HeightPixels = KillfeedContainer.AbsoluteSize.Y * KILL_FEED_MESSAGE_HEIGHT_RELATIVE
    Message.Parent = KillfeedContainer
    Message:SetYPosition(KILL_FEED_START_POSITION,true)
    table.insert(MessagesQueue,1,Message)

    --Play the audio.
    if KillFeedData.AudioId then
        local Sound = Instance.new("Sound")
        Sound.SoundId = "rbxassetid://"..tostring(KillFeedData.AudioId)
        SoundService:PlayLocalSound(Sound)
    end

    --Show the message.
    Message:Show()
    if MessagesQueue[MAX_KILLFEED_MESSAGES + 1] then
        RemoveMessage(MessagesQueue[MAX_KILLFEED_MESSAGES + 1])
    end
    UpdateMessagePositions()

    --Destory the message.
    wait(KILL_FEED_MESSGAE_DURATION)
    RemoveMessage(Message)
end



--Connect the killfeed event.
DisplayMessageEvent.Event:Connect(function(KillFeedData)
    CreateMessage(KillFeedData)
end)

--Connect the screen size changing.
KillfeedContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    for _,Message in pairs(MessagesQueue) do
        Message.HeightPixels = KillfeedContainer.AbsoluteSize.Y * KILL_FEED_MESSAGE_HEIGHT_RELATIVE
    end
end)