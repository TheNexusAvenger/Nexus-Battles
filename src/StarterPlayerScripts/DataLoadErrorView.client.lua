--[[
TheNexusAvenger

Displays that the data failed to load.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local DataLoadSuccessfulValue = Players.LocalPlayer:WaitForChild("DataLoadSuccessful")
local LoadingScreenCompleteValue = Players.LocalPlayer:WaitForChild("LoadingScreenComplete")
local DataLoadErrorPrompt = ReplicatedStorageProject:GetResource("UI.Prompt.DataLoadErrorPrompt")



--Wait for the load screen to finish.
while not LoadingScreenCompleteValue.Value do
    LoadingScreenCompleteValue:GetPropertyChangedSignal("Value"):Wait()
end

--Return if the data loaded successfully.
if DataLoadSuccessfulValue.Value then
    wait()
    script:Destroy()
    return
end

--Display the prompt.
local Prompt = DataLoadErrorPrompt.new()
Prompt:Open()
while Prompt.Container.Parent do
    Prompt.Container:GetPropertyChangedSignal("Parent"):Wait()
end
script:Destroy()