local Reaper = require("Reaper")

local Routing = {}

local function GetOutputs(routing)

    if routing.outputs then

        return routing.outputs

    end

    if routing.output then

        return {{
            destination = routing.output
        }}

    end

    return {}

end

local function CreateConfiguredSend(context, sourceEntry, sendData)

    local destination = context.registry.tracks[sendData.destination]

    if not destination then

        error("Unknown routing destination: " .. tostring(sendData.destination))

    end

    local sendIndex = Reaper.CreateSend(sourceEntry.track, destination.track)

    if sendData.mode then

        Reaper.SetSendMode(sourceEntry.track, sendIndex, sendData.mode)

    end

    if sendData.volume ~= nil then

        Reaper.SetSendVolume(sourceEntry.track, sendIndex, sendData.volume)

    end

end

function Routing.Apply(context)

    for _, entry in ipairs(context.tracks) do

        local routing = entry.data.routing

        if routing then

            local outputs = GetOutputs(routing)

            if #outputs > 0 then

                Reaper.SetMainSend(entry.track, false)

                for _, output in ipairs(outputs) do

                    CreateConfiguredSend(context, entry, output)

                end

            end

            for _, send in ipairs(routing.sends or {}) do

                CreateConfiguredSend(context, entry, send)

            end

        end

    end

end

return Routing
