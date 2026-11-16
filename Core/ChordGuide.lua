local Reaper = require("Reaper")
local Timing = require("Timing")
local Harmony = require("Harmony")

--------------------------------------------------
-- Writes the chord changes of every section on the "Chords" track, as
-- empty items whose text shows the chord symbol.
--------------------------------------------------

local ChordGuide = {}

local CHORD_TRACK = "chords"

function ChordGuide.Apply(context, settings)

    local trackEntry = context.registry.tracks[CHORD_TRACK]

    if not trackEntry then
        return
    end

    local qnPerBar = Timing.QNPerBar(settings)

    for _, section in ipairs(context.song) do

        local sectionQN = Timing.BarToQN(section.startBar, settings)

        for _, change in ipairs(Harmony.Changes(section, qnPerBar)) do

            local startTime = Reaper.QNToTime(sectionQN + change.fromQN)
            local endTime = Reaper.QNToTime(sectionQN + change.toQN)

            Reaper.CreateTextItem(trackEntry.track, startTime, endTime, change.chord.symbol)

        end

    end

end

return ChordGuide
