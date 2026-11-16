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

return Drums
