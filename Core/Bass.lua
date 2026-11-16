local Reaper = require("Reaper")
local Timing = require("Timing")
local MidiWriter = require("MidiWriter")
local Harmony = require("Harmony")
local Arrangement = require("Arrangement")
local MidiNotes = require("Patterns.MidiNotes")

--------------------------------------------------
-- Generates a bass line from the section chords.
--
-- SongSettings.bass = {
--     mode = "kick" | "eighths" | "boogie",
--     velocity = 100,     -- base velocity
--     legato = 0.9        -- note length, as a share of the gap to the next note
-- }
--
--   kick     plays the chord root on every kick drum hit
--   eighths  plays the root on every eighth note
--   boogie   shuffle root–5th–6th–5th, one interval per beat
--------------------------------------------------

local Bass = {}

local BASS_TRACK = "bass_midi"

Bass.MODES = {
    kick = true,
    eighths = true,
    boogie = true
}

local BOOGIE_INTERVALS = {0, 7, 9, 7}

-- Kick positions (sixteenths) played in `bar` according to the drum plan.
local function KickPositions(plan, bar)

    local positions = {}
    local seen = {}

    for _, segment in ipairs(plan or {}) do

        if segment.bar == bar then

            for _, note in ipairs(segment.pattern.notes) do

                local qn = note.position / 4

                if note.pitch == MidiNotes.drums.kick and qn >= segment.fromQN and qn < segment.toQN and
                    not seen[note.position] then

                    seen[note.position] = true

                    table.insert(positions, note.position)

                end

            end

        end

    end

    table.sort(positions)

    if #positions == 0 or positions[1] > 0 then

        table.insert(positions, 1, 0)

    end

    return positions

end

-- Returns the list of { position, interval } of a bar.
local function Hits(mode, plan, bar, settings, barLength)

    local hits = {}

    if mode == "kick" then

        for _, position in ipairs(KickPositions(plan, bar)) do
            table.insert(hits, {
                position = position,
                interval = 0
            })
        end

    elseif mode == "eighths" then

        for position = 0, barLength - 1, 2 do
            table.insert(hits, {
                position = position,
                interval = 0
            })
        end

    else

        local count, beatLength = Timing.Beats(settings)

        for beat = 1, count do

            local start = (beat - 1) * beatLength
            local interval = BOOGIE_INTERVALS[(beat - 1) % #BOOGIE_INTERVALS + 1]

            table.insert(hits, {
                position = start,
                interval = interval
            })
            table.insert(hits, {
                position = start + beatLength * 2 / 3,
                interval = interval
            })

        end

    end

    return hits

end

local function BarNotes(section, bar, hits, options, qnPerBar, barLength)

    local notes = {}

    for index, hit in ipairs(hits) do

        local nextPosition = hits[index + 1] and hits[index + 1].position or barLength
        local chord = Harmony.ChordAt(section, (bar - 1) * qnPerBar + hit.position / 4, qnPerBar)

        local velocity = options.velocity

        if hit.position == 0 then
            velocity = math.min(127, velocity + 10)
        end

        table.insert(notes, {
            pitch = Harmony.BassPitch(chord.bass) + hit.interval,
            position = hit.position,
            length = (nextPosition - hit.position) * options.legato,
            velocity = velocity
        })

    end

    return notes

end

function Bass.Apply(context, settings)

    local bass = settings.bass

    if not bass then
        return
    end

    local trackEntry = context.registry.tracks[BASS_TRACK]

    if not trackEntry then
        error("Missing MIDI track: " .. BASS_TRACK)
    end

    local options = {
        mode = bass.mode or "kick",
        velocity = bass.velocity or 100,
        legato = bass.legato or 0.9
    }

    local qnPerBar = Timing.QNPerBar(settings)
    local barLength = qnPerBar * 4

    for index, section in ipairs(context.song) do

        if section.chords and #section.chords > 0 then

            local plan = Arrangement.DrumPlan(section, context.song[index + 1], context.registry, qnPerBar)

            local feel = {
                energy = section.energy or 1,
                humanization = settings.humanization,
                swing = settings.swing
            }

            local startQN = Timing.BarToQN(section.startBar, settings)
            local endQN = Timing.BarToQN(section.endBar + 1, settings)

            local item = MidiWriter.CreateItem(trackEntry.track, startQN, endQN)
            local take = Reaper.GetActiveTake(item)

            for bar = 1, section.bars do

                local hits = Hits(options.mode, plan, bar, settings, barLength)

                local pattern = {
                    bars = 1,
                    notes = BarNotes(section, bar, hits, options, qnPerBar, barLength)
                }

                MidiWriter.WritePattern(take, pattern, startQN + (bar - 1) * qnPerBar, qnPerBar, feel)

            end

            Reaper.SortMidi(take)

        end

    end

    Reaper.UpdateArrange()

end

return Bass
