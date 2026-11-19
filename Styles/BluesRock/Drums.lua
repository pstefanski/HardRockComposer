local PatternBuilder = require("PatternBuilder")

--------------------------------------------------
-- Blues Rock drum patterns (12/8 shuffle).
--
-- A 12/8 bar spans sixteenth positions 0 to 23:
--   beats (dotted quarters)   0, 6, 12, 18
--   eighth-note triplets      every 2 positions
--   shuffle (1st + 3rd note)  0, 4, 6, 10, 12, 16, 18, 22
--------------------------------------------------

local Drums = {}

local D = PatternBuilder.Drums
local Add = PatternBuilder.Add
local AddAt = PatternBuilder.AddAt
local AddEvery = PatternBuilder.AddEvery
local Note = PatternBuilder.Note

local Pattern = PatternBuilder.Collector(Drums)

local SHUFFLE = {0, 4, 6, 10, 12, 16, 18, 22}

local function Shuffle(notes, pitch, accent, normal)
    for _, position in ipairs(SHUFFLE) do
        Add(notes, pitch, position, position % 6 == 0 and accent or normal)
    end
end

local function Backbeat(notes, pitch, velocity)
    AddAt(notes, pitch, {6, 18}, velocity)
end

do
    local notes = {}
    Shuffle(notes, D.closed_hat, 86, 66)
    Backbeat(notes, D.side_stick, 96)
    AddAt(notes, D.kick, {0, 12}, 96)
    Pattern("bl_intro", "Intro Side Stick", notes)
end

do
    local notes = {}
    Shuffle(notes, D.closed_hat, 94, 72)
    Backbeat(notes, D.snare, 112)
    AddAt(notes, D.kick, {0, 10, 12}, 108)
    Pattern("bl_verse", "Verse Shuffle", notes)
end

do
    local notes = {}
    Shuffle(notes, D.closed_hat, 94, 72)
    Backbeat(notes, D.snare, 112)
    Add(notes, D.snare, 16, 46)
    AddAt(notes, D.kick, {0, 10, 12, 22}, 106)
    Pattern("bl_verse_alt", "Verse Shuffle Alt", notes)
end

do
    local notes = {}
    Add(notes, D.crash, 0, 122, 1)
    Shuffle(notes, D.ride, 100, 84)
    Backbeat(notes, D.snare, 118)
    AddAt(notes, D.kick, {0, 10, 12}, 116)
    Pattern("bl_chorus_crash", "Chorus Crash", notes)
end

do
    local notes = {}
    Shuffle(notes, D.ride, 100, 84)
    Backbeat(notes, D.snare, 118)
    AddAt(notes, D.kick, {0, 10, 12}, 116)
    Pattern("bl_chorus", "Chorus Ride Shuffle", notes)
end

do
    -- Every triplet on the ride, accents on the beats.
    local notes = {}
    AddEvery(notes, D.ride, 0, 22, 2, 102, 80, 6)
    Backbeat(notes, D.snare, 116)
    AddAt(notes, D.kick, {0, 12}, 114)
    Pattern("bl_solo", "Solo Triplets", notes)
end

do
    -- Stop time: one hit on the downbeat, the band answers in the gaps.
    local notes = {}
    Add(notes, D.crash, 0, 120, 2)
    Add(notes, D.kick, 0, 118)
    Add(notes, D.snare, 0, 112)
    AddAt(notes, D.closed_hat, {6, 12, 18}, 70)
    Pattern("bl_stop_time", "Stop Time", notes)
end

do
    local notes = {}
    Add(notes, D.crash, 0, 127, 6)
    Add(notes, D.kick, 0, 124)
    Add(notes, D.floor_tom, 0, 116)
    Pattern("bl_ending", "Ending Hit", notes)
end

Pattern("bl_rest", "Rest", {})

-- One dotted-quarter beat (1.5 quarter notes): snare triplet into the next bar.
Pattern("bl_fill_triplet", "Triplet Pickup", {
    Note(D.snare, 18, 100),
    Note(D.snare, 20, 108),
    Note(D.snare, 22, 118)
}, 1.5)

-- Two dotted-quarter beats (3 quarter notes): triplets down the toms.
Pattern("bl_fill_toms", "Triplet Tom Fill", {
    Note(D.snare, 12, 104),
    Note(D.snare, 14, 108),
    Note(D.high_tom, 16, 110),
    Note(D.mid_tom, 18, 114),
    Note(D.low_tom, 20, 118),
    Note(D.floor_tom, 22, 122)
}, 3)

--------------------------------------------------
-- Generated grooves (see Core/DrumGroove.lua). The patterns above stay
-- available for sections that name them.
--------------------------------------------------

Drums.grooves = {

    intro = {
        phrase = 2,
        pulse = { voice = "closed_hat", positions = SHUFFLE, velocity = 66, accent = 86 },
        kick = { positions = {0, 12}, velocity = 96 },
        snare = { voice = "side_stick", positions = {6, 18}, velocity = 96 }
    },

    verse = {
        phrase = 4,
        pulse = {
            voice = "closed_hat", positions = SHUFFLE, velocity = 72, accent = 94,
            open = { voice = "open_hat", positions = {22}, chance = 0.3, velocity = 88 }
        },
        kick = {
            positions = {0, 12}, velocity = 108,
            options = { {10, 0.6, 100}, {22, 0.3, 96}, {16, 0.2, 92} }
        },
        snare = { positions = {6, 18}, velocity = 112 },
        ghosts = { positions = {16, 4, 10}, chance = 0.4, velocity = 44, max = 2 }
    },

    chorus = {
        phrase = 4,
        pulse = { voice = "ride", positions = SHUFFLE, velocity = 84, accent = 100 },
        kick = { positions = {0, 12}, velocity = 116, options = { {10, 0.7, 108}, {22, 0.3, 104} } },
        snare = { positions = {6, 18}, velocity = 118, rimshot = 0.3 },
        ghosts = { positions = {16, 4}, chance = 0.3, velocity = 46, max = 1 },
        opening = { voice = "crash", velocity = 122 }
    },

    -- Every triplet on the ride.
    solo = {
        phrase = 4,
        pulse = { voice = "ride", every = 2, velocity = 80, accent = 102 },
        kick = { positions = {0, 12}, velocity = 114, options = { {10, 0.5, 104}, {4, 0.3, 100} } },
        snare = { positions = {6, 18}, velocity = 116 },
        ghosts = { positions = {16, 22, 10}, chance = 0.4, velocity = 46, max = 2 },
        opening = { voice = "crash", velocity = 120 }
    }

}

-- Generated fills (see Core/DrumFill.lua): triplet fills replace the
-- fills above, which sections can still force with `fill`.
Drums.fills = {
    toms = { "high_tom", "low_tom", "floor_tom" },
    velocity = { from = 84, to = 116 },
    kick = 96,
    pickup = 0.4,
    phrase = 0.5
}

return Drums
