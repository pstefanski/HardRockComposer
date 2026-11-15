local MidiNotes = require("Patterns.MidiNotes")

local Drums = {}

local function Note(pitch, position, velocity, length)
    return {pitch = pitch, position = position, length = length or 0.25, velocity = velocity}
end

local function Add(notes, pitch, position, velocity, length)
    table.insert(notes, Note(pitch, position, velocity, length))
end

local function AddKicks(notes, positions, velocity)
    for _, position in ipairs(positions) do
        Add(notes, MidiNotes.drums.kick, position, velocity)
    end
end

local function AddBackbeat(notes, velocity, ghostVelocity)
    Add(notes, MidiNotes.drums.snare, 4, velocity)
    Add(notes, MidiNotes.drums.snare, 12, velocity)
    if ghostVelocity then
        Add(notes, MidiNotes.drums.snare, 7, ghostVelocity)
        Add(notes, MidiNotes.drums.snare, 15, ghostVelocity)
    end
end

local function AddEighthHats(notes, accent, normal, skipPosition)
    for position = 0, 14, 2 do
        if position ~= skipPosition then
            Add(notes, MidiNotes.drums.closed_hat, position, position % 4 == 0 and accent or normal)
        end
    end
end

local function AddSemiOpenHatQuarters(notes, velocity)
    for position = 0, 12, 4 do
        Add(notes, MidiNotes.drums.semi_open_hat, position, velocity)
    end
end

local function AddRide(notes, accent, normal, startPosition)
    for position = startPosition or 0, 14, 2 do
        Add(notes, MidiNotes.drums.ride, position, position % 4 == 0 and accent or normal)
    end
end

local function AddCrashQuarters(notes, velocity, startPosition)
    for position = startPosition or 0, 12, 4 do
        Add(notes, MidiNotes.drums.crash, position, velocity, 1)
    end
end

local function Pattern(id, name, notes, transitionBeats)
    table.insert(Drums, {
        id = id,
        name = name,
        type = "drums",
        resolution = 16,
        bars = 1,
        transitionBeats = transitionBeats,
        notes = notes
    })
end

do
    local notes = {}
    for position = 0, 14, 2 do
        Add(notes, MidiNotes.drums.floor_tom, position, position % 4 == 0 and 108 or 96)
    end
    Add(notes, MidiNotes.drums.snare, 4, 104)
    Add(notes, MidiNotes.drums.snare, 12, 106)
    Add(notes, MidiNotes.drums.high_tom, 7, 92)
    Add(notes, MidiNotes.drums.mid_tom, 15, 96)
    Pattern("intro_toms", "Intro Toms", notes)
end

do
    local notes = {}
    for position = 0, 14, 2 do
        Add(notes, MidiNotes.drums.floor_tom, position, position % 4 == 0 and 112 or 100)
    end
    Add(notes, MidiNotes.drums.snare, 4, 108)
    Add(notes, MidiNotes.drums.snare, 12, 110)
    Add(notes, MidiNotes.drums.mid_tom, 3, 90)
    Add(notes, MidiNotes.drums.high_tom, 7, 96)
    Add(notes, MidiNotes.drums.mid_tom, 11, 94)
    Add(notes, MidiNotes.drums.high_tom, 15, 100)
    Pattern("intro_toms_alt", "Intro Toms Build", notes)
end

do
    local notes = {}
    AddKicks(notes, {0, 8}, 112)
    AddBackbeat(notes, 112)
    AddSemiOpenHatQuarters(notes, 88)
    Pattern("verse_drive", "Verse Drive", notes)
end

do
    local notes = {}
    AddKicks(notes, {0, 8}, 108)
    Add(notes, MidiNotes.drums.kick, 10, 92)
    AddBackbeat(notes, 112)
    AddSemiOpenHatQuarters(notes, 90)
    Pattern("verse_drive_alt", "Verse Drive Alt", notes)
end

do
    local notes = {}
    Add(notes, MidiNotes.drums.crash, 0, 124, 1)
    AddKicks(notes, {0, 8}, 118)
    AddBackbeat(notes, 120)
    AddCrashQuarters(notes, 116, 4)
    Pattern("chorus_crash", "Chorus Crash", notes)
end

do
    local notes = {}
    AddKicks(notes, {0, 8}, 118)
    AddBackbeat(notes, 120)
    AddCrashQuarters(notes, 116)
    Pattern("chorus_drive", "Chorus Drive", notes)
end

do
    local notes = {}
    AddKicks(notes, {0, 8}, 116)
    Add(notes, MidiNotes.drums.kick, 10, 96)
    AddBackbeat(notes, 120)
    AddCrashQuarters(notes, 120)
    Pattern("chorus_crash_alt", "Chorus Crash Alt", notes)
end

do
    local notes = {}
    Add(notes, MidiNotes.drums.crash, 0, 124, 1)
    AddKicks(notes, {0, 8}, 116)
    AddBackbeat(notes, 118)
    AddRide(notes, 94, 82, 2)
    Pattern("solo_crash", "Solo Crash", notes)
end

do
    local notes = {}
    AddKicks(notes, {0, 8}, 114)
    Add(notes, MidiNotes.drums.kick, 10, 94)
    AddBackbeat(notes, 116)
    AddRide(notes, 94, 82)
    Pattern("solo_ride", "Solo Ride", notes)
end

do
    local notes = {}
    AddKicks(notes, {0, 8}, 114)
    AddBackbeat(notes, 116)
    AddEighthHats(notes, 92, 78, 14)
    Add(notes, MidiNotes.drums.open_hat, 14, 96)
    Pattern("solo_drive_alt", "Solo Drive Alt", notes)
end

do
    local notes = {}
    Add(notes, MidiNotes.drums.crash, 0, 127, 1)
    AddKicks(notes, {0, 8}, 120)
    AddBackbeat(notes, 122)
    AddRide(notes, 98, 86, 2)
    Pattern("outro_crash", "Outro Crash", notes)
end

do
    local notes = {}
    Add(notes, MidiNotes.drums.crash, 0, 122, 1)
    AddKicks(notes, {0, 8}, 118)
    AddBackbeat(notes, 120)
    AddRide(notes, 96, 84, 2)
    Pattern("outro_drive", "Outro Drive", notes)
end

Pattern("fill_snare_pickup", "Snare Pickup", {
    Note(MidiNotes.drums.snare, 12, 92),
    Note(MidiNotes.drums.snare, 13, 100),
    Note(MidiNotes.drums.snare, 14, 110),
    Note(MidiNotes.drums.snare, 15, 120)
}, 1)

Pattern("fill_tom_2beat", "Two Beat Tom Fill", {
    Note(MidiNotes.drums.high_tom, 8, 100),
    Note(MidiNotes.drums.high_tom, 10, 104),
    Note(MidiNotes.drums.mid_tom, 12, 110),
    Note(MidiNotes.drums.mid_tom, 13, 112),
    Note(MidiNotes.drums.low_tom, 14, 118),
    Note(MidiNotes.drums.low_tom, 15, 122)
}, 2)

Pattern("fill_big", "Big Drum Fill", {
    Note(MidiNotes.drums.high_tom, 12, 108),
    Note(MidiNotes.drums.mid_tom, 13, 114),
    Note(MidiNotes.drums.low_tom, 14, 120),
    Note(MidiNotes.drums.low_tom, 15, 124)
}, 1)

return Drums
