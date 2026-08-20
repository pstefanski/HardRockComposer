local Reaper = require("Reaper")
local Humanizer = require("Humanizer")
local Dynamics = require("Dynamics")

local MidiWriter = {}

function MidiWriter.CreateItem(track, startQN, endQN)

    return Reaper.CreateMidiItem(track, startQN, endQN)

end
function MidiWriter.WritePattern(take, pattern, patternStartQN, beatsPerBar, repeatCount, humanization)

    repeatCount = repeatCount or 1

    local patternLengthQN = pattern.bars * beatsPerBar

    for repetition = 0, repeatCount - 1 do

        local repetitionStartQN = patternStartQN + repetition * patternLengthQN

        MidiWriter.WritePatternAtBar(take, pattern, repetitionStartQN, beatsPerBar, humanization)

    end

    Reaper.SortMidi(take)

end

local function WritePatternBetweenBeats(take, pattern, startQN, startBeat, endBeat, humanization, energy)

    local humanize = humanization and humanization.enabled
    local windowStartQN = startQN + startBeat
    local windowEndQN = startQN + endBeat

    for _, note in ipairs(pattern.notes) do

        local noteQN = startQN + note.position / 4
        local noteEndQN = noteQN + note.length / 4

        if noteQN >= windowStartQN and noteQN < windowEndQN then

            local endQN = math.min(noteEndQN, windowEndQN)
            local velocity = Dynamics.Velocity(note.velocity, energy)
            local timingOffset = 0

            if humanize then
                velocity = Humanizer.Velocity(velocity, humanization.velocity)
                timingOffset = Humanizer.Timing(humanization.timing)
            end

            local startPPQ = Reaper.QNToPPQ(take, noteQN) + timingOffset
            local endPPQ = Reaper.QNToPPQ(take, endQN) + timingOffset

            Reaper.InsertMidiNote(take, startPPQ, endPPQ, note.pitch, velocity)
        end

    end

end

function MidiWriter.WritePatternAtBar(take, pattern, startQN, beatsPerBar, humanization, energy)

    WritePatternBetweenBeats(take, pattern, startQN, 0, pattern.bars * beatsPerBar, humanization, energy)

end

function MidiWriter.WritePatternUntilBeat(take, pattern, startQN, beatsPerBar, endBeat, humanization, energy)

    WritePatternBetweenBeats(take, pattern, startQN, 0, endBeat, humanization, energy)

end

function MidiWriter.WritePatternBetweenBeats(take, pattern, startQN, beatsPerBar, startBeat, endBeat, humanization,
                                              energy)

    WritePatternBetweenBeats(take, pattern, startQN, startBeat, endBeat, humanization, energy)

end

return MidiWriter
