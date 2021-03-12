--[[
TheNexusAvenger

Centralizes remote object creation.
--]]

local RemoteEventCreator = {}

local Tool = script.Parent



--[[
Creates a remote event.
--]]
function RemoteEventCreator:CreateRemoteEvent(Name)
    --Warn if an item with that name exists.
    if Tool:FindFirstChild(Name) then
        warn("Conflicting item "..Name.." exists in "..Tool:GetFullName())
    end

    --Create and return the remote event.
    local RemoteEvent = Instance.new("RemoteEvent")
    RemoteEvent.Name = Name
    RemoteEvent.Parent = Tool

    return RemoteEvent
end

--[[
Creates a remote function.
--]]
function RemoteEventCreator:CreateRemoteFunction(Name)
    --Warn if an item with that name exists.
    if Tool:FindFirstChild(Name) then
        warn("Conflicting item "..Name.." exists in "..Tool:GetFullName())
    end

    --Create and return the remote function.
    local RemoteFunction = Instance.new("RemoteFunction")
    RemoteFunction.Name = Name
    RemoteFunction.Parent = Tool

    return RemoteFunction
end

--[[
Gets a remote event. It does not check the class.
--]]
function RemoteEventCreator:GetRemoteEvent(Name)
    return Tool:WaitForChild(Name)
end

--[[
Gets a remote event. It does not check the class.
--]]
function RemoteEventCreator:GetRemoteFunction(Name)
    return RemoteEventCreator:GetRemoteEvent(Name)
end



return RemoteEventCreator