local Reaper = require("Reaper")

local Regions = {}

function Regions.Apply(context)

    for _, section in ipairs(context.song) do

        local startTime = Reaper.BarToTime(
            section.startBar
        )

        local endTime = Reaper.BarToTime(
            section.endBar + 1
        )

        Reaper.AddRegion(
            section.name,
            startTime,
            endTime
        )

    end

end

return Regions