local Test = require("Test")
local MockReaper = require("MockReaper")
local Builder = require("Builder")
local Validator = require("Validator")
local StyleLoader = require("StyleLoader")
local Harmony = require("Harmony")

local PPQ = MockReaper.PPQ

local function Load(id, change)
    local style = Test.DeepCopy(StyleLoader.Load(id))
    style.settings.humanization.enabled = false
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

local function Track(state, name)
    for _, track in ipairs(state.tracks) do
        if track.name == name then
            return track
        end
    end
    error("No track " .. name)
end

local function ItemsOn(state, name)
    local items = {}
    for _, item in ipairs(state.items) do
        if item.track.name == name then
            table.insert(items, item)
        end
    end
    return items
end

local function NotesBetween(item, fromPPQ, toPPQ)
    local notes = {}
    for _, note in ipairs(item.take.notes) do
        if note.startPPQ >= fromPPQ and note.startPPQ < toPPQ then
            table.insert(notes, note)
        end
    end
    return notes
end

local function Validate(style)
    return Validator.Validate({
        layout = style.layout,
        structure = style.structure,
        patternSets = style.patternSets,
        settings = style.settings,
        palette = require("ColorsPalette")
    })
end

--------------------------------------------------
-- Harmony
--------------------------------------------------

Test.Case("Harmony: parses roots, qualities and slash basses", function()
    local chord = Harmony.Parse("F#m")
    Test.Equal(chord.root, 6)
    Test.Equal(chord.quality, "m")
    Test.Equal(chord.bass, 6)
    Test.Equal(Harmony.Parse("Bb7").root, 10)
    Test.Equal(Harmony.Parse("E5").root, 4)
    Test.Equal(Harmony.Parse("D/F#").bass, 6)
    Test.Equal(Harmony.Parse("Cb").root, 11)
end)

Test.Case("Harmony: rejects unknown symbols", function()
    local chord, message = Harmony.Parse("H7")
    Test.Equal(chord, nil)
    Test.Equal(message, "unknown chord 'H7'")
    Test.Equal(select(2, Harmony.Parse("Exyz")), "unknown chord quality in 'Exyz'")
    Test.Equal(select(2, Harmony.Parse("C/X")), "unknown slash bass in 'C/X'")
end)

Test.Case("Harmony: bass notes stay between E2 and D#3 by default", function()
    Test.Equal(Harmony.BassPitch(4), 40)
    Test.Equal(Harmony.BassPitch(3), 51)
    Test.Equal(Harmony.BassPitch(0), 48)
end)

Test.Case("Harmony: the bass register can start on any note", function()
    Test.Equal(Harmony.BassPitch(4, 28), 28)
    Test.Equal(Harmony.BassPitch(3, 28), 39)
    Test.Equal(Harmony.BassPitch(0, 33), 36, "A1 register")
    Test.Equal(Harmony.BassPitch(9, 33), 33)
end)

Test.Case("Harmony: the progression repeats through the section", function()
    local section = {bars = 8, chords = {"E5", "D5", "A5"}}
    Test.Equal(Harmony.ChordAt(section, 0, 4).symbol, "E5")
    Test.Equal(Harmony.ChordAt(section, 3.9, 4).symbol, "E5")
    Test.Equal(Harmony.ChordAt(section, 4, 4).symbol, "D5")
    Test.Equal(Harmony.ChordAt(section, 12, 4).symbol, "E5")
    section.chord_bars = 0.5
    Test.Equal(Harmony.ChordAt(section, 2, 4).symbol, "D5")
    Test.Equal(Harmony.ChordAt({bars = 4}, 0, 4), nil)
end)

Test.Case("Harmony: changes merge repeated chords", function()
    local changes = Harmony.Changes({bars = 4, chords = {"E7", "E7", "A7"}}, 4)
    Test.Equal(#changes, 3)
    Test.Equal(changes[1].chord.symbol, "E7")
    Test.Equal(changes[1].toQN, 8)
    Test.Equal(changes[2].chord.symbol, "A7")
    Test.Equal(changes[3].fromQN, 12)
    Test.Equal(changes[3].toQN, 16)
end)

--------------------------------------------------
-- Bass
--------------------------------------------------

local function KickBass(style)
    style.settings.bass.mode = "kick"
end

Test.Case("Bass: kick mode plays the root on every kick", function()
    local state, context = Build(Load("HardRock", KickBass))
    Test.Equal(context.song[2].id, "verse_1")
    local verse = ItemsOn(state, "Bass MIDI")[2]

    -- Bar 1 (E5): verse_drive kicks on beats 1 and 3.
    local bar1 = NotesBetween(verse, 0, 4 * PPQ)
    Test.Equal(#bar1, 2)
    Test.Equal(bar1[1].pitch, 40, "E2")
    Test.Equal(bar1[2].startPPQ, 2 * PPQ)

    -- Bar 3 (D5): D3.
    local bar3 = NotesBetween(verse, 8 * PPQ, 12 * PPQ)
    Test.Equal(bar3[1].pitch, 50)
end)

Test.Case("Bass: kick mode follows the extra kicks of variations", function()
    local state = Build(Load("HardRock", KickBass))
    local verse = ItemsOn(state, "Bass MIDI")[2]
    -- Bar 4 uses verse_drive_alt, with an extra kick on position 10.
    local bar4 = NotesBetween(verse, 12 * PPQ, 16 * PPQ)
    Test.Equal(#bar4, 3)
    Test.Equal(bar4[3].startPPQ, 12 * PPQ + 2.5 * PPQ)
end)

Test.Case("Bass: boogie mode walks root, fifth, sixth, fifth in 12/8", function()
    local state, context = Build(Load("BluesRock"))
    Test.Equal(context.song[2].id, "verse_1")
    local bar1 = NotesBetween(ItemsOn(state, "Bass MIDI")[2], 0, 6 * PPQ)
    Test.Equal(#bar1, 8)
    local expected = {40, 40, 47, 47, 49, 49, 47, 47}
    for index, note in ipairs(bar1) do
        Test.Equal(note.pitch, expected[index], "note " .. index)
    end
    -- Shuffle: second note of each beat on the third triplet.
    Test.Equal(bar1[2].startPPQ, PPQ)
    Test.Equal(bar1[3].startPPQ, 1.5 * PPQ)
end)

Test.Case("Bass: Hard Rock plays root eighth notes", function()
    local state, context = Build(Load("HardRock"))
    Test.Equal(context.song[2].id, "verse_1")
    local bar1 = NotesBetween(ItemsOn(state, "Bass MIDI")[2], 0, 4 * PPQ)
    Test.Equal(#bar1, 8)
    for index, note in ipairs(bar1) do
        Test.Equal(note.startPPQ, (index - 1) * PPQ / 2)
        Test.Equal(note.pitch, 40, "E2")
    end
end)

Test.Case("Bass: eighths mode drives every eighth note", function()
    local state = Build(Load("PunkRock"))
    local bar1 = NotesBetween(ItemsOn(state, "Bass MIDI")[2], 0, 4 * PPQ)
    Test.Equal(#bar1, 8)
    for index, note in ipairs(bar1) do
        Test.Equal(note.startPPQ, (index - 1) * PPQ / 2)
        Test.Equal(note.pitch, 43, "G2")
    end
end)

Test.Case("Bass: lowest_note moves the register", function()
    local state = Build(Load("HardRock", function(style)
        style.settings.bass.lowest_note = 28
    end))
    local bar1 = NotesBetween(ItemsOn(state, "Bass MIDI")[2], 0, 4 * PPQ)
    Test.Equal(bar1[1].pitch, 28, "E1")
end)

Test.Case("Bass: no bass settings, no bass line", function()
    local state = Build(Load("HardRock", function(style)
        style.settings.bass = nil
    end))
    Test.Equal(#ItemsOn(state, "Bass MIDI"), 0)
end)

--------------------------------------------------
-- Chord guide
--------------------------------------------------

Test.Case("Chord guide: one text item per chord change", function()
    local style = Load("HardRock")
    local state, context = Build(style)
    local items = Track(state, "Chords").textItems
    local expected = 0
    for _, section in ipairs(context.song) do
        expected = expected + #Harmony.Changes(section, 4)
    end
    Test.Equal(#items, expected)

    -- Intro: E5 E5 G5 A5 → E5 lasts two bars.
    Test.Equal(items[1].info.P_NOTES, "E5")
    Test.Equal(items[1].info.D_POSITION, 0)
    Test.Near(items[1].info.D_LENGTH, 8 * 60 / style.settings.tempo)
    Test.Equal(items[2].info.P_NOTES, "G5")
end)

--------------------------------------------------
-- Automation
--------------------------------------------------

Test.Case("Automation: bus levels follow the section energy", function()
    local style = Load("HardRock")
    local state, context = Build(style)

    local points = Track(state, "Drum Bus").envelopes.Volume.points
    Test.Equal(#points, #context.song)
    Test.Equal(points[1].shape, 1, "square points")

    -- Intro energy 0.3: -3 + 3 * 0.3 = -2.1 dB.
    Test.Near(points[1].value, 10 ^ (-2.1 / 20), 1e-9)

    -- Hall: louder in calm sections (0 dB at energy 0, -6 dB at energy 1).
    local hall = Track(state, "Hall").envelopes.Volume.points
    Test.Near(hall[1].value, 10 ^ (-1.8 / 20), 1e-9)
    Test.Near(hall[3].value, 10 ^ (-6 / 20), 1e-9, "chorus at full energy")
end)

Test.Case("Automation: tracks without automation have no envelope", function()
    local state = Build(Load("HardRock"))
    Test.Equal(Track(state, "Kick").envelopes, nil)
end)

--------------------------------------------------
-- Count-in
--------------------------------------------------

Test.Case("Count-in: shifts the song and clicks every beat", function()
    local style = Load("HardRock", function(s)
        s.settings.count_in = {bars = 2}
    end)
    local state, context = Build(style)
    Test.Equal(context.song[1].startBar, 3)
    Test.Equal(state.markers[1].name, "Count-in")
    Test.Equal(state.markers[1].position, 0)

    local drums = ItemsOn(state, "EZD MIDI")
    local countIn = drums[#drums]
    Test.Equal(countIn.startQN, 0)
    Test.Equal(countIn.endQN, 8)
    Test.Equal(#countIn.take.notes, 8)
    Test.Equal(countIn.take.notes[1].pitch, 37)
    Test.Equal(countIn.take.notes[1].velocity, 110)

    Test.Equal(drums[1].startQN, 8, "intro after the count-in")
end)

Test.Case("Count-in: counts dotted quarters in 12/8", function()
    local style = Load("BluesRock", function(s)
        s.settings.count_in = {bars = 1}
    end)
    local state = Build(style)
    local drums = ItemsOn(state, "EZD MIDI")
    local countIn = drums[#drums]
    Test.Equal(#countIn.take.notes, 4)
    Test.Equal(countIn.take.notes[2].startPPQ, 1.5 * PPQ)
end)

--------------------------------------------------
-- Validation
--------------------------------------------------

Test.Case("Validator: checks chords, bass, count-in and automation", function()
    local style = Load("HardRock")
    style.structure[1].chords = {"E5", "H7"}
    style.structure[2].chord_bars = 0
    style.structure[3].chords = {}
    style.settings.bass.mode = "slap"
    style.settings.bass.lowest_note = 120
    style.settings.count_in = {bars = 0}
    style.layout[2].tracks[#style.layout[2].tracks].automation.volume.high = nil
    local errors = Validate(style)
    Test.Contains(errors, "section 'intro': unknown chord 'H7'")
    Test.Contains(errors, "chord_bars must be a positive number")
    Test.Contains(errors, "chords must be a non-empty list")
    Test.Contains(errors, "bass.mode must be kick, eighths or boogie")
    Test.Contains(errors, "bass.lowest_note must be a MIDI note between 0 and 107")
    Test.Contains(errors, "count_in.bars must be a positive integer")
    Test.Contains(errors, "track 'drum_bus': automation.volume needs low and high levels")
end)

Test.Case("Validator: chords and bass need their tracks", function()
    local style = Load("HardRock")
    table.remove(style.layout, 1)
    for _, group in ipairs(style.layout) do
        for index = #group.tracks, 1, -1 do
            if group.tracks[index].id == "bass_midi" then
                table.remove(group.tracks, index)
            end
        end
    end
    local errors = Validate(style)
    Test.Contains(errors, "chords require a 'chords' track")
    Test.Contains(errors, "the bass line requires a 'bass_midi' track")
end)
