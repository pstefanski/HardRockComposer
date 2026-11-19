local Test = require("Test")
local DrumFill = require("DrumFill")
local DrumGroove = require("DrumGroove")
local DrumKit = require("DrumKit")
local Arrangement = require("Arrangement")
local Validator = require("Validator")

local K = DrumKit.notes

local STRAIGHT = DrumFill.Timing({
    beats_per_bar = 4,
    beat_unit = 4
})

local TRIPLET = DrumFill.Timing({
    beats_per_bar = 12,
    beat_unit = 8
})

local function Signature(pattern)
    local parts = {}
    for _, note in ipairs(pattern.notes) do
        table.insert(parts, note.position .. ":" .. note.pitch .. ":" .. note.velocity)
    end
    return table.concat(parts, " ")
end

local function Group(note)
    return DrumKit.groups[DrumKit.NameOf(note.pitch)]
end

Test.Case("DrumFill: the same seed draws the same fill, other seeds other fills", function()
    local rules = DrumFill.Rules(nil)
    local a = DrumFill.Fill(rules, STRAIGHT, DrumFill.Generator(1, "verse", 8), 2)
    local b = DrumFill.Fill(rules, STRAIGHT, DrumFill.Generator(1, "verse", 8), 2)
    Test.Equal(Signature(a), Signature(b))

    local seen, count = {}, 0
    for seed = 1, 10 do
        local signature = Signature(DrumFill.Fill(rules, STRAIGHT, DrumFill.Generator(seed, "verse", 8), 2))
        if not seen[signature] then
            seen[signature] = true
            count = count + 1
        end
    end
    Test.True(count >= 5, "only " .. count .. " different fills for 10 seeds")
end)

Test.Case("DrumFill: a fill stays in its last beats, with the kick on every beat and no cymbal", function()
    local rules = DrumFill.Rules(nil)
    for seed = 1, 30 do
        for beats = 1, 4 do
            local fill = DrumFill.Fill(rules, STRAIGHT, DrumFill.Generator(seed, "s", beats), beats)
            local start = 16 - beats * 4
            local where = "seed " .. seed .. ", " .. beats .. " beat(s)"
            Test.Equal(fill.transitionBeats, beats, where)
            local kicks = {}
            for _, note in ipairs(fill.notes) do
                Test.True(note.position >= start - 0.25 and note.position < 16, where .. ": note inside the fill")
                Test.True(note.velocity >= 1 and note.velocity <= 127, where .. ": valid velocity")
                Test.True(Group(note) ~= "hats" and Group(note) ~= "cymbals", where .. ": no cymbal in a fill")
                if note.pitch == K.kick then
                    kicks[note.position] = true
                end
            end
            for beat = 0, beats - 1 do
                Test.True(kicks[start + beat * 4], where .. ": kick on beat " .. beat + 1)
            end
        end
    end
end)

Test.Case("DrumFill: the toms come down to the lowest one and the fill grows louder", function()
    local rules = DrumFill.Rules({
        cells = {"toms"}
    })
    local fill = DrumFill.Fill(rules, STRAIGHT, DrumFill.Generator(3, "s", 4), 2)
    local order = {
        [K.high_tom] = 1,
        [K.mid_tom] = 2,
        [K.low_tom] = 3,
        [K.floor_tom] = 4
    }
    local last, previous = nil, 0
    local first, final
    for _, note in ipairs(fill.notes) do
        if order[note.pitch] then
            Test.True(order[note.pitch] >= previous, "the toms only go down")
            previous = order[note.pitch]
            last = note
            first = first or note
            final = note
        end
    end
    Test.Equal(last.pitch, K.floor_tom)
    Test.True(final.velocity > first.velocity, "crescendo")
end)

Test.Case("DrumFill: in 12/8 the fills use the triplet grid", function()
    local rules = DrumFill.Rules({
        cells = {"snare", "toms", "kick_snare"}
    })
    for seed = 1, 10 do
        local fill = DrumFill.Fill(rules, TRIPLET, DrumFill.Generator(seed, "s", 4), 2)
        Test.Equal(fill.transitionBeats, 3, "two dotted quarters")
        for _, note in ipairs(fill.notes) do
            Test.True(note.position >= 12 and note.position % 2 == 0, "triplet eighth at " .. note.position)
        end
    end
end)

Test.Case("DrumFill: a pickup is light, short and without kick", function()
    local rules = DrumFill.Rules(nil)
    for seed = 1, 20 do
        local pickup = DrumFill.Fill(rules, STRAIGHT, DrumFill.Generator(seed, "s", 4), 1, {
            pickup = true
        })
        Test.True(pickup.transitionBeats == 1 or pickup.transitionBeats == 0.5)
        Test.True(#pickup.notes > 0)
        for _, note in ipairs(pickup.notes) do
            Test.True(note.position >= 16 - pickup.transitionBeats * 4, "inside the pickup")
            Test.True(note.velocity <= rules.velocity.from + 6, "soft")
            Test.True(note.pitch ~= K.kick or note.position ~= 12, "no kick under a pickup")
        end
    end
end)

Test.Case("DrumFill: a flam grace note swings with its note", function()
    local rules = DrumFill.Rules({
        cells = {"flam"}
    })
    local fill = DrumFill.Fill(rules, STRAIGHT, DrumFill.Generator(1, "s", 1), 1)
    local grace
    for _, note in ipairs(fill.notes) do
        if note.position % 1 ~= 0 then
            grace = note
        end
    end
    Test.True(grace ~= nil, "a grace note")
    Test.Equal(grace.swingPosition, grace.position + 0.2)
end)

Test.Case("DrumFill: a build goes from eighths to sixteenths over the kick", function()
    local rules = DrumFill.Rules(nil)
    local single = DrumFill.Build(rules, STRAIGHT, 1)
    Test.Equal(#single, 1)
    local snares, kicks, previous = {}, 0, 0
    for _, note in ipairs(single[1].notes) do
        if note.pitch == K.snare then
            table.insert(snares, note.position)
            Test.True(note.velocity >= previous, "crescendo")
            previous = note.velocity
        elseif note.pitch == K.kick then
            kicks = kicks + 1
        end
    end
    Test.Equal(table.concat(snares, ","), "0,2,4,6,8,9,10,11,12,13,14,15")
    Test.Equal(kicks, 4)

    local double = DrumFill.Build(rules, STRAIGHT, 2)
    Test.Equal(#double, 2)
    Test.Equal(double[1].transitionBeats, 4, "a build bar is a whole bar")
    Test.True(double[2].notes[#double[2].notes].velocity >= double[1].notes[#double[1].notes].velocity)
end)

Test.Case("DrumFill: an arrival replaces the hi-hat on the first beat with a crash and a kick", function()
    local pattern = {
        id = "p",
        bars = 1,
        notes = {{
            pitch = K.closed_hat,
            position = 0,
            length = 0.25,
            velocity = 100
        }, {
            pitch = K.closed_hat,
            position = 2,
            length = 0.25,
            velocity = 80
        }, {
            pitch = K.snare,
            position = 4,
            length = 0.25,
            velocity = 110
        }}
    }
    local arrival = DrumFill.Arrival(pattern, "crash_1", 122)
    Test.Equal(arrival.id, "p+arrival")
    Test.Equal(#pattern.notes, 3, "the pattern itself is unchanged")
    local at0 = {}
    for _, note in ipairs(arrival.notes) do
        if note.position == 0 then
            at0[note.pitch] = note
        end
    end
    Test.Equal(at0[K.closed_hat], nil)
    Test.Equal(at0[K.crash_1].velocity, 122)
    Test.Equal(at0[K.crash_1].length, 1)
    Test.True(at0[K.kick] ~= nil)
end)

--------------------------------------------------
-- In the drum plan
--------------------------------------------------

local function Groove()
    return {
        phrase = 4,
        pulse = {
            voice = "closed_hat",
            every = 2,
            velocity = 84
        },
        kick = {
            positions = {0, 8},
            velocity = 112
        },
        snare = {
            positions = {4, 12},
            velocity = 114
        }
    }
end

local SETTINGS = {
    beats_per_bar = 4,
    beat_unit = 4,
    drum_seed = 2
}

local function Registry(fills)
    local context = {
        registry = {
            patterns = {
                hand_fill = {
                    id = "hand_fill",
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
    DrumFill.Apply(fills, context, SETTINGS)
    return context.registry
end

local function Section(id, bars, energy, extra)
    local section = {
        id = id,
        bars = bars,
        energy = energy,
        patterns = {
            drums = {
                groove = "verse"
            }
        }
    }
    for key, value in pairs(extra or {}) do
        section[key] = value
    end
    return section
end

local function Segments(plan, bar)
    local list = {}
    for _, segment in ipairs(plan) do
        if segment.bar == bar then
            table.insert(list, segment)
        end
    end
    return list
end

Test.Case("DrumFill: the energy jump to the next section gives a whole-bar fill", function()
    local registry = Registry({})
    local plan = Arrangement.DrumPlan(Section("verse", 8, 0.6), Section("chorus", 8, 1.0), registry, 4)
    local last = Segments(plan, 8)
    Test.Equal(#last, 1, "the fill takes the whole bar")
    Test.Equal(last[1].pattern.id, "fill")
    Test.Equal(last[1].fromQN, 0)

    plan = Arrangement.DrumPlan(Section("verse", 8, 0.6), Section("verse_2", 8, 0.6), registry, 4)
    last = Segments(plan, 8)
    Test.Equal(#last, 2)
    Test.Equal(last[2].fromQN, 2, "a two-beat fill")

    plan = Arrangement.DrumPlan(Section("outro", 8, 1), nil, registry, 4)
    Test.Equal(#Segments(plan, 8), 1)
    Test.Equal(Segments(plan, 8)[1].pattern, registry.grooves.verse.bars[4], "no fill at the end of the song")
end)

Test.Case("DrumFill: a build replaces the last bars with a snare build", function()
    local registry = Registry({})
    local plan = Arrangement.DrumPlan(Section("verse", 4, 0.6, {
        transition = "build"
    }), Section("chorus", 8, 1), registry, 4)
    Test.Equal(Segments(plan, 4)[1].pattern.id, "build#1")
    Test.Equal(Segments(plan, 3)[1].pattern, registry.grooves.verse.bars[3])
end)

Test.Case("DrumFill: the next section lands on alternating crashes", function()
    local registry = Registry({})
    local state = {
        crashes = 0
    }
    local verse = Section("verse", 4, 0.6)
    local chorus = Section("chorus", 4, 1)
    local outro = Section("outro", 4, 1)
    local plan1 = Arrangement.DrumPlan(chorus, outro, registry, 4, {
        previous = verse,
        state = state
    })
    local plan2 = Arrangement.DrumPlan(outro, nil, registry, 4, {
        previous = chorus,
        state = state
    })
    local function Crash(plan)
        for _, note in ipairs(plan[1].pattern.notes) do
            if note.position == 0 and Group(note) == "cymbals" then
                return note.pitch
            end
        end
    end
    Test.Equal(Crash(plan1), K.crash)
    Test.Equal(Crash(plan2), K.crash_1)
    local first = Arrangement.DrumPlan(verse, chorus, registry, 4)
    Test.Equal(first[1].pattern, registry.grooves.verse.bars[1], "the first section has no arrival")
end)

Test.Case("DrumFill: phrase fills come after 4 and 8 bars, never on the last bar", function()
    local registry = Registry({
        pickup = 1,
        phrase = 1
    })
    local plan = Arrangement.DrumPlan(Section("verse", 16, 0.6, {
        transition = "none"
    }), Section("chorus", 8, 1), registry, 4)
    Test.Equal(Segments(plan, 4)[2].pattern.id, "pickup")
    Test.Equal(Segments(plan, 12)[2].pattern.id, "pickup")
    Test.Equal(Segments(plan, 8)[2].pattern.id, "fill")
    Test.Equal(Segments(plan, 9)[1].pattern.id, registry.grooves.verse.bars[1].id .. "+arrival")
    Test.Equal(#Segments(plan, 16), 1, "transition none")

    registry = Registry({
        pickup = 0,
        phrase = 0
    })
    plan = Arrangement.DrumPlan(Section("verse", 16, 0.6, {
        transition = "none"
    }), nil, registry, 4)
    Test.Equal(#plan, 16, "no phrase fill")
end)

Test.Case("DrumFill: a fill written by hand still wins over the generated ones", function()
    local registry = Registry({})
    local plan = Arrangement.DrumPlan(Section("verse", 4, 0.6, {
        fill = "hand_fill"
    }), Section("chorus", 4, 1), registry, 4)
    Test.Equal(Segments(plan, 4)[2].pattern.id, "hand_fill")
    Test.Equal(Segments(plan, 4)[2].fromQN, 3)
end)

--------------------------------------------------
-- Validation
--------------------------------------------------

local function Errors(fills, transition)
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
            transition = transition,
            patterns = {
                drums = {
                    groove = "verse"
                }
            }
        }},
        patternSets = {{}},
        grooves = {
            verse = Groove()
        },
        fills = fills,
        settings = {
            tempo = 120,
            beats_per_bar = 4,
            beat_unit = 4
        },
        palette = {}
    })
end

Test.Case("DrumFill: the validator checks the fill rules and the transitions", function()
    Test.Equal(#Errors(DrumFill.Rules(nil)), 0, table.concat(Errors(DrumFill.Rules(nil)), "\n"))
    Test.Equal(#Errors({}, "build"), 0)
    local errors = Errors({
        toms = {"high_tom", "cowbell"},
        cells = {"snare", "paradiddle"},
        velocity = {
            from = 10,
            to = 200
        },
        pickup = 2,
        crashes = {}
    }, "huge")
    Test.Contains(errors, "fills toms: unknown drum voice 'cowbell'")
    Test.Contains(errors, "fills: unknown fill cell 'paradiddle'")
    Test.Contains(errors, "fills velocity.to: velocity must be an integer between 1 and 127")
    Test.Contains(errors, "fills velocity.from: must be above 20 (pickups play 20 softer)")
    Test.Contains(errors, "fills: pickup must be a chance between 0 and 1")
    Test.Contains(errors, "fills: crashes must be a non-empty list")
    Test.Contains(errors, "section 'verse': unknown transition 'huge'")
    Test.Contains(Errors(nil, "big"), "section 'verse': unknown fill pattern 'fill_big'")
end)
