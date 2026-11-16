local Test = require("Test")
local StyleLoader = require("StyleLoader")

local Style = StyleLoader.Load("HardRock")
local TrackLayout = Style.layout
local SongStructure = Style.structure
local SongSettings = Style.settings
local DrumPatterns = Style.patternSets[1]
local MockReaper = require("MockReaper")
local Builder = require("Builder")
local Plugins = require("Plugins")


local function Starts(text, prefix)
    return text:sub(1, #prefix) == prefix
end

local function FindTrack(state, name)
    for _, track in ipairs(state.tracks) do
        if track.name == name then
            return track
        end
    end
    error("No track named " .. name)
end

local function ConsoleContains(state, fragment)
    for _, line in ipairs(state.console) do
        if line:find(fragment, 1, true) then
            return true
        end
    end
    return false
end

Test.Case("Plugins: a plain name inherits the declaration preset", function()
    local candidates = Plugins.Candidates({plugin = "ReaEQ", preset = "HRC EQ"})
    Test.Equal(#candidates, 1)
    Test.Equal(candidates[1].plugin, "ReaEQ")
    Test.Equal(candidates[1].preset, "HRC EQ")
end)

Test.Case("Plugins: table candidates keep their own preset", function()
    local candidates = Plugins.Candidates({
        plugin = {"VST3: A", "AU: A", {plugin = "VST: ReaComp (Cockos)"}},
        preset = "HRC A"
    })
    Test.Equal(#candidates, 3)
    Test.Equal(candidates[2].preset, "HRC A")
    Test.Equal(candidates[3].plugin, "VST: ReaComp (Cockos)")
    Test.Equal(candidates[3].preset, nil)
end)

Test.Case("Plugins: with everything installed, nothing is substituted", function()
    MockReaper.Reset()
    local context = Builder.Build(Style)
    local summary = Plugins.Summary(context)
    Test.Equal(#summary.substituted, 0)
    Test.Equal(#summary.missing, 0)
    Test.Equal(#summary.missingPresets, 0)
    Test.True(summary.loaded > 0)
end)

Test.Case("Plugins: falls back to the AU version", function()
    local state = MockReaper.Reset()
    state.isPluginMissing = function(name)
        return Starts(name, "VST3: UADx")
    end
    local context = Builder.Build(Style)
    local entry = context.registry.plugins.bass_bus_1176
    Test.Equal(entry.plugin, "AU: UADx 1176 Rev A Compressor")
    Test.Equal(FindTrack(state, "Bass Bus").fx[2].preset, "HRC Bass Bus 1176")
end)

Test.Case("Plugins: falls back to stock REAPER plugins without preset", function()
    local state = MockReaper.Reset()
    state.isPluginMissing = function(name)
        return name:find("UADx", 1, true) ~= nil
    end
    local context = Builder.Build(Style)
    local entry = context.registry.plugins.vocal_lead_1176
    Test.Equal(entry.plugin, "VST: ReaComp (Cockos)")
    Test.Equal(context.registry.plugins.fx_plate_reverb.plugin, "VST: ReaVerbate (Cockos)")

    local fx = FindTrack(state, "Vocal Bus").fx
    Test.Equal(fx[1].name, "VST: ReaComp (Cockos)")
    Test.Equal(fx[1].preset, nil)
end)

Test.Case("Plugins: optional plugins are skipped and reported", function()
    local state = MockReaper.Reset()
    state.isPluginMissing = function(name)
        return name:find("Studer", 1, true) ~= nil or name == "TONEX"
    end
    local context = Builder.Build(Style)
    Test.Equal(context.registry.plugins.drum_bus_studer, nil)
    Test.Equal(context.registry.plugins.tonex_guitar_lead, nil)
    Test.Equal(#Plugins.Summary(context).missing, 8)
    Plugins.LogSummary(context)
    Test.True(ConsoleContains(state, "[WARNING]   Skipped (optional): drum_bus_studer (VST3: UADx Studer A800 Tape Recorder)"))
end)

Test.Case("Plugins: without EZdrummer the drum MIDI is still written", function()
    local state = MockReaper.Reset()
    state.missingPlugins["EZdrummer 3"] = true
    local context = Builder.Build(Style)
    Test.Equal(context.registry.plugins.ezdrummer, nil)
    Test.Equal(#FindTrack(state, "EZD MIDI").sends, 0)
    Test.True(#state.items > 0)
end)

Test.Case("Plugins: a missing preset keeps default settings", function()
    local state = MockReaper.Reset()
    state.missingPresets["HRC Drum Bus EQ"] = true
    local context = Builder.Build(Style)
    Test.True(context.registry.plugins.eq ~= nil)
    local summary = Plugins.Summary(context)
    Test.Equal(#summary.missingPresets, 1)
    Test.Equal(summary.missingPresets[1].missingPreset, "HRC Drum Bus EQ")
    Plugins.LogSummary(context)
    Test.True(ConsoleContains(state, "[WARNING]   Not found, default settings kept: HRC Drum Bus EQ\n"))
end)

Test.Case("Plugins: a required plugin without candidates stops the build", function()
    local state = MockReaper.Reset()
    state.isPluginMissing = function(name)
        return name:find("ReaEQ", 1, true) ~= nil
    end
    Test.Raises(function() Builder.Build(Style) end, "Unable to load plugin 'eq' on track 'drum_bus' (tried 'VST: ReaEQ (Cockos)')")
end)

Test.Case("Plugins: builds on a machine with only AU UADx, no TONEX, Valhalla or HRC presets", function()
    local state = MockReaper.Reset()
    state.isPluginMissing = function(name)
        return Starts(name, "VST3: UADx") or name == "TONEX" or name:find("Valhalla", 1, true) ~= nil
    end
    state.isPresetMissing = function()
        return true
    end
    local context = Builder.Build(Style)
    local summary = Plugins.Summary(context)
    Test.Equal(#summary.missing, 6, "TONEX instances")
    Test.Equal(context.registry.plugins.fx_delay_valhalla.plugin, "VST: ReaDelay (Cockos)")
    Test.True(#summary.missingPresets > 0)
end)

Test.Case("Plugins: the summary is printed to the console", function()
    local state = MockReaper.Reset()
    state.missingPlugins["TONEX"] = true
    local context = Builder.Build(Style)
    Plugins.LogSummary(context)
    Test.True(ConsoleContains(state, "6 missing"))
    Test.True(ConsoleContains(state, "tonex_bass (TONEX), tonex_bass_distortion (TONEX)"))
end)

Test.Case("Plugins: the build itself logs nothing, the summary has one line per category", function()
    local state = MockReaper.Reset()
    state.missingPlugins["TONEX"] = true
    state.isPluginMissing = function(name)
        return name:find("Valhalla", 1, true) ~= nil
    end
    state.isPresetMissing = function()
        return true
    end
    local context = Builder.Build(Style)
    Test.Equal(#state.console, 0, "console during the build")

    Plugins.LogSummary(context)
    Test.Equal(#state.console, 5, table.concat(state.console))
    Test.True(ConsoleContains(state, "Plugins: 19 loaded, 1 substituted, 6 missing"))
    Test.True(ConsoleContains(state, "Presets: 0 loaded, 0 from Presets/, 18 not found"))
end)
