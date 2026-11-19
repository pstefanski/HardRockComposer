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
            settings = style.settings,
            palette = require("ColorsPalette")
        })
        Test.Equal(#errors, 0, table.concat(errors, "\n"))
    end)

    Test.Case("Styles: " .. entry.id .. " builds with every note inside its section", function()
        local style = Load(entry.id)
        local state, context = Build(style)
        local timing = style.settings.humanization.timing
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
    -- and the triplet pickup fill at the end of its last bar.
    local verse = ItemsOn(state, "EZD MIDI")[2]
    Test.Equal(context.song[2].id, "verse_1")
    Test.True(HasNoteAt(verse, 38, 1.5 * PPQ), "snare on beat 2")
    Test.True(HasNoteAt(verse, 38, 4.5 * PPQ), "snare on beat 4")
    local lastBarPPQ = (context.song[2].bars - 1) * 6 * PPQ
    Test.True(HasNoteAt(verse, 38, lastBarPPQ + 5.5 * PPQ), "last triplet of the fill")
end)

Test.Case("Styles: Classic Rock swings the off-beat eighths", function()
    local style = Load("ClassicRock", function(s)
        s.settings.humanization.enabled = false
    end)
    local state, context = Build(style)
    local verse = ItemsOn(state, "EZD MIDI")[2]
    Test.Equal(context.song[2].id, "verse_1")
    local amount = style.settings.swing.amount
    Test.True(HasNoteAt(verse, 42, 0), "on-beat hat stays on the grid")
    Test.True(HasNoteAt(verse, 42, (0.5 + amount / 6) * PPQ), "off-beat hat is delayed")
    Test.True(not HasNoteAt(verse, 42, 0.5 * PPQ), "no straight off-beat hat")
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
