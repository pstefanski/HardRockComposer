local Test = require("Test")
local MockReaper = require("MockReaper")
local Builder = require("Builder")
local Plugins = require("Plugins")
local PresetStore = require("PresetStore")
local PresetExport = require("PresetExport")
local StyleLoader = require("StyleLoader")

local Style = StyleLoader.Load("HardRock")

local function TempDirectory()
    local path = os.tmpname()
    os.remove(path)
    assert(os.execute('mkdir -p "' .. path .. '"'))
    return path .. "/"
end

local function Files(directory)
    local files = {}
    local listing = io.popen('ls "' .. directory .. '"')
    for name in listing:lines() do
        table.insert(files, name)
    end
    listing:close()
    return files
end

local function FindFX(state, trackName, index)
    for _, track in ipairs(state.tracks) do
        if track.name == trackName then
            return track.fx[index]
        end
    end
    error("No track " .. trackName)
end

-- The store is shared module state: always leave it disabled.
local function WithStore(directory, fn)
    PresetStore.SetDirectory(directory)
    local ok, err = pcall(fn)
    PresetStore.SetDirectory(nil)
    if not ok then
        error(err, 0)
    end
end

Test.Case("Presets: file names are derived from preset names", function()
    Test.Equal(PresetStore.FileName("HRC Bass Bus 1176"), "HRC_Bass_Bus_1176.lua")
    Test.Equal(PresetStore.FileName("HRC Vocal Bus LA-2A"), "HRC_Vocal_Bus_LA-2A.lua")
end)

Test.Case("Presets: save and load round trip", function()
    WithStore(TempDirectory(), function()
        local entry = {
            preset = "HRC Test",
            plugin = "VST3: Test",
            fx_type = "VST3",
            state = "abc+/=\n\"quoted\""
        }
        Test.True(PresetStore.Save(entry))
        local loaded = PresetStore.Load("HRC Test")
        Test.Equal(loaded.state, entry.state)
        Test.Equal(loaded.plugin, "VST3: Test")
        Test.Equal(PresetStore.Load("HRC Unknown"), nil)
    end)
end)

Test.Case("Presets: files can only return data", function()
    local directory = TempDirectory()
    WithStore(directory, function()
        local file = io.open(directory .. "HRC_Evil.lua", "w")
        file:write('os.execute("echo pwned") return { preset = "HRC Evil", state = "x" }')
        file:close()
        Test.Equal(PresetStore.Load("HRC Evil"), nil)
    end)
end)

Test.Case("Presets: export saves every loaded HRC preset", function()
    local directory = TempDirectory()
    WithStore(directory, function()
        MockReaper.Reset()
        local context = Builder.Build(Style)
        local results = PresetExport.Export(context)
        local summary = Plugins.Summary(context)
        Test.Equal(#results, summary.presetsLoaded)
        for _, result in ipairs(results) do
            Test.True(result.file ~= nil, result.preset .. ": " .. tostring(result.reason))
        end
        Test.Equal(#Files(directory), #results)
        Test.Equal(PresetStore.Load("HRC Bass Bus 1176").state,
            "state:VST3: UADx 1176 Rev A Compressor:HRC Bass Bus 1176")
    end)
end)

Test.Case("Presets: export skips presets REAPER does not know and unreadable states", function()
    WithStore(TempDirectory(), function()
        local state = MockReaper.Reset()
        state.missingPresets["HRC Drum Bus EQ"] = true
        state.isPluginMissing = function(name)
            return name == "VST3: UADx Pultec EQP-1A EQ"
        end
        local results = PresetExport.Export(Builder.Build(Style))
        local reasons = {}
        for _, result in ipairs(results) do
            reasons[result.preset] = result.reason
        end
        Test.Equal(reasons["HRC Drum Bus EQ"], "preset not found in REAPER")
        Test.Equal(reasons["HRC Vocal Bus Pultec"], "plugin state not readable (AU)")
    end)
end)

Test.Case("Presets: a machine without the HRC presets uses the exported states", function()
    WithStore(TempDirectory(), function()
        -- Machine with the presets: export.
        MockReaper.Reset()
        PresetExport.Export(Builder.Build(Style))

        -- Machine without them: the stored states are applied.
        local state = MockReaper.Reset()
        state.isPresetMissing = function()
            return true
        end
        local context = Builder.Build(Style)
        local summary = Plugins.Summary(context)
        Test.Equal(#summary.missingPresets, 0)
        Test.True(summary.presetsFromFile > 0)
        Test.Equal(FindFX(state, "Bass Bus", 2).state, "state:VST3: UADx 1176 Rev A Compressor:HRC Bass Bus 1176")
        Test.Equal(context.registry.plugins.bass_bus_1176.presetStatus, "file")

        Plugins.LogSummary(context)
        Test.True(table.concat(state.console):find(summary.presetsFromFile .. " from Presets/", 1, true) ~= nil)
    end)
end)

Test.Case("Presets: a state is only applied to the same plugin and format", function()
    WithStore(TempDirectory(), function()
        MockReaper.Reset()
        PresetExport.Export(Builder.Build(Style))

        -- Only the AU version of the UADx plugins is installed.
        local state = MockReaper.Reset()
        state.isPresetMissing = function()
            return true
        end
        state.isPluginMissing = function(name)
            return name:sub(1, 10) == "VST3: UADx"
        end
        local context = Builder.Build(Style)
        Test.Equal(context.registry.plugins.bass_bus_1176.plugin, "AU: UADx 1176 Rev A Compressor")
        Test.Equal(context.registry.plugins.bass_bus_1176.presetStatus, "missing")
        Test.Equal(FindFX(state, "Bass Bus", 2).state, nil)
    end)
end)
