local Reaper = require("Reaper")

local MidiWriter = {}

function MidiWriter.CreateItem(
    track,
    startQN,
    endQN
)

    return Reaper.CreateMidiItem(
        track,
        startQN,
        endQN
    )

end

function MidiWriter.WritePattern(
    take,
    pattern,
    patternStartQN,
    beatsPerBar,
    repeatCount
)

    repeatCount = repeatCount or 1

    local patternLengthQN =
        pattern.bars * beatsPerBar

    for repetition = 0, repeatCount - 1 do

        local repetitionStartQN =
            patternStartQN
            + repetition
            * patternLengthQN

        for _, note in ipairs(pattern.notes) do

            local noteQN =
                repetitionStartQN
                + note.position / 4

            local endQN =
                noteQN
                + note.length / 4

            local startPPQ =
                Reaper.QNToPPQ(
                    take,
                    noteQN
                )

            local endPPQ =
                Reaper.QNToPPQ(
                    take,
                    endQN
                )

            Reaper.InsertMidiNote(
                take,
                startPPQ,
                endPPQ,
                note.pitch,
                note.velocity
            )

        end

    end

    Reaper.SortMidi(take)

end

function MidiWriter.WritePatternAtBar(
    take,
    pattern,
    startQN,
    beatsPerBar
)

    for _, note in ipairs(pattern.notes) do

        local noteQN =
            startQN
            + note.position / 4

        local endQN =
            noteQN
            + note.length / 4

        local startPPQ =
            Reaper.QNToPPQ(
                take,
                noteQN
            )

        local endPPQ =
            Reaper.QNToPPQ(
                take,
                endQN
            )

        Reaper.InsertMidiNote(
            take,
            startPPQ,
            endPPQ,
            note.pitch,
            note.velocity
        )

    end

end

return MidiWriter