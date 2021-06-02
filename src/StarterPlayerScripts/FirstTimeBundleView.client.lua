--[[
TheNexusAvenger

Displays the armor bundle for new players.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageProject = require(ReplicatedStorage:WaitForChild("Project"):WaitForChild("ReplicatedStorage"))

local DataLoadSuccessfulValue = Players.LocalPlayer:WaitForChild("DataLoadSuccessful")
local FirstTimeBundleClosedValue = Players.LocalPlayer:WaitForChild("PersistentStats"):WaitForChild("FirstTimeBundleClosed")
local LoadingScreenCompleteValue = Players.LocalPlayer:WaitForChild("LoadingScreenComplete")
local FirstPlayBundlePrompt = ReplicatedStorageProject:GetResource("UI.Prompt.FirstPlayBundlePrompt")
local NexusAdminFeatureFlags = ReplicatedStorageProject:GetResource("NexusAdminClient").FeatureFlags



--Wait for the load screen to finish.
while not LoadingScreenCompleteValue.Value do
    LoadingScreenCompleteValue:GetPropertyChangedSignal("Value"):Wait()
end

--Return if the data load failed, the prompt was displayed before, or the purchase option is disabled.
if not DataLoadSuccessfulValue.Value or FirstTimeBundleClosedValue.Value or not NexusAdminFeatureFlags:GetFeatureFlag("RobuxPurchasesEnabled") and not NexusAdminFeatureFlags:GetFeatureFlag("RobuxPurchaseFirstArmorBundleEnabled") then
    wait()
    script:Destroy()
    return
end

--Display the prompt.
local Prompt = FirstPlayBundlePrompt.new()
Prompt:Open()
while Prompt.Container.Parent do
    Prompt.Container:GetPropertyChangedSignal("Parent"):Wait()
end
script:Destroy()