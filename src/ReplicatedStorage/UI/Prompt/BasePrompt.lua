--[[
TheNexusAvenger

Base prompt that is used in the stack of major prompts.
--]]

local PROMPT_TRANSITION_TIME = 0.5



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local PromptStack = ReplicatedStorageProject:GetResource("UI.Prompt.PromptStack")

local BasePrompt = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusInstance"):Extend()
BasePrompt:SetClassName("BasePrompt")



--[[
Creates the base prompt.
--]]
function BasePrompt:__new(Name)
    self:InitializeSuper()

    --Create the adorn frame.
    local Container = Instance.new("ScreenGui")
    Container.Name = Name
    Container.ResetOnSpawn = false
    Container.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.Container = Container

    local AdornFrame = Instance.new("Frame")
    AdornFrame.BackgroundTransparency = 1
    AdornFrame.Position = UDim2.new(0,0,1,0)
    AdornFrame.Size = UDim2.new(1,0,1,0)
    AdornFrame.Parent = Container
    self.AdornFrame = AdornFrame
    self.OpenState = "BELOW"
end

--[[
Shows the prompt.
Intended to be called by the prompt stack.
--]]
function BasePrompt:Show(FromPosition)
    if self.OpenState == "BELOW" and FromPosition == "ABOVE" then
        self.AdornFrame.Position = UDim2.new(0,0,-1,0)
    elseif self.OpenState == "ABOVE" and FromPosition == "BELOW" then
        self.AdornFrame.Position = UDim2.new(0,0,1,0)
    end
    self.OpenState = "CENTER"
    self.AdornFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,PROMPT_TRANSITION_TIME,true)
end

--[[
Hides the prompt upward.
Intended to be called by the prompt stack.
--]]
function BasePrompt:HideUpward()
    self.OpenState = "ABOVE"
    self.AdornFrame:TweenPosition(UDim2.new(0,0,-1,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,PROMPT_TRANSITION_TIME,true)
end

--[[
Hides the prompt downward.
Intended to be called by the prompt stack.
--]]
function BasePrompt:HideDownward()
    self.OpenState = "BELOW"
    self.AdornFrame:TweenPosition(UDim2.new(0,0,1,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,PROMPT_TRANSITION_TIME,true)
end

--[[
Returns if the prompt is open.
--]]
function BasePrompt:IsOpen()
    return (self.OpenState == "CENTER")
end

--[[
Opens the prompt.
--]]
function BasePrompt:Open()
    PromptStack:Add(self)
end

--[[
Closes the prompt.
--]]
function BasePrompt:Close()
    PromptStack:Remove(self)
end

--[[
Toggles the prompt.
--]]
function BasePrompt:Toggle()
    if self:IsOpen() then
        self:Close()
    else
        self:Open()
    end
end

--[[
Destroys the prompt.
--]]
function BasePrompt:Destroy()
    self.super:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true

    if self:IsOpen() then
        coroutine.wrap(function()
            self.object:Close()
            wait(PROMPT_TRANSITION_TIME)
            self.Container:Destroy()
        end)()
    else
        self.Container:Destroy()
    end
end



return BasePrompt