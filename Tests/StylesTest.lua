local Test = require("Test")
local MockReaper = require("MockReaper")
local Builder = require("Builder")
local Validator = require("Validator")
local StyleLoader = require("StyleLoader")
local Timing = require("Timing")

local PPQ = MockReaper.PPQ

local function Load(id, change)
    local style = Test.DeepCopy(StyleLoader.Load(id))
    if change then
        change(style)
    end
    return style
end

local function Build(style)
    local state = MockReaper.Reset()
    local context = Builder.Build(style)
    return state, context
end

local function ItemsOn(state, trackName)
    local items = {}
    for _, item in ipairs(state.items) do
        if item.track.name == trackName then
            table.insert(items, item)
        end
    end
    return items
end

local function HasNoteAt(item, pitch, ppq)
    for _, note in ipairs(item.take.notes) do
        if note.pitch == pitch and math.abs(note.startPPQ - ppq) < 1e-6 then
            return true
        end
    end
    return false
end

for _, entry in ipairs(StyleLoader.Available()) do

    Test.Case("Styles: " .. entry.id .. " data is valid", function()
        local style = Load(entry.id)
        local errors = Validator.Validate({
            layout = style.layout,
            structure = style.structure,
            patternSets = style.patternSets,
            grooves = style.grooves,
            fills = style.fills,
            settings = style.settings,
            palette = require("ColorsPalette")
        })
        Test.Equal(#errors, 0, table.concat(errors, "\n"))
    end)

    Test.Case("Styles: " .. entry.id .. " builds with every note inside its section", function()
        local style = Load(entry.id)
        local state, context = Build(style)
        -- Humanization can move a note before the section: its timing
        -- range plus the earliest placement of a part of the kit.
        local timing = style.settings.humanization.timing
        for _, ticks in pairs(style.settings.humanization.feel or {}) do
            timing = math.max(timing, style.settings.humanization.timing - ticks)
        end
        local qnPerBar = Timing.QNPerBar(style.settings)

        Test.Equal(state.tempoMarkers[1].numerator, style.settings.beats_per_bar)
        Test.Equal(state.tempoMarkers[1].denominator, style.settings.beat_unit)
        for _, trackName in ipairs({"EZD MIDI", "Bass MIDI"}) do
            local items = ItemsOn(state, trackName)
            Test.Equal(#items, #context.song, trackName .. " items")

            for index, item in ipairs(items) do
                local section = context.song[index]
                local where = trackName .. " " .. section.id
                local lengthPPQ = (item.endQN - item.startQN) * PPQ
                Test.Equal(item.endQN - item.startQN, section.bars * qnPerBar, where .. " length")
                Test.True(#item.take.notes > 0, where .. ": no notes")
                for _, note in ipairs(item.take.notes) do
                    Test.True(note.startPPQ >= -timing and note.startPPQ < lengthPPQ,
                        where .. ": note at " .. note.startPPQ .. " outside 0.." .. lengthPPQ)
                    Test.True(note.endPPQ > note.startPPQ, where .. ": empty note")
                end
            end
        end
    end)

end

Test.Case("Styles: the snare sits behind the hi-hat in Hard Rock", function()
    local style = Load("HardRock")
    local state, context = Build(style)
    local K = require("DrumKit").notes
    local offsets = {[K.snare] = {}, [K.closed_hat] = {}}
    for index, item in ipairs(ItemsOn(state, "EZD MIDI")) do
        if context.song[index] and context.song[index].id == "verse_1" then
            for _, note in ipairs(item.take.notes) do
                if offsets[note.pitch] then
                    local grid = math.floor(note.startPPQ / (PPQ / 4) + 0.5) * (PPQ / 4)
                    table.insert(offsets[note.pitch], note.startPPQ - grid)
                end
            end
        end
    end
    local function Average(list)
        local sum = 0
        for _, value in ipairs(list) do
            sum = sum + value
        end
        return sum / #list
    end
    Test.True(#offsets[K.snare] > 16 and #offsets[K.closed_hat] > 16)
    Test.Near(Average(offsets[K.snare]), 8, 2, "snare placement")
    Test.Near(Average(offsets[K.closed_hat]), -4, 2, "hi-hat placement")
end)

Test.Case("Styles: Hard Rock hands over with generated fills and arrival crashes", function()
    local style = Load("HardRock", function(s)
        s.settings.humanization.enabled = false
    end)
    local state, context = Build(style)
    local K = require("DrumKit").notes
    local items = ItemsOn(state, "EZD MIDI")
    Test.Equal(context.song[2].id, "verse_1")
    Test.Equal(context.song[3].id, "chorus_1")

    -- The intro (energy 0.3) jumps to the verse (0.6): a whole-bar fill,
    -- without hi-hat, then a crash and a kick on the first beat of the verse.
    local intro, verse = items[1], items[2]
    local lastBar = (context.song[1].bars - 1) * 4 * PPQ
    for _, note in ipairs(intro.take.notes) do
        if note.startPPQ >= lastBar then
            Test.True(note.pitch ~= K.closed_hat and note.pitch ~= K.crash, "no cymbal during the fill")
        end
    end
    Test.True(HasNoteAt(verse, K.crash, 0), "crash on the verse")
    Test.True(HasNoteAt(verse, K.kick, 0))
    Test.True(not HasNoteAt(verse, K.closed_hat, 0), "the crash replaces the hi-hat")

    -- The chorus after the next fill lands on the other crash.
    Test.True(HasNoteAt(items[3], K.crash_1, 0), "crashes alternate")

    -- Verse 2 builds up to the chorus on the snare.
    local verse2 = items[4]
    Test.Equal(context.song[4].id, "verse_2")
    local snares = 0
    local lastVerseBar = (context.song[4].bars - 1) * 4 * PPQ
    for _, note in ipairs(verse2.take.notes) do
        if note.startPPQ >= lastVerseBar and note.pitch == K.snare then
            snares = snares + 1
        end
    end
    Test.True(snares >= 12, "a snare build over the last bar (" .. snares .. " snares)")
end)

Test.Case("Styles: an unknown style lists the available ones", function()
    Test.Raises(function() StyleLoader.Load("Polka") end, "Unknown style 'Polka' (available: HardRock, ClassicRock")
end)

Test.Case("Styles: Blues Rock bars last six quarter notes (12/8)", function()
    local style = Load("BluesRock", function(s)
        s.settings.humanization.enabled = false
    end)
    local state, context = Build(style)
    Test.Equal(state.tempoMarkers[1].numerator, 12)
    Test.Equal(state.tempoMarkers[1].denominator, 8)

    -- Verse 1: shuffle backbeat on the 2nd and 4th dotted quarter of bar 1,
    -- and a generated triplet fill over its last bar (the chorus is louder).
    local verse = ItemsOn(state, "EZD MIDI")[2]
    Test.Equal(context.song[2].id, "verse_1")
    Test.True(HasNoteAt(verse, 38, 1.5 * PPQ), "snare on beat 2")
    Test.True(HasNoteAt(verse, 38, 4.5 * PPQ), "snare on beat 4")
    local lastBarPPQ = (context.song[2].bars - 1) * 6 * PPQ
    local endPPQ = context.song[2].bars * 6 * PPQ
    for beat = 0, 3 do
        Test.True(HasNoteAt(verse, 36, lastBarPPQ + beat * 1.5 * PPQ), "kick under the fill, beat " .. beat + 1)
    end
    for _, note in ipairs(verse.take.notes) do
        if note.startPPQ >= lastBarPPQ and note.startPPQ < endPPQ then
            Test.True(note.pitch ~= 42 and note.pitch ~= 51, "no hi-hat or ride during the fill")
            Test.True(math.abs((note.startPPQ - lastBarPPQ) % (PPQ / 2)) < 1e-6, "triplet grid")
        end
    end
end)

Test.Case("Styles: Classic Rock swings the off-beat eighths", function()
    local style = Load("ClassicRock", function(s)
        s.settings.humanization.enabled = false
    end)
    local state, context = Build(style)
    local verse = ItemsOn(state, "EZD MIDI")[2]
    Test.Equal(context.song[2].id, "verse_1")
    local amount = style.settings.swing.amount
    -- Bar 2 (bar 1 lands on a crash after the intro fill).
    local bar = 4 * PPQ
    Test.True(HasNoteAt(verse, 42, bar), "on-beat hat stays on the grid")
    Test.True(HasNoteAt(verse, 42, bar + (0.5 + amount / 6) * PPQ), "off-beat hat is delayed")
    Test.True(not HasNoteAt(verse, 42, bar + 0.5 * PPQ), "no straight off-beat hat")
end)

Test.Case("Styles: the structure seed picks the optional sections", function()
    local songs = {}
    for seed = 1, 12 do
        local _, context = Build(Load("PunkRock", function(s)
            s.settings.structure_seed = seed
        end))
        local ids = {}
        for _, section in ipairs(context.song) do
            table.insert(ids, section.id)
        end
        songs[table.concat(ids, ",")] = true
    end
    local count = 0
    for _ in pairs(songs) do
        count = count + 1
    end
    Test.True(count >= 3, "expected several song variants, got " .. count)
end)
