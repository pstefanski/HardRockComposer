local Test = require("Test")
local StyleLoader = require("StyleLoader")

local Style = StyleLoader.Load("HardRock")
local TrackLayout = Style.layout
local SongStructure = Style.structure
local SongSettings = Style.settings
local DrumPatterns = Style.patternSets[1]
local Validator = require("Validator")

local ColorsPalette = require("ColorsPalette")

-- Returns a fresh, mutable copy of the project data.
local function Data()
    return Test.DeepCopy({
        layout = TrackLayout,
        structure = SongStructure,
        patternSets = {DrumPatterns},
        settings = SongSettings,
        palette = ColorsPalette
    })
end

local function FindTrack(data, id)
    for _, group in ipairs(data.layout) do
        for _, track in ipairs(group.tracks) do
            if track.id == id then
                return track
            end
        end
    end
    error("No track " .. id)
end

Test.Case("Validator: the shipped data is valid", function()
    local errors = Validator.Validate(Data())
    Test.Equal(#errors, 0, table.concat(errors, "\n"))
end)

Test.Case("Validator: rejects unsupported settings", function()
    local data = Data()
    data.settings.tempo = 0
    data.settings.beat_unit = 3
    data.settings.swing = {amount = 2}
    data.settings.structure_seed = 1.5
    local errors = Validator.Validate(data)
    Test.Contains(errors, "tempo must be")
    Test.Contains(errors, "beat_unit must be 2, 4, 8 or 16")
    Test.Contains(errors, "swing.amount must be between 0 and 1")
    Test.Contains(errors, "structure_seed must be an integer")
end)

Test.Case("Validator: rejects duplicate track ids", function()
    local data = Data()
    FindTrack(data, "snare_top").id = "kick"
    Test.Contains(Validator.Validate(data), "track 'kick': duplicate track id")
end)

Test.Case("Validator: rejects unknown colors", function()
    local data = Data()
    FindTrack(data, "kick").color = "pink"
    data.structure[1].color = "teal"
    local errors = Validator.Validate(data)
    Test.Contains(errors, "track 'kick': unknown color 'pink'")
    Test.Contains(errors, "section 'intro': unknown color 'teal'")
end)

Test.Case("Validator: rejects broken routing", function()
    local data = Data()
    local kick = FindTrack(data, "kick")
    kick.routing.output = "nowhere"
    kick.routing.sends = {{destination = "kick"}, {destination = "fx_plate", mode = "sideways"}}
    local errors = Validator.Validate(data)
    Test.Contains(errors, "unknown destination 'nowhere'")
    Test.Contains(errors, "a track cannot send to itself")
    Test.Contains(errors, "unknown send mode 'sideways'")
end)

Test.Case("Validator: rejects broken plugin outputs", function()
    local data = Data()
    local ezdrummer = FindTrack(data, "ezd_midi").plugins[1]
    ezdrummer.outputs[1].pair = 17
    ezdrummer.outputs[2].destination = "nowhere"
    local errors = Validator.Validate(data)
    Test.Contains(errors, "invalid pair '17'")
    Test.Contains(errors, "unknown destination 'nowhere'")
end)

Test.Case("Validator: rejects duplicate plugin ids", function()
    local data = Data()
    local kick = FindTrack(data, "kick")
    kick.plugins = {{id = "ezdrummer", plugin = "ReaEQ"}}
    Test.Contains(Validator.Validate(data), "duplicate plugin id 'ezdrummer'")
end)

Test.Case("Validator: rejects broken plugin candidates", function()
    local data = Data()
    local kick = FindTrack(data, "kick")
    kick.plugins = {
        {id = "a", plugin = {}},
        {id = "b", plugin = {"VST3: X", {preset = "HRC"}}},
        {id = "c", plugin = "ReaEQ", optional = "yes"}
    }
    local errors = Validator.Validate(data)
    Test.Contains(errors, "plugin 'a': plugin candidate list is empty")
    Test.Contains(errors, "plugin 'b': candidate #2 has no plugin name")
    Test.Contains(errors, "plugin 'c': optional must be true or false")
end)

Test.Case("Validator: rejects unknown pattern references", function()
    local data = Data()
    data.structure[2].patterns.drums.primary = "polka"
    data.structure[1].fill = "fill_missing"
    local errors = Validator.Validate(data)
    Test.Contains(errors, "unknown primary pattern 'polka'")
    Test.Contains(errors, "unknown fill pattern 'fill_missing'")
end)

Test.Case("Validator: rejects invalid sections", function()
    local data = Data()
    data.structure[2].id = data.structure[1].id
    data.structure[3].bars = 0
    data.structure[4].energy = 2
    data.structure[5].transition = "huge"
    local errors = Validator.Validate(data)
    Test.Contains(errors, "duplicate section id")
    Test.Contains(errors, "bars must be a positive integer")
    Test.Contains(errors, "energy must be between 0 and 1")
    Test.Contains(errors, "unknown transition 'huge'")
end)

Test.Case("Validator: rejects invalid patterns", function()
    local data = Data()
    local pattern = data.patternSets[1][1]
    pattern.notes[1].pitch = "kick"
    data.patternSets[1][2].id = pattern.id
    local errors = Validator.Validate(data)
    Test.Contains(errors, "invalid notes")
    Test.Contains(errors, "duplicate pattern id")
end)

Test.Case("Validator: rejects notes outside the pattern", function()
    local data = Data()
    data.patternSets[1][1].notes[1].position = 16
    Test.Contains(Validator.Validate(data), "note at position 16 is outside the pattern (16 sixteenths)")
    data = Data()
    data.settings.beats_per_bar = 12
    data.settings.beat_unit = 8
    data.patternSets[1][1].notes[1].position = 20
    Test.Equal(#Validator.Validate(data), 0, "12/8 bars are 24 sixteenths long")
end)

Test.Case("Validator: optional sections", function()
    local data = Data()
    data.structure[2].chance = 1.5
    Test.Contains(Validator.Validate(data), "chance must be between 0 and 1")
    data = Data()
    for _, section in ipairs(data.structure) do
        section.chance = 0.5
    end
    Test.Contains(Validator.Validate(data), "at least one section must be mandatory")
end)

Test.Case("Validator: Assert reports every error at once", function()
    local data = Data()
    data.settings.tempo = -1
    FindTrack(data, "kick").color = "pink"
    Test.Raises(function() Validator.Assert(data) end, "2 error(s)")
end)
