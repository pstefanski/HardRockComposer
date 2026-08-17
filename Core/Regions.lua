local Reaper = require("Reaper")
local Timing = require("Timing")

local Regions = {}

function Regions.Apply(context, settings)

    for _, section in ipairs(context.song) do

        local startQN =
            Timing.BarToQN(
                section.startBar,
                settings
            )

        local endQN =
            Timing.BarToQN(
                section.endBar + 1,
                settings
            )

        local startTime =
            Reaper.QNToTime(
                startQN
            )

        local endTime =
            Reaper.QNToTime(
                endQN
            )

        Reaper.AddRegion(
            section.name,
            startTime,
            endTime
        )

    end

end

return Regions