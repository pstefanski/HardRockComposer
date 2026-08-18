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

function MidiWriter.WritePatternAtBar(take, pattern, startQN, beatsPerBar, humanization, energy)

    local humanize = humanization and humanization.enabled

    for _, note in ipairs(pattern.notes) do

        local noteQN = startQN + note.position / 4

        local endQN = noteQN + note.length / 4

        local timingOffset = 0

        local velocity = Dynamics.Velocity(note.velocity, energy)

        if humanize then

            velocity = Humanizer.Velocity(note.velocity, humanization.velocity)

            timingOffset = Humanizer.Timing(humanization.timing)

        end

        local startPPQ = Reaper.QNToPPQ(take, noteQN)

        local endPPQ = Reaper.QNToPPQ(take, endQN)

        startPPQ = startPPQ + timingOffset

        endPPQ = endPPQ + timingOffset

        Reaper.InsertMidiNote(take, startPPQ, endPPQ, note.pitch, velocity)

    end

end

return MidiWriter
