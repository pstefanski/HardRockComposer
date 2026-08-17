local Reaper = require("Reaper")
local Timing = require("Timing")
local ColorsPalette = require("ColorsPalette")

local Regions = {}

function Regions.Apply(
    context,
    settings
)

    Reaper.ClearMarkers()

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

        local color = nil

        if section.color then

            color =
                ColorsPalette[
                    section.color
                ]

            if not color then

                error(
                    "Unknown region color: " ..
                    tostring(section.color)
                )

            end

        end

        Reaper.AddRegion(
            section.name,
            startTime,
            endTime,
            color
        )

    end

end

return Regions