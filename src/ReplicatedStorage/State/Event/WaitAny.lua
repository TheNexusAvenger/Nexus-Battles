--[[
TheNexusAvenger

Waits for one of many events to occur.
--]]

return function(...)
    --Get the events.
    local Events = {...}
    if #Events == 0 then return end

    --Create the main event.
    local WaitCompleteEvent = Instance.new("BindableEvent")

    --Connect the events.
    local EventConnections = {}
    for _,Event in pairs(Events) do
        table.insert(EventConnections,Event:Connect(function(...)
            --Fire the event.
            WaitCompleteEvent:Fire(...)

            --Clear the connections.
            for _,Connection in pairs(EventConnections) do
                Connection:Disconnect()
            end
            EventConnections = {}
        end))
    end

    --Wait for the event to be fired.
    return WaitCompleteEvent.Event:Wait()
end