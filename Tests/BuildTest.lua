local Test = require("Test")
local MockReaper = require("MockReaper")
local Builder = require("Builder")

local TrackLayout = require("TrackLayout")
local SongStructure = require("SongStructure")
local SongSettings = require("SongSettings")

local function ExpectedTrackCount()
    local count = 0
    for _, group in ipairs(TrackLayout) do
        if group.folder ~= false then
            count = count + 1
        end
        count = count + #group.tracks
    end
    return count
end

local function SectionsWithDrums()
    local count = 0
    for _, section in ipairs(SongStructure) do
        if section.patterns and section.patterns.drums then
            count = count + 1
        end
    end
    return count
end

local function CountMarkers(state, isRegion)
    local count = 0
    for _, marker in ipairs(state.markers) do
        if marker.isRegion == isRegion then
            count = count + 1
        end
    end
    return count
end

-- A compact fingerprint of every generated MIDI note.
local function NotesFingerprint(state)
    local parts = {}
    for _, item in ipairs(state.items) do
        for _, note in ipairs(item.take.notes) do
            table.insert(parts, string.format("%g:%d:%d:%d", item.startQN, note.startPPQ, note.pitch, note.velocity))
        end
    end
    return table.concat(parts, ";")
end

Test.Case("Build: creates every folder and track", function()
    local state = MockReaper.Reset()
    Builder.Build(TrackLayout)
    Test.Equal(#state.tracks, ExpectedTrackCount())
end)

Test.Case("Build: applies tempo and time signature from SongSettings", function()
    local state = MockReaper.Reset()
    Builder.Build(TrackLayout)
    Test.Equal(state.bpm, SongSettings.tempo)
    Test.Equal(#state.tempoMarkers, 1)
    Test.Equal(state.tempoMarkers[1].numerator, SongSettings.beats_per_bar)
    Test.Equal(state.tempoMarkers[1].denominator, SongSettings.beat_unit)
end)

Test.Case("Build: keeps one marker and one region per section", function()
    local state = MockReaper.Reset()
    Builder.Build(TrackLayout)
    Test.Equal(CountMarkers(state, false), #SongStructure, "markers")
    Test.Equal(CountMarkers(state, true), #SongStructure, "regions")
end)

Test.Case("Build: markers are placed at the song tempo", function()
    local state = MockReaper.Reset()
    Builder.Build(TrackLayout)
    local secondSectionQN = SongStructure[1].bars * SongSettings.beats_per_bar
    local expected = secondSectionQN * 60 / SongSettings.tempo
    Test.Near(state.markers[2].position, expected, 1e-9, "second marker")
end)

Test.Case("Build: writes one drum item per section on the EZD MIDI track", function()
    local state = MockReaper.Reset()
    Builder.Build(TrackLayout)
    Test.Equal(#state.items, SectionsWithDrums())
    for _, item in ipairs(state.items) do
        Test.Equal(item.track.name, "EZD MIDI")
        Test.True(#item.take.notes > 0, "item at QN " .. item.startQN .. " has no notes")
    end
end)

Test.Case("Build: MIDI generation is deterministic", function()
    local state = MockReaper.Reset()
    Builder.Build(TrackLayout)
    local first = NotesFingerprint(state)
    state = MockReaper.Reset()
    Builder.Build(TrackLayout)
    Test.Equal(NotesFingerprint(state), first)
end)

Test.Case("Build: rebuilding replaces the previous project", function()
    local state = MockReaper.Reset()
    Builder.Build(TrackLayout)
    Builder.Build(TrackLayout)
    Test.Equal(#state.tracks, ExpectedTrackCount())
    Test.Equal(CountMarkers(state, false), #SongStructure)
    Test.Equal(#state.tempoMarkers, 1)
end)

Test.Case("Build: invalid data leaves the current project untouched", function()
    local state = MockReaper.Reset()
    reaper.InsertTrackAtIndex(0)
    local layout = Test.DeepCopy(TrackLayout)
    layout[1].tracks[2].routing.output = "nowhere"
    Test.Raises(function() Builder.Build(layout) end, "unknown destination 'nowhere'")
    Test.Equal(#state.tracks, 1)
end)

Test.Case("Build: a missing plugin stops the build", function()
    local state = MockReaper.Reset()
    state.missingPlugins["EZdrummer 3"] = true
    Test.Raises(function() Builder.Build(TrackLayout) end, "Unable to load plugin 'EZdrummer 3'")
end)
