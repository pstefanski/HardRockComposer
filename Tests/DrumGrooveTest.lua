local Test = require("Test")
local DrumGroove = require("DrumGroove")
local DrumKit = require("DrumKit")
local Arrangement = require("Arrangement")
local Validator = require("Validator")

local K = DrumKit.notes

local SETTINGS = {
    beats_per_bar = 4,
    beat_unit = 4
}

local function Groove()
    return {
        phrase = 4,
        pulse = {
            voice = "closed_hat",
            every = 2,
            velocity = 84,
            accent = 104,
            open = {
                voice = "open_hat",
                positions = {14},
                chance = 0.5,
                velocity = 98
            }
        },
        kick = {
            positions = {0, 8},
            velocity = 112,
            options = {{10, 0.5}, {6, 0.3, 96}, {14, 0.2}}
        },
        snare = {
            positions = {4, 12},
            velocity = 114
        },
        ghosts = {
            positions = {7, 15, 3, 10},
            chance = 0.5,
            velocity = 36,
            max = 2
        },
        opening = {
            voice = "crash",
            velocity = 122
        }
    }
end

local function Signature(pattern)
    local parts = {}
    for _, note in ipairs(pattern.notes) do
        table.insert(parts, note.position .. ":" .. note.pitch .. ":" .. note.velocity)
    end
    return table.concat(parts, " ")
end

local function PhraseSignature(phrase)
    local bars = {}
    for _, bar in ipairs(phrase.bars) do
        table.insert(bars, Signature(bar))
    end
    return table.concat(bars, " | ")
end

local function NotesAt(pattern, position)
    local pitches = {}
    for _, note in ipairs(pattern.notes) do
        if note.position == position then
            pitches[note.pitch] = note
        end
    end
    return pitches
end

Test.Case("DrumGroove: the same seed gives the same phrase", function()
    local a = DrumGroove.Phrase("verse", Groove(), 7, SETTINGS)
    local b = DrumGroove.Phrase("verse", Groove(), 7, SETTINGS)
    Test.Equal(PhraseSignature(a), PhraseSignature(b))
end)

Test.Case("DrumGroove: the drum seed and the groove name change the phrase", function()
    local seen = {}
    local count = 0
    for seed = 1, 8 do
        local signature = PhraseSignature(DrumGroove.Phrase("verse", Groove(), seed, SETTINGS))
        if not seen[signature] then
            seen[signature] = true
            count = count + 1
        end
    end
    Test.True(count >= 4, "only " .. count .. " different phrases for 8 seeds")

    local verse = PhraseSignature(DrumGroove.Phrase("verse", Groove(), 1, SETTINGS))
    local chorus = PhraseSignature(DrumGroove.Phrase("chorus", Groove(), 1, SETTINGS))
    Test.True(verse ~= chorus, "another groove name draws another phrase")
end)

Test.Case("DrumGroove: a four-bar phrase repeats its first bar and keeps the fixed hits", function()
    for seed = 1, 20 do
        local phrase = DrumGroove.Phrase("verse", Groove(), seed, SETTINGS)
        Test.Equal(#phrase.bars, 4)
        Test.Equal(Signature(phrase.bars[3]), Signature(phrase.bars[1]), "bar 3 repeats bar 1")
        for index, bar in ipairs(phrase.bars) do
            local where = "seed " .. seed .. " bar " .. index
            Test.True(NotesAt(bar, 0)[K.kick] and NotesAt(bar, 8)[K.kick], where .. ": kicks on 1 and 3")
            Test.True(NotesAt(bar, 4)[K.snare] and NotesAt(bar, 12)[K.snare], where .. ": backbeat")
            for _, note in ipairs(bar.notes) do
                Test.True(note.position >= 0 and note.position < 16, where .. ": note inside the bar")
                Test.True(note.velocity >= 1 and note.velocity <= 127, where .. ": valid velocity")
            end
        end
    end
end)

Test.Case("DrumGroove: the end of the phrase never falls back on its first bar", function()
    local groove = Groove()
    groove.pulse.open = nil
    groove.ghosts = nil
    for seed = 1, 50 do
        local phrase = DrumGroove.Phrase("verse", groove, seed, SETTINGS)
        Test.True(Signature(phrase.bars[4]) ~= Signature(phrase.bars[1]), "seed " .. seed)
        Test.True(Signature(phrase.bars[2]) ~= Signature(phrase.bars[1]), "seed " .. seed)
    end
end)

Test.Case("DrumGroove: the hi-hat opens at the end of the phrase", function()
    for seed = 1, 10 do
        local last = DrumGroove.Phrase("verse", Groove(), seed, SETTINGS).bars[4]
        local notes = NotesAt(last, 14)
        Test.True(notes[K.open_hat] ~= nil, "open hi-hat on the last eighth")
        Test.Equal(notes[K.closed_hat], nil, "the open hi-hat replaces the closed one")
    end
    local first = DrumGroove.Phrase("verse", Groove(), 1, SETTINGS).bars[1]
    Test.Equal(NotesAt(first, 14)[K.open_hat], nil, "the first bar stays closed")
end)

Test.Case("DrumGroove: accents fall on the beats", function()
    local bar = DrumGroove.Phrase("verse", Groove(), 1, SETTINGS).bars[1]
    Test.Equal(NotesAt(bar, 0)[K.closed_hat].velocity, 104)
    Test.Equal(NotesAt(bar, 2)[K.closed_hat].velocity, 84)
end)

Test.Case("DrumGroove: ghost notes stay off the backbeat and within their maximum", function()
    for seed = 1, 20 do
        local bar = DrumGroove.Phrase("verse", Groove(), seed, SETTINGS).bars[1]
        local ghosts = 0
        for _, note in ipairs(bar.notes) do
            if note.pitch == K.snare and note.velocity == 36 then
                ghosts = ghosts + 1
                Test.True(note.position ~= 4 and note.position ~= 12, "ghost on the backbeat")
            end
        end
        Test.True(ghosts <= 2, "seed " .. seed .. ": " .. ghosts .. " ghost notes")
    end
end)

Test.Case("DrumGroove: the opening bar starts with a crash instead of the hi-hat", function()
    local phrase = DrumGroove.Phrase("verse", Groove(), 1, SETTINGS)
    local notes = NotesAt(phrase.opening, 0)
    Test.Equal(notes[K.crash].velocity, 122)
    Test.Equal(notes[K.crash].length, 1, "a crash rings")
    Test.Equal(notes[K.closed_hat], nil)
    Test.True(notes[K.kick] ~= nil)
    Test.Equal(DrumGroove.BarPattern(phrase, 1), phrase.opening)
    Test.Equal(DrumGroove.BarPattern(phrase, 5), phrase.bars[1])
    Test.Equal(DrumGroove.BarPattern(phrase, 8), phrase.bars[4])
end)

Test.Case("DrumGroove: rimshot chance 1 plays rimshots on the backbeat", function()
    local groove = Groove()
    groove.snare.rimshot = 1
    local bar = DrumGroove.Phrase("verse", groove, 1, SETTINGS).bars[1]
    Test.True(NotesAt(bar, 4)[K.snare_rimshot] ~= nil)
    Test.Equal(NotesAt(bar, 4)[K.snare], nil)
end)

Test.Case("DrumGroove: 12/8 grooves use the dotted-quarter beats", function()
    local groove = {
        phrase = 2,
        pulse = {
            voice = "ride",
            positions = {0, 4, 6, 10, 12, 16, 18, 22},
            velocity = 80,
            accent = 100
        },
        snare = {
            positions = {6, 18},
            velocity = 110
        }
    }
    local phrase = DrumGroove.Phrase("shuffle", groove, 1, {
        beats_per_bar = 12,
        beat_unit = 8
    })
    Test.Equal(#phrase.bars, 2)
    Test.Equal(NotesAt(phrase.bars[1], 6)[K.ride].velocity, 100)
    Test.Equal(NotesAt(phrase.bars[1], 10)[K.ride].velocity, 80)
end)

Test.Case("DrumGroove: sections using the same groove share its phrase", function()
    local context = {
        registry = {
            patterns = {}
        }
    }
    DrumGroove.Apply({
        verse = Groove()
    }, context, {
        beats_per_bar = 4,
        beat_unit = 4,
        drum_seed = 3
    })
    local section = {
        bars = 8,
        patterns = {
            drums = {
                groove = "verse"
            }
        }
    }
    local plan1 = Arrangement.DrumPlan(section, nil, context.registry, 4)
    local plan2 = Arrangement.DrumPlan(section, nil, context.registry, 4)
    Test.Equal(#plan1, 8)
    for index = 1, 8 do
        Test.Equal(plan1[index].pattern, plan2[index].pattern)
    end
    Test.Equal(plan1[1].pattern, context.registry.grooves.verse.opening)
    Test.Equal(plan1[2].pattern, context.registry.grooves.verse.bars[2])
    Test.Equal(plan1[8].pattern, context.registry.grooves.verse.bars[4])
end)

Test.Case("DrumGroove: a fill takes the end of the last bar of a groove section", function()
    local context = {
        registry = {
            patterns = {
                fill = {
                    id = "fill",
                    bars = 1,
                    transitionBeats = 1,
                    notes = {}
                }
            }
        }
    }
    DrumGroove.Apply({
        verse = Groove()
    }, context, SETTINGS)
    local plan = Arrangement.DrumPlan({
        bars = 4,
        fill = "fill",
        patterns = {
            drums = {
                groove = "verse"
            }
        }
    }, nil, context.registry, 4)
    Test.Equal(#plan, 5)
    Test.Equal(plan[4].pattern, context.registry.grooves.verse.bars[4])
    Test.Equal(plan[4].toQN, 3)
    Test.Equal(plan[5].pattern.id, "fill")
end)

--------------------------------------------------
-- Validation
--------------------------------------------------

local function Errors(grooves, drums, settings)
    local DrumPatterns = {}
    return Validator.Validate({
        layout = {{
            id = "drums",
            name = "Drums",
            tracks = {{
                id = "ezd_midi",
                name = "EZD MIDI"
            }}
        }},
        structure = {{
            id = "verse",
            name = "Verse",
            bars = 4,
            patterns = {
                drums = drums or {
                    groove = "verse"
                }
            }
        }},
        patternSets = {DrumPatterns},
        grooves = grooves,
        settings = settings or {
            tempo = 120,
            beats_per_bar = 4,
            beat_unit = 4
        },
        palette = {}
    })
end

Test.Case("DrumGroove: the validator accepts a complete groove", function()
    local errors = Errors({
        verse = Groove()
    })
    Test.Equal(#errors, 0, table.concat(errors, "\n"))
end)

Test.Case("DrumGroove: the validator reports wrong voices, positions, chances and velocities", function()
    local groove = Groove()
    groove.phrase = 3
    groove.pulse.voice = "cowbell"
    groove.kick.options[1] = {16, 0.5}
    groove.ghosts.chance = 2
    groove.snare.velocity = 200
    local errors = Errors({
        verse = groove
    })
    Test.Contains(errors, "groove 'verse': phrase must be 1, 2 or 4 bars")
    Test.Contains(errors, "groove 'verse' pulse: unknown drum voice 'cowbell'")
    Test.Contains(errors, "groove 'verse' kick option #1: position 16 is outside the bar (0 to 15)")
    Test.Contains(errors, "groove 'verse' ghosts: chance must be between 0 and 1")
    Test.Contains(errors, "groove 'verse' snare: velocity must be an integer between 1 and 127")
end)

Test.Case("DrumGroove: the validator checks the groove references and the feel", function()
    Test.Contains(Errors({}), "section 'verse': unknown drum groove 'verse'")
    Test.Contains(Errors({
        verse = Groove()
    }, {
        groove = "verse",
        primary = "x"
    }), "drums.groove cannot be combined with primary, variation or opening")
    local errors = Errors({
        verse = Groove()
    }, nil, {
        tempo = 120,
        beats_per_bar = 4,
        beat_unit = 4,
        drum_seed = 1.5,
        humanization = {
            enabled = true,
            seed = 1,
            velocity = 4,
            timing = 4,
            feel = {
                snare = 6,
                cowbell = 2
            }
        }
    })
    Test.Contains(errors, "drum_seed must be an integer")
    Test.Contains(errors, "humanization.feel: unknown part of the kit 'cowbell'")
end)
