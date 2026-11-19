local Test = require("Test")
local MockReaper = require("MockReaper")
local Session = require("Session")
local Serialize = require("Serialize")
local Harmony = require("Harmony")
local StyleLoader = require("StyleLoader")
local Validator = require("Validator")

local function Style(id)
    return StyleLoader.Load(id or "HardRock")
end

local function SectionIds(style)
    local ids = {}
    for _, section in ipairs(style.structure) do
        table.insert(ids, section.id)
    end
    return table.concat(ids, ",")
end

--------------------------------------------------
-- Serialize
--------------------------------------------------

Test.Case("Serialize: round trip of nested data", function()
    local value = {
        style = "HardRock",
        tempo = 140.5,
        seed = 42,
        flag = true,
        name = 'quote " and\nnewline',
        sections = {{source = "intro", energy = 0.3}, {source = "verse_1", energy = 1 / 3}}
    }
    local decoded = Serialize.Decode(Serialize.Encode(value))
    Test.Equal(decoded.tempo, 140.5)
    Test.Equal(math.type(decoded.seed), "integer")
    Test.Equal(decoded.flag, true)
    Test.Equal(decoded.name, value.name)
    Test.Equal(decoded.sections[2].energy, 1 / 3, "floats are exact")
    Test.Equal(Serialize.Encode(decoded), Serialize.Encode(value), "stable output")
end)

Test.Case("Serialize: decoding only produces data", function()
    Test.Equal(Serialize.Decode("os.exit(1)"), nil)
    Test.Equal(Serialize.Decode("{ x = os }").x, nil, "no library is reachable")
    Test.Equal(Serialize.Decode("{ broken"), nil)
    Test.Equal(Serialize.Decode(""), nil)
    Test.Equal(Serialize.Decode(nil), nil)
end)

--------------------------------------------------
-- Transposition
--------------------------------------------------

Test.Case("Harmony: transposes chord symbols", function()
    Test.Equal(Harmony.Transpose("E5", 3), "G5")
    Test.Equal(Harmony.Transpose("A7", 1), "Bb7")
    Test.Equal(Harmony.Transpose("F#m", -2), "Em")
    Test.Equal(Harmony.Transpose("D/F#", 2), "E/Ab")
    Test.Equal(Harmony.Transpose("B5", 1), "C5")
    Test.Equal(Harmony.Transpose("Cmaj7", 0), "Cmaj7")
    Test.Equal(Harmony.KeyPitch("Bb"), 10)
    Test.Equal(Harmony.KeyPitch("H"), nil)
end)

--------------------------------------------------
-- Defaults and Apply
--------------------------------------------------

Test.Case("Session: defaults follow the style", function()
    local style = Style("ClassicRock")
    local options = Session.Defaults(style)
    Test.Equal(options.style, "ClassicRock")
    Test.Equal(options.tempo, 120)
    Test.Equal(options.key, "A")
    Test.Equal(options.bass_mode, "kick")
    Test.Equal(options.swing, 0.3)
    Test.Equal(options.count_in, 0)
    Test.Equal(#options.sections, #style.structure)
    Test.Equal(options.sections[6].play, "seed", "bridge is optional")
    Test.Equal(options.sections[1].play, "always")
end)

Test.Case("Session: unchanged defaults give the style back", function()
    for _, entry in ipairs(StyleLoader.Available()) do
        local style = Style(entry.id)
        local applied = Session.Apply(style, Session.Defaults(style))
        Test.Equal(SectionIds(applied), SectionIds(style), entry.id)
        for index, section in ipairs(applied.structure) do
            Test.Equal(section.chance, style.structure[index].chance, entry.id .. " chance")
            Test.Equal(table.concat(section.chords or {}, " "), table.concat(style.structure[index].chords or {}, " "))
        end
    end
end)

Test.Case("Session: settings are applied to a copy of the style", function()
    local style = Style("HardRock")
    local options = Session.Defaults(style)
    options.tempo = 150
    options.structure_seed = 9
    options.count_in = 2
    options.bass_mode = "kick"
    local applied = Session.Apply(style, options)
    Test.Equal(applied.settings.tempo, 150)
    Test.Equal(applied.settings.structure_seed, 9)
    Test.Equal(applied.settings.count_in.bars, 2)
    Test.Equal(applied.settings.bass.mode, "kick")
    Test.Equal(style.settings.tempo, 140, "the loaded style is not modified")
    Test.Equal(style.settings.bass.mode, "eighths")
end)

Test.Case("Session: the key transposes every chord", function()
    local style = Style("HardRock")
    local options = Session.Defaults(style)
    options.key = "G"
    local applied = Session.Apply(style, options)
    Test.Equal(applied.settings.key, "G")
    Test.Equal(table.concat(applied.structure[1].chords, " "), "G5 G5 Bb5 C5")
    Test.Equal(table.concat(style.structure[1].chords, " "), "E5 E5 G5 A5", "original untouched")
end)

Test.Case("Session: sections can be edited, reordered, duplicated and skipped", function()
    local style = Style("PunkRock")
    local options = Session.Defaults(style)

    options.sections[1].bars = 2
    options.sections[1].name = "Count"
    options.sections[2].energy = 0.5
    Session.DuplicateSection(options, 3)              -- chorus_1 twice
    Session.MoveSection(options, 2, -1)               -- verse_1 first
    options.sections[7].play = "always"               -- bridge (was seed)
    options.sections[#options.sections - 1].play = "never" -- chorus_4

    local applied = Session.Apply(style, options)
    Test.Equal(SectionIds(applied), "verse_1,intro,chorus_1,chorus_1_2,verse_2,chorus_2,bridge,chorus_3,outro")
    Test.Equal(applied.structure[2].bars, 2)
    Test.Equal(applied.structure[2].name, "Count")
    Test.Equal(applied.structure[1].energy, 0.5)
    Test.Equal(applied.structure[7].chance, nil, "forced bridge")

    local errors = Validator.Validate({
        layout = applied.layout,
        structure = applied.structure,
        patternSets = applied.patternSets,
        grooves = applied.grooves,
        settings = applied.settings,
        palette = require("ColorsPalette")
    })
    Test.Equal(#errors, 0, table.concat(errors, "\n"))
end)

Test.Case("Session: the last section cannot be removed, moves stay in range", function()
    local style = Style("HardRock")
    local options = Session.Defaults(style)
    Test.True(not Session.MoveSection(options, 1, -1))
    Test.True(not Session.MoveSection(options, #options.sections, 1))
    while #options.sections > 1 do
        Test.True(Session.RemoveSection(options, 1))
    end
    Test.True(not Session.RemoveSection(options, 1))
end)

--------------------------------------------------
-- Normalize and persistence
--------------------------------------------------

Test.Case("Session: invalid saved choices fall back to the defaults", function()
    local style = Style("BluesRock")
    local defaults = Session.Defaults(style)
    local options = Session.Normalize(style, {
        style = "BluesRock",
        tempo = -5,
        key = "H",
        structure_seed = 1.5,
        count_in = 99,
        swing = 0.4,
        target = "elsewhere",
        sections = {{source = "gone"}, {source = "intro", bars = 0, energy = 4, play = "seed"}}
    })
    Test.Equal(options.tempo, defaults.tempo)
    Test.Equal(options.key, "E")
    Test.Equal(options.structure_seed, defaults.structure_seed)
    Test.Equal(options.count_in, 0)
    Test.Equal(options.swing, nil, "Blues Rock has no swing setting")
    Test.Equal(options.target, "replace")
    Test.Equal(#options.sections, 1, "unknown sections are dropped")
    Test.Equal(options.sections[1].bars, 4)
    Test.Equal(options.sections[1].energy, 0.4)
    Test.Equal(options.sections[1].play, "always", "intro has no chance")

    Test.Equal(Session.Normalize(style, nil).tempo, defaults.tempo)
    Test.Equal(Session.Normalize(style, {style = "HardRock"}).key, "E")
end)

Test.Case("Session: choices are saved per style in REAPER", function()
    local state = MockReaper.Reset()
    local style = Style("HeavyRock")
    local options = Session.Defaults(style)
    options.tempo = 152
    options.key = "C"
    options.target = "new_tab"
    Session.Save(options)

    Test.Equal(Session.LastStyle(), "HeavyRock")
    Test.True(state.extState["HardRockComposer/session.HeavyRock"] ~= nil)

    local loaded = Session.Load(style)
    Test.Equal(loaded.tempo, 152)
    Test.Equal(loaded.key, "C")
    Test.Equal(loaded.target, "new_tab")

    Test.Equal(Session.Load(Style("PunkRock")).tempo, 190, "other styles keep their defaults")
end)
