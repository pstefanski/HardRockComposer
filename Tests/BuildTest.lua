local Test = require("Test")
local StyleLoader = require("StyleLoader")

local Style = StyleLoader.Load("HardRock")
local TrackLayout = Style.layout
local SongStructure = Style.structure
local SongSettings = Style.settings
local DrumPatterns = Style.patternSets[1]
local MockReaper = require("MockReaper")
local Builder = require("Builder")


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
    Builder.Build(Style)
    Test.Equal(#state.tracks, ExpectedTrackCount())
end)

Test.Case("Build: applies tempo and time signature from SongSettings", function()
    local state = MockReaper.Reset()
    Builder.Build(Style)
    Test.Equal(state.bpm, SongSettings.tempo)
    Test.Equal(#state.tempoMarkers, 1)
    Test.Equal(state.tempoMarkers[1].numerator, SongSettings.beats_per_bar)
    Test.Equal(state.tempoMarkers[1].denominator, SongSettings.beat_unit)
end)

Test.Case("Build: keeps one marker and one region per section", function()
    local state = MockReaper.Reset()
    Builder.Build(Style)
    Test.Equal(CountMarkers(state, false), #SongStructure, "markers")
    Test.Equal(CountMarkers(state, true), #SongStructure, "regions")
end)

Test.Case("Build: markers are placed at the song tempo", function()
    local state = MockReaper.Reset()
    Builder.Build(Style)
    local secondSectionQN = SongStructure[1].bars * SongSettings.beats_per_bar
    local expected = secondSectionQN * 60 / SongSettings.tempo
    Test.Near(state.markers[2].position, expected, 1e-9, "second marker")
end)

Test.Case("Build: writes one drum item per section on the EZD MIDI track", function()
    local state = MockReaper.Reset()
    Builder.Build(Style)
    local drumItems = 0
    for _, item in ipairs(state.items) do
        if item.track.name == "EZD MIDI" then
            drumItems = drumItems + 1
            Test.True(#item.take.notes > 0, "item at QN " .. item.startQN .. " has no notes")
        end
    end
    Test.Equal(drumItems, SectionsWithDrums())
end)

Test.Case("Build: MIDI generation is deterministic", function()
    local state = MockReaper.Reset()
    Builder.Build(Style)
    local first = NotesFingerprint(state)
    state = MockReaper.Reset()
    Builder.Build(Style)
    Test.Equal(NotesFingerprint(state), first)
end)

Test.Case("Build: rebuilding replaces the previous project", function()
    local state = MockReaper.Reset()
    Builder.Build(Style)
    Builder.Build(Style)
    Test.Equal(#state.tracks, ExpectedTrackCount())
    Test.Equal(CountMarkers(state, false), #SongStructure)
    Test.Equal(#state.tempoMarkers, 1)
end)

Test.Case("Build: invalid data leaves the current project untouched", function()
    local state = MockReaper.Reset()
    reaper.InsertTrackAtIndex(0)
    local layout = Test.DeepCopy(TrackLayout)
    for _, group in ipairs(layout) do
        for _, track in ipairs(group.tracks) do
            if track.id == "kick" then
                track.routing.output = "nowhere"
            end
        end
    end
    local style = Test.DeepCopy(Style)
    style.layout = layout
    Test.Raises(function() Builder.Build(style) end, "unknown destination 'nowhere'")
    Test.Equal(#state.tracks, 1)
end)


Test.Case("Build: clears the FX of REAPER's master track", function()
    local state = MockReaper.Reset()
    reaper.TrackFX_AddByName(state.master, "VST3: UADx SSL G Bus Compressor")
    reaper.TrackFX_AddByName(state.master, "VST3: UADx Ampex ATR-102 Master Tape")
    Builder.Build(Style)
    Test.Equal(#state.master.fx, 0)
    Test.True(table.concat(state.console):find("Removed from REAPER master: VST3: UADx SSL G Bus Compressor", 1, true) ~= nil)
end)

Test.Case("Build: the master processing lives on the Master Bus", function()
    local state = MockReaper.Reset()
    Builder.Build(Style)
    for _, track in ipairs(state.tracks) do
        if track.name == "Master Bus" then
            Test.Equal(#track.fx, 2)
            Test.Equal(track.fx[1].name, "VST3: UADx SSL G Bus Compressor")
            return
        end
    end
    error("No Master Bus track")
end)
