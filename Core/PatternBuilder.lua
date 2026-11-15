local MidiNotes = require("Patterns.MidiNotes")

--------------------------------------------------
-- Small vocabulary used by the style files to declare drum patterns.
--
-- Positions are expressed in sixteenth notes from the start of the bar
-- (0 = first beat, 4 = second quarter note, ...), whatever the time
-- signature: a 12/8 bar spans positions 0 to 23.
--------------------------------------------------

local PatternBuilder = {}

local drums = MidiNotes.drums

PatternBuilder.Drums = drums

function PatternBuilder.Note(pitch, position, velocity, length)

    return {
        pitch = pitch,
        position = position,
        length = length or 0.25,
        velocity = velocity
    }

end

function PatternBuilder.Add(notes, pitch, position, velocity, length)

    table.insert(notes, PatternBuilder.Note(pitch, position, velocity, length))

end

-- Adds the same note at each listed position.
function PatternBuilder.AddAt(notes, pitch, positions, velocity, length)

    for _, position in ipairs(positions) do

        PatternBuilder.Add(notes, pitch, position, velocity, length)

    end

end

-- Adds a note every `step` sixteenths from `first` to `last` (inclusive).
-- Positions that are multiples of `accentEvery` use the accent velocity.
function PatternBuilder.AddEvery(notes, pitch, first, last, step, accent, normal, accentEvery, length)

    for position = first, last, step do

        local velocity = normal or accent

        if accentEvery and position % accentEvery == 0 then
            velocity = accent
        end

        PatternBuilder.Add(notes, pitch, position, velocity, length)

    end

end

--------------------------------------------------
-- 4/4 rock helpers
--------------------------------------------------

function PatternBuilder.AddKicks(notes, positions, velocity)

    PatternBuilder.AddAt(notes, drums.kick, positions, velocity)

end

-- Snare on beats 2 and 4, with optional ghost notes just before.
function PatternBuilder.AddBackbeat(notes, velocity, ghostVelocity)

    PatternBuilder.Add(notes, drums.snare, 4, velocity)
    PatternBuilder.Add(notes, drums.snare, 12, velocity)

    if ghostVelocity then
        PatternBuilder.Add(notes, drums.snare, 7, ghostVelocity)
        PatternBuilder.Add(notes, drums.snare, 15, ghostVelocity)
    end

end

function PatternBuilder.AddEighthHats(notes, accent, normal, skipPosition)

    for position = 0, 14, 2 do

        if position ~= skipPosition then
            PatternBuilder.Add(notes, drums.closed_hat, position, position % 4 == 0 and accent or normal)
        end

    end

end

function PatternBuilder.AddSemiOpenHatQuarters(notes, velocity)

    PatternBuilder.AddEvery(notes, drums.semi_open_hat, 0, 12, 4, velocity)

end

function PatternBuilder.AddRide(notes, accent, normal, startPosition)

    for position = startPosition or 0, 14, 2 do
        PatternBuilder.Add(notes, drums.ride, position, position % 4 == 0 and accent or normal)
    end

end

function PatternBuilder.AddCrashQuarters(notes, velocity, startPosition)

    PatternBuilder.AddEvery(notes, drums.crash, startPosition or 0, 12, 4, velocity, nil, nil, 1)

end

--------------------------------------------------
-- Pattern collection
--------------------------------------------------

-- Returns a function that appends drum patterns to `list`.
--
--     local Pattern = PatternBuilder.Collector(Drums)
--     Pattern("verse", "Verse", notes)                 -- 1 bar
--     Pattern("fill", "Fill", notes, 1)                -- 1-beat transition fill
--     Pattern("groove", "Groove", notes, nil, 2)       -- 2 bars
function PatternBuilder.Collector(list)

    return function(id, name, notes, transitionBeats, bars)

        table.insert(list, {
            id = id,
            name = name,
            type = "drums",
            resolution = 16,
            bars = bars or 1,
            transitionBeats = transitionBeats,
            notes = notes
        })

    end

end

return PatternBuilder
