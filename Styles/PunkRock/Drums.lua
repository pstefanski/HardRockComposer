local PatternBuilder = require("PatternBuilder")

--------------------------------------------------
-- Punk Rock drum patterns (4/4, fast, straight eighths).
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

-- "Skank" beat: kick on every beat, snare on every off-beat eighth.
local function Skank(notes, kick, snare)
    AddEvery(notes, D.kick, 0, 12, 4, kick)
    AddEvery(notes, D.snare, 2, 14, 4, snare)
end

do
    local notes = {}
    AddEvery(notes, D.floor_tom, 0, 14, 2, 116, 104, 4)
    AddEvery(notes, D.kick, 0, 12, 4, 116)
    Pattern("pk_intro", "Intro Floor Tom Drive", notes)
end

do
    local notes = {}
    AddEvery(notes, D.closed_hat, 0, 14, 2, 106, 90, 4)
    AddAt(notes, D.kick, {0, 8, 10}, 118)
    AddBackbeat(notes, 122)
    Pattern("pk_verse", "Verse Eighth Drive", notes)
end

do
    local notes = {}
    AddEvery(notes, D.closed_hat, 0, 14, 2, 106, 90, 4)
    AddAt(notes, D.kick, {0, 6, 8, 10}, 118)
    AddBackbeat(notes, 122)
    Pattern("pk_verse_alt", "Verse Eighth Drive Alt", notes)
end

do
    local notes = {}
    Add(notes, D.crash, 0, 127, 1)
    Skank(notes, 120, 116)
    AddCrashQuarters(notes, 114, 4)
    Pattern("pk_chorus_crash", "Chorus Crash", notes)
end

do
    local notes = {}
    Skank(notes, 120, 116)
    AddCrashQuarters(notes, 114)
    Pattern("pk_chorus", "Chorus Skank", notes)
end

do
    local notes = {}
    AddEvery(notes, D.floor_tom, 0, 14, 2, 110, 96, 4)
    AddAt(notes, D.kick, {0, 8}, 114)
    AddBackbeat(notes, 118)
    Pattern("pk_bridge", "Bridge Floor Tom", notes)
end

do
    local notes = {}
    Add(notes, D.crash, 0, 127, 4)
    Add(notes, D.kick, 0, 124)
    Add(notes, D.snare, 0, 120)
    Pattern("pk_ending", "Ending Hit", notes)
end

Pattern("pk_fill_snare", "Snare Sixteenths", {
    Note(D.snare, 12, 104),
    Note(D.snare, 13, 108),
    Note(D.snare, 14, 116),
    Note(D.snare, 15, 122)
}, 1)

-- Used by `transition = "big"` sections.
Pattern("fill_big", "Snare and Toms", {
    Note(D.snare, 8, 108),
    Note(D.snare, 9, 104),
    Note(D.snare, 10, 112),
    Note(D.snare, 11, 108),
    Note(D.high_tom, 12, 116),
    Note(D.mid_tom, 13, 116),
    Note(D.floor_tom, 14, 124),
    Note(D.floor_tom, 15, 124)
}, 2)

--------------------------------------------------
-- Generated grooves (see Core/DrumGroove.lua). The patterns above stay
-- available for sections that name them.
--------------------------------------------------

Drums.grooves = {

    intro = {
        phrase = 2,
        pulse = { voice = "floor_tom", every = 2, velocity = 104, accent = 116 },
        kick = { every = 4, velocity = 116 }
    },

    verse = {
        phrase = 4,
        pulse = {
            voice = "closed_hat", every = 2, velocity = 90, accent = 106,
            open = { voice = "open_hat", positions = {14}, chance = 0.3, velocity = 100 }
        },
        kick = { positions = {0, 8}, velocity = 118, options = { {10, 0.6}, {6, 0.35, 112} } },
        snare = { positions = {4, 12}, velocity = 122 }
    },

    -- "Skank" beat: kick on every beat, snare on every off-beat eighth.
    chorus = {
        phrase = 2,
        pulse = { voice = "crash", every = 4, velocity = 114 },
        kick = { every = 4, velocity = 120 },
        snare = { positions = {2, 6, 10, 14}, velocity = 116 },
        opening = { voice = "crash", velocity = 127 }
    },

    bridge = {
        phrase = 4,
        pulse = { voice = "floor_tom", every = 2, velocity = 96, accent = 110 },
        kick = { positions = {0, 8}, velocity = 114, options = { {6, 0.3, 106}, {14, 0.3, 106} } },
        snare = { positions = {4, 12}, velocity = 118 }
    }

}

return Drums
