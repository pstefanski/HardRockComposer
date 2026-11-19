local MidiNotes = require("Patterns.MidiNotes")
local PatternBuilder = require("PatternBuilder")

--------------------------------------------------
-- Hard Rock drum patterns (4/4, straight).
--------------------------------------------------

local Drums = {}

local Note = PatternBuilder.Note
local Add = PatternBuilder.Add
local AddKicks = PatternBuilder.AddKicks
local AddBackbeat = PatternBuilder.AddBackbeat
local AddEighthHats = PatternBuilder.AddEighthHats
local AddSemiOpenHatQuarters = PatternBuilder.AddSemiOpenHatQuarters
local AddRide = PatternBuilder.AddRide
local AddCrashQuarters = PatternBuilder.AddCrashQuarters

local Pattern = PatternBuilder.Collector(Drums)

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

--------------------------------------------------
-- Generated grooves (see Core/DrumGroove.lua). The patterns above stay
-- available for sections that name them.
--------------------------------------------------

Drums.grooves = {

    -- Floor tom drive with tom answers.
    intro = {
        phrase = 4,
        pulse = { voice = "floor_tom", every = 2, velocity = 96, accent = 108 },
        kick = { positions = {0}, velocity = 104, options = { {8, 0.5} } },
        snare = { positions = {4, 12}, velocity = 104 },
        extras = {
            { voice = "high_tom", position = 7, chance = 0.7, velocity = 92 },
            { voice = "mid_tom", position = 15, chance = 0.6, velocity = 96 },
            { voice = "mid_tom", position = 3, chance = 0.3, velocity = 90 },
            { voice = "high_tom", position = 11, chance = 0.3, velocity = 94 }
        }
    },

    -- Eighth notes on the hi-hat, syncopated kicks, a few ghost notes.
    verse = {
        phrase = 4,
        pulse = {
            voice = "closed_hat", every = 2, velocity = 78, accent = 98,
            open = { voice = "open_hat", positions = {14}, chance = 0.4, velocity = 92 }
        },
        kick = {
            positions = {0, 8}, velocity = 112,
            options = { {10, 0.5, 96}, {6, 0.25, 92}, {14, 0.15, 90}, {3, 0.15, 88} }
        },
        snare = { positions = {4, 12}, velocity = 114 },
        ghosts = { positions = {7, 15, 9, 1}, chance = 0.35, velocity = 34, max = 2 }
    },

    -- Washy semi-open hi-hat, rimshots, crash on the first bar.
    chorus = {
        phrase = 4,
        pulse = { voice = "semi_open_hat", every = 2, velocity = 92, accent = 108 },
        kick = {
            positions = {0, 8}, velocity = 118,
            options = { {10, 0.6, 100}, {6, 0.3, 98}, {14, 0.2, 96} }
        },
        snare = { positions = {4, 12}, velocity = 120, rimshot = 0.5 },
        opening = { voice = "crash", velocity = 124 }
    },

    -- Ride with a few bell hits.
    solo = {
        phrase = 4,
        pulse = { voice = "ride", every = 2, velocity = 84, accent = 100 },
        kick = {
            positions = {0, 8}, velocity = 114,
            options = { {10, 0.5, 96}, {6, 0.3, 94}, {14, 0.2, 92} }
        },
        snare = { positions = {4, 12}, velocity = 116 },
        ghosts = { positions = {7, 15}, chance = 0.3, velocity = 34, max = 1 },
        extras = {
            { voice = "ride_bell", position = 2, chance = 0.4, velocity = 96 },
            { voice = "ride_bell", position = 10, chance = 0.4, velocity = 96 }
        },
        opening = { voice = "crash", velocity = 122 }
    },

    -- Crash on every beat, full rimshots.
    outro = {
        phrase = 2,
        pulse = { voice = "crash", every = 4, velocity = 112, accent = 116 },
        kick = { positions = {0, 8}, velocity = 120, options = { {10, 0.6, 104}, {14, 0.3, 100} } },
        snare = { positions = {4, 12}, velocity = 122, rimshot = 1 },
        opening = { voice = "crash", velocity = 127 }
    }

}

return Drums
