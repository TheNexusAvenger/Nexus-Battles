--[[
TheNexusAvenger

Stores the active prompts in a stack.
--]]

local BLUR_TRANSITION_TIME = 0.5



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local PromptStack = ReplicatedStorageProject:GetResource("External.NexusInstance.NexusObject"):Extend()
PromptStack:SetClassName("PromptStack")
PromptStack.Prompts = {}



--[[
Adds a prompt to the stack.
--]]
function PromptStack:Add(Prompt)
    --Hide the existing prompt.
    if self.Prompts[#self.Prompts] then
        self.Prompts[#self.Prompts]:HideUpward()
    end

    --Show the blur if it doesn't exist.
    if not self.Blur then
        self.Blur = Instance.new("BlurEffect")
        self.Blur.Size = 0
        self.Blur.Parent = Lighting

        TweenService:Create(self.Blur,TweenInfo.new(BLUR_TRANSITION_TIME),{
            Size = 20,
        }):Play()
    end

    --Add the prompt and show it.
    table.insert(self.Prompts,Prompt)
    Prompt:Show("BELOW")
end

--[[
Removes a prompt from the stack.
--]]
function PromptStack:Remove(Prompt)
    --Get the last index to remove.
    --A prompt may existing the stack multiple places.
    local Index
    for i,OtherPrompt in pairs(self.Prompts) do
        if Prompt == OtherPrompt then
            Index = i
        end
    end
    if not Index then return end

    --Remove the prompt and update the open prompt.
    if Index == #self.Prompts and Index > 1 then
        self.Prompts[#self.Prompts - 1]:Show("ABOVE")
    end
    Prompt:HideDownward()
    table.remove(self.Prompts,Index)

    --Hide the blur if there is no more prompts.
    if #self.Prompts == 0 and self.Blur then
        local Blur = self.Blur
        self.Blur = nil

        TweenService:Create(Blur,TweenInfo.new(BLUR_TRANSITION_TIME),{
            Size = 0,
        }):Play()
        delay(BLUR_TRANSITION_TIME,function()
            Blur:Destroy()
        end)
    end
end



return PromptStack