local Reaper = require("Reaper")

local Routing = {}

function Routing.Apply(context)

    for _, entry in ipairs(context.tracks) do

        local destinationId = entry.data.route_to

        if destinationId then

            local destination = context.registry.tracks[destinationId]

            if destination then

                Reaper.SetMainSend(entry.track, false)

                Reaper.CreateSend(
                    entry.track,
                    destination.track
                )

            end

        end

    end

end

return Routing