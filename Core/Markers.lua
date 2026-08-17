local Reaper = require("Reaper")
local Timing = require("Timing")

local Markers = {}

function Markers.Apply(context, settings)

    Reaper.ClearMarkers()

    for _, section in ipairs(context.song) do

        local positionQN =
            Timing.BarToQN(
                section.startBar,
                settings
            )

        local position =
            Reaper.QNToTime(
                positionQN
            )

        Reaper.AddMarker(
            section.name,
            position
        )

    end

end

return Markers