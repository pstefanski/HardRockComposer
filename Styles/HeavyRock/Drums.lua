local PatternBuilder = require("PatternBuilder")

--------------------------------------------------
-- Heavy Rock drum patterns (4/4, straight, double kick).
--------------------------------------------------

local Drums = {}

local D = PatternBuilder.Drums
local Add = PatternBuilder.Add
local AddAt = PatternBuilder.AddAt
local AddEvery = PatternBuilder.AddEvery
local AddBackbeat = PatternBuilder.AddBackbeat
local AddCrashQuarters = PatternBuilder.AddCrashQuarters
local Note = PatternBuilder.Note

local Pattern = PatternBuilder.Collector(Drums)

-- Sixteenth-note double kick, accented on the beats.
local function DoubleKick(notes, accent, normal)
    AddEvery(notes, D.kick, 0, 15, 1, accent, normal, 4)
end

local function FloorTomEighths(notes, accent, normal)
    AddEvery(notes, D.floor_tom, 0, 14, 2, accent, normal, 4)
end

do
    local notes = {}
    Add(notes, D.crash, 0, 124, 1)
    FloorTomEighths(notes, 114, 100)
    AddAt(notes, D.kick, {0, 8}, 118)
    AddBackbeat(notes, 118)
    Pattern("hv_intro_crash", "Intro Crash", notes)
end

do
    local notes = {}
    FloorTomEighths(notes, 114, 100)
    AddAt(notes, D.kick, {0, 8}, 118)
    AddBackbeat(notes, 118)
    Pattern("hv_intro_toms", "Intro Floor Tom", notes)
end

do
    local notes = {}
    AddEvery(notes, D.closed_hat, 0, 14, 2, 100, 84, 4)
    AddAt(notes, D.kick, {0, 3, 8, 10}, 116)
    AddBackbeat(notes, 120)
    Pattern("hv_verse", "Verse Gallop", notes)
end

do
    local notes = {}
    AddEvery(notes, D.closed_hat, 0, 14, 2, 100, 84, 4)
    AddAt(notes, D.kick, {0, 2, 3, 8, 10, 11}, 116)
    AddBackbeat(notes, 120)
    Pattern("hv_verse_alt", "Verse Gallop Alt", notes)
end

do
    local notes = {}
    Add(notes, D.crash, 0, 127, 1)
    DoubleKick(notes, 120, 104)
    AddBackbeat(notes, 124)
    AddCrashQuarters(notes, 116, 4)
    Pattern("hv_chorus_crash", "Chorus Crash", notes)
end

do
    local notes = {}
    DoubleKick(notes, 120, 104)
    AddBackbeat(notes, 124)
    AddCrashQuarters(notes, 116)
    Pattern("hv_chorus", "Chorus Double Kick", notes)
end

do
    -- Half-time: snare on beat 3, syncopated double kick bursts.
    local notes = {}
    AddAt(notes, D.crash, {0, 8}, 120, 1)
    AddAt(notes, D.kick, {0, 1, 2, 3, 6, 7, 10, 11, 14, 15}, 118)
    Add(notes, D.snare, 8, 126)
    Pattern("hv_breakdown", "Half-Time Breakdown", notes)
end

do
    local notes = {}
    AddEvery(notes, D.ride, 0, 14, 2, 104, 88, 4)
    AddEvery(notes, D.kick, 0, 14, 2, 116, 104, 4)
    AddBackbeat(notes, 120)
    Pattern("hv_solo", "Solo Eighth Kicks", notes)
end

do
    local notes = {}
    DoubleKick(notes, 122, 106)
    AddBackbeat(notes, 124)
    AddCrashQuarters(notes, 120)
    Pattern("hv_outro", "Outro Double Kick", notes)
end

Pattern("hv_fill_toms", "Sixteenth Tom Fill", {
    Note(D.high_tom, 8, 108),
    Note(D.high_tom, 9, 104),
    Note(D.mid_tom, 10, 112),
    Note(D.mid_tom, 11, 108),
    Note(D.low_tom, 12, 116),
    Note(D.low_tom, 13, 112),
    Note(D.floor_tom, 14, 122),
    Note(D.floor_tom, 15, 118)
}, 2)

-- Used by `transition = "big"` sections.
Pattern("fill_big", "Big Fill", {
    Note(D.snare, 12, 116),
    Note(D.snare, 13, 112),
    Note(D.floor_tom, 14, 124),
    Note(D.kick, 14, 120),
    Note(D.floor_tom, 15, 124),
    Note(D.kick, 15, 120)
}, 1)

--------------------------------------------------
-- Generated grooves (see Core/DrumGroove.lua). The patterns above stay
-- available for sections that name them.
--------------------------------------------------

Drums.grooves = {

    intro = {
        phrase = 4,
        pulse = { voice = "floor_tom", every = 2, velocity = 100, accent = 114 },
        kick = { positions = {0, 8}, velocity = 118, options = { {3, 0.4, 110}, {10, 0.5, 112} } },
        snare = { positions = {4, 12}, velocity = 118 },
        opening = { voice = "crash", velocity = 124 }
    },

    -- Gallop kicks under eighth notes on the hi-hat.
    verse = {
        phrase = 4,
        pulse = {
            voice = "closed_hat", every = 2, velocity = 84, accent = 100,
            open = { voice = "open_hat", positions = {14}, chance = 0.3, velocity = 96 }
        },
        kick = {
            positions = {0, 8}, velocity = 116,
            options = { {3, 0.8}, {10, 0.7}, {2, 0.4, 108}, {11, 0.4, 108} }
        },
        snare = { positions = {4, 12}, velocity = 120, rimshot = 0.3 }
    },

    -- Sixteenth-note double kick, crash on every beat, china answers.
    chorus = {
        phrase = 2,
        pulse = { voice = "crash", every = 4, velocity = 116 },
        kick = { every = 1, velocity = 104, accent = 120 },
        snare = { positions = {4, 12}, velocity = 124, rimshot = 0.7 },
        extras = {
            { voice = "china", position = 14, chance = 0.4, velocity = 108 }
        },
        opening = { voice = "crash", velocity = 127 }
    },

    solo = {
        phrase = 4,
        pulse = { voice = "ride", every = 2, velocity = 88, accent = 104 },
        kick = { every = 2, velocity = 104, accent = 116 },
        snare = { positions = {4, 12}, velocity = 120 },
        extras = {
            { voice = "ride_bell", position = 6, chance = 0.4, velocity = 100 },
            { voice = "ride_bell", position = 14, chance = 0.4, velocity = 100 }
        },
        opening = { voice = "crash", velocity = 122 }
    },

    outro = {
        phrase = 2,
        pulse = { voice = "crash", every = 4, velocity = 120 },
        kick = { every = 1, velocity = 106, accent = 122 },
        snare = { positions = {4, 12}, velocity = 124, rimshot = 1 },
        extras = {
            { voice = "china", position = 12, chance = 0.5, velocity = 112 }
        },
        opening = { voice = "crash", velocity = 127 }
    }

}

return Drums
