local Reaper = require("Reaper")

local Markers = {}

function Markers.Apply(context)

    Reaper.ClearMarkers()

    for _, section in ipairs(context.song) do

        local position = Reaper.BarToTime(
            section.startBar
        )

        Reaper.AddMarker(
            section.name,
            position
        )

    end

end

return Markers