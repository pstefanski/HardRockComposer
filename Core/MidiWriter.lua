local Reaper = require("Reaper")

local MidiWriter = {}

function MidiWriter.CreateItem(
    track,
    startPosition,
    length
)

    local item = Reaper.CreateMidiItem(
        track,
        startPosition,
        length
    )

    return item

end

function MidiWriter.WritePattern(
    take,
    pattern,
    ppqPerQuarter
)

    for _, note in ipairs(pattern.notes) do

        local startPPQ =
            note.position *
            (ppqPerQuarter / 4)

        local lengthPPQ =
            note.length *
            (ppqPerQuarter / 4)

        Reaper.InsertMidiNote(
            take,
            startPPQ,
            startPPQ + lengthPPQ,
            note.pitch,
            note.velocity
        )

    end

end

return MidiWriter