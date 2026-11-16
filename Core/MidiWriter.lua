local Reaper = require("Reaper")
local Humanizer = require("Humanizer")
local Dynamics = require("Dynamics")
local Timing = require("Timing")

--------------------------------------------------
-- Writes pattern notes into a MIDI take.
--
-- feel = {
--     energy,          -- 0..1, scales velocities (Dynamics)
--     humanization,    -- SongSettings.humanization
--     swing            -- SongSettings.swing
-- }
--------------------------------------------------

local MidiWriter = {}

function MidiWriter.CreateItem(track, startQN, endQN)

    return Reaper.CreateMidiItem(track, startQN, endQN)

end

-- Writes the notes of `pattern` whose grid position falls in
-- [fromQN, toQN[, both relative to `barQN` (the start of the pattern).
-- Notes are cut at `toQN`. Swing and humanization move the notes after
-- the window test, so a note always belongs to the window of its grid
-- position.
function MidiWriter.WriteBetween(take, pattern, barQN, fromQN, toQN, feel)

    feel = feel or {}

    local humanization = feel.humanization
    local humanize = humanization and humanization.enabled

    local windowStartQN = barQN + fromQN
    local windowEndQN = barQN + toQN

    for _, note in ipairs(pattern.notes) do

        local gridQN = barQN + note.position / 4

        if gridQN >= windowStartQN and gridQN < windowEndQN then

            local swingQN = Timing.SwingOffsetQN(note.position, feel.swing)
            local noteQN = gridQN + swingQN
            local endQN = math.min(gridQN + note.length / 4 + swingQN, windowEndQN)

            if endQN <= noteQN then
                endQN = math.min(noteQN + note.length / 4, windowEndQN + swingQN)
            end

            local velocity = Dynamics.Velocity(note.velocity, feel.energy)
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

-- Writes a whole pattern starting at `barQN`.
function MidiWriter.WritePattern(take, pattern, barQN, qnPerBar, feel)

    MidiWriter.WriteBetween(take, pattern, barQN, 0, pattern.bars * qnPerBar, feel)

end

return MidiWriter
