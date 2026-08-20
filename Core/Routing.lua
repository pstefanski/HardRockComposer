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

function Routing.Apply(context)

    for _, entry in ipairs(context.tracks) do

        local routing = entry.data.routing

        if routing then

            local outputs = GetOutputs(routing)

            if #outputs > 0 then

                Reaper.SetMainSend(entry.track, false)

                for _, output in ipairs(outputs) do

                    local destination = context.registry.tracks[output.destination]

                    if not destination then

                        error("Unknown routing destination: " .. tostring(output.destination))

                    end

                    local sendIndex = Reaper.CreateSend(entry.track, destination.track)

                    if output.mode then

                        Reaper.SetSendMode(entry.track, sendIndex, output.mode)

                    end

                end

            end

        end

    end

end

return Routing
