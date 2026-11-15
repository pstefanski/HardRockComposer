local PatternBuilder = require("PatternBuilder")

--------------------------------------------------
-- Classic Rock drum patterns (4/4, light shuffle from SongSettings.swing).
--------------------------------------------------

local Drums = {}

local D = PatternBuilder.Drums
local Add = PatternBuilder.Add
local AddAt = PatternBuilder.AddAt
local AddEvery = PatternBuilder.AddEvery
local AddBackbeat = PatternBuilder.AddBackbeat

local Pattern = PatternBuilder.Collector(Drums)

local function EighthHats(notes, accent, normal)
    AddEvery(notes, D.closed_hat, 0, 14, 2, accent, normal, 4)
end

do
    local notes = {}
    EighthHats(notes, 90, 70)
    AddAt(notes, D.kick, {0, 8}, 100)
    Pattern("cr_intro", "Intro Hats", notes)
end

do
    local notes = {}
    EighthHats(notes, 96, 76)
    AddAt(notes, D.kick, {0, 8, 10}, 110)
    AddBackbeat(notes, 112)
    Pattern("cr_verse", "Verse Groove", notes)
end

do
    local notes = {}
    EighthHats(notes, 96, 76)
    AddAt(notes, D.kick, {0, 6, 8, 10}, 108)
    AddBackbeat(notes, 112, 48)
    Pattern("cr_verse_alt", "Verse Groove Alt", notes)
end

do
    local notes = {}
    Add(notes, D.crash, 0, 122, 1)
    AddEvery(notes, D.ride, 2, 14, 2, 98, 84, 4)
    AddAt(notes, D.kick, {0, 8, 10}, 116)
    AddBackbeat(notes, 118)
    Pattern("cr_chorus_crash", "Chorus Crash", notes)
end

do
    local notes = {}
    AddEvery(notes, D.ride, 0, 14, 2, 98, 84, 4)
    AddAt(notes, D.kick, {0, 8, 10}, 116)
    AddBackbeat(notes, 118)
    Pattern("cr_chorus", "Chorus Ride", notes)
end

do
    -- Half-time feel: snare on beat 3 only.
    local notes = {}
    AddEvery(notes, D.ride, 0, 12, 4, 92)
    AddAt(notes, D.kick, {0, 6}, 104)
    Add(notes, D.snare, 8, 110)
    Pattern("cr_bridge", "Bridge Half-Time", notes)
end

do
    local notes = {}
    AddEvery(notes, D.ride, 0, 14, 2, 100, 86, 4)
    AddAt(notes, D.kick, {0, 6, 8, 10}, 114)
    AddBackbeat(notes, 116, 50)
    Pattern("cr_solo", "Solo Ride", notes)
end

do
    -- Final hit, then let it ring.
    local notes = {}
    Add(notes, D.crash, 0, 127, 4)
    Add(notes, D.kick, 0, 124)
    Add(notes, D.floor_tom, 0, 116)
    Pattern("cr_ending", "Ending Hit", notes)
end

Pattern("cr_rest", "Rest", {})

Pattern("cr_fill_snare", "Snare Pickup", {
    PatternBuilder.Note(D.snare, 12, 96),
    PatternBuilder.Note(D.snare, 14, 108),
    PatternBuilder.Note(D.snare, 15, 116)
}, 1)

Pattern("cr_fill_toms", "Two Beat Tom Fill", {
    PatternBuilder.Note(D.snare, 8, 104),
    PatternBuilder.Note(D.snare, 10, 108),
    PatternBuilder.Note(D.high_tom, 12, 110),
    PatternBuilder.Note(D.mid_tom, 13, 112),
    PatternBuilder.Note(D.low_tom, 14, 118),
    PatternBuilder.Note(D.floor_tom, 15, 122)
}, 2)

return Drums
