local Test = require("Test")
local MockReaper = require("MockReaper")
local FakeImGui = require("FakeImGui")
local Window = require("UI.Window")
local PluginScanner = require("PluginScanner")
local StyleLoader = require("StyleLoader")
local PresetStore = require("PresetStore")

-- Bootstrap.lua points the store to Presets/ in REAPER.
local function WithPresets(fn)
    PresetStore.SetDirectory(REPO_ROOT .. "Presets/")
    local ok, err = pcall(fn)
    PresetStore.SetDirectory(nil)
    if not ok then
        error(err, 0)
    end
end

local function Open(prepare)
    local state = MockReaper.Reset()
    if prepare then
        prepare(state)
    end
    local fake = FakeImGui.New()
    local window = Window.New()
    local function Frame()
        return window:Frame(fake.api, {})
    end
    Test.True(Frame(), "first frame")
    return window, fake, Frame, state
end

local function TextItems(state, trackName)
    for _, track in ipairs(state.tracks) do
        if track.name == trackName then
            return track.textItems or {}
        end
    end
    return {}
end

--------------------------------------------------
-- Plugin scanner
--------------------------------------------------

-- Names as REAPER lists them on the user's Mac.
local MAC = {
    "VST3i: EZdrummer 3 (Toontrack) (32 out)",
    "VST3i: EZbass (Toontrack) (2->8ch)",
    "VST3: TONEX (IK Multimedia)",
    "VST: ReaEQ (Cockos)",
    "VST: ReaComp (Cockos)",
    "VST: ReaDelay (Cockos)",
    "VST: ReaVerbate (Cockos)",
    "VSTi: ReaSynth (Cockos)",
    "VST3: UADx 1176 Rev A Compressor (Universal Audio (UADx))",
    "AU: UADx LA-2A Gray Compressor (Universal Audio (UADx))"
}

Test.Case("Scanner: matches names like REAPER", function()
    Test.True(PluginScanner.Matches("EZdrummer 3", MAC[1]))
    Test.True(PluginScanner.Matches("VST3: EZbass", MAC[2]), "VST3 also matches VST3i")
    Test.True(PluginScanner.Matches("VST: ReaSynth (Cockos)", MAC[8]), "VST also matches VSTi")
    Test.True(PluginScanner.Matches("tonex", MAC[3]), "case-insensitive")
    Test.True(not PluginScanner.Matches("AU: UADx 1176 Rev A Compressor", MAC[9]), "format must match")
    Test.True(not PluginScanner.Matches("VST3: UADx LA-2A Gray Compressor", MAC[10]))
end)

Test.Case("Scanner: reports the candidate REAPER should load", function()
    local status = {}
    WithPresets(function()
        for _, entry in ipairs(PluginScanner.Status(StyleLoader.Load("HardRock").layout, MAC)) do
            status[entry.id] = entry
        end
    end)
    Test.Equal(status.ezdrummer.status, "ok")
    Test.Equal(status.bass_bus_1176.status, "ok")
    Test.Equal(status.vocal_bus_la2a.status, "fallback")
    Test.Equal(status.vocal_bus_la2a.used, "AU: UADx LA-2A Gray Compressor")
    Test.Equal(status.drum_bus_api_2500.used, "VST: ReaComp (Cockos)")
    Test.Equal(status.drum_bus_studer.status, "skipped", "optional, not installed")
    Test.Equal(status.fx_delay_valhalla.used, "VST: ReaDelay (Cockos)")
    Test.Equal(status.ezdrummer.presetFile, true, "Presets/ has the EZdrummer state")
    Test.Equal(status.drum_bus_api_2500.preset, nil, "no preset for the stock fallback")
end)

Test.Case("Scanner: a required plugin without any candidate is missing", function()
    local status = PluginScanner.Status(StyleLoader.Load("HardRock").layout, {})
    local byId = {}
    for _, entry in ipairs(status) do
        byId[entry.id] = entry.status
    end
    Test.Equal(byId.eq, "missing")
    Test.Equal(byId.tonex_bass, "skipped")
end)

--------------------------------------------------
-- Window
--------------------------------------------------

Test.Case("Window: draws every style", function()
    local window, fake, Frame = Open()
    for index, entry in ipairs(StyleLoader.Available()) do
        fake:Set("Style", index - 1)
        Frame()
        Test.Equal(window.style.id, entry.id)
        Frame()
    end
    Test.True(fake:HasText("Time signature: 4/4"))
    fake:Set("Style", 2)
    Frame()
    Frame()
    Test.True(fake:HasText("Time signature: 12/8 (set by the style)"))
end)

Test.Case("Window: opens on the last style used", function()
    local window = Open(function(state)
        state.extState["HardRockComposer/style"] = "PunkRock"
    end)
    Test.Equal(window.style.id, "PunkRock")
    local stale = Open(function(state)
        state.extState["HardRockComposer/style"] = "Polka"
    end)
    Test.Equal(stale.style.id, "HardRock", "unknown style: Config.Style")
end)

Test.Case("Window: Generate builds the project and saves the choices", function()
    local window, fake, Frame, state = Open()
    fake:Set("Tempo (BPM, quarter note)", 150)
    Frame()
    fake:Click("Generate")
    Frame()
    Frame()
    Test.True(window.result.ok, window.result.message)
    Test.Equal(state.bpm, 150)
    Test.True(fake:HasText("Generated 7 sections."))
    Test.True(fake:HasText("Plugins: 26 loaded, 0 substituted, 0 missing"))
    Test.True(state.extState["HardRockComposer/session.HardRock"]:find("tempo=150", 1, true) ~= nil)
end)

Test.Case("Window: key, sections and target reach the generated project", function()
    local window, fake, Frame, state = Open()
    fake:Set("Key", 7) -- G
    fake:Set("A new project tab", true)
    Frame()
    fake:Click("1/x") -- remove the intro
    Frame()
    Test.Equal(window.options.sections[1].source, "verse_1")
    fake:Click("Generate")
    Frame()
    Test.Equal(state.newTabs, 1)
    Test.Equal(TextItems(state, "Chords")[1].info.P_NOTES, "G5", "verse in G")
    Test.Equal(state.markers[1].name, "Verse 1")
end)

Test.Case("Window: section buttons reorder and duplicate", function()
    local window, fake, Frame = Open()
    fake:Click("2/Up")
    Frame()
    Test.Equal(window.options.sections[1].source, "verse_1")
    fake:Click("1/+")
    Frame()
    Test.Equal(window.options.sections[2].source, "verse_1")
    fake:Set("3/##bars", 0)
    Frame()
    Test.Equal(window.options.sections[3].bars, 1, "bars are clamped")
    Test.True(fake:HasText("Length:"))
end)

Test.Case("Window: a failed generation is shown", function()
    local window, fake, Frame = Open()
    for _, section in ipairs(window.options.sections) do
        section.play = "never"
    end
    fake:Click("Generate")
    Frame()
    Frame()
    Test.True(not window.result.ok)
    Test.True(fake:HasText("Generation failed:"))
    Test.True(fake:HasText("the song has no section"))
end)

Test.Case("Window: plugin scan in the Plugins tab", function()
    local window, fake, Frame = Open(function(state)
        state.installedFX = MAC
    end)
    fake:Click("Scan installed plugins")
    WithPresets(function()
        Frame()
    end)
    Frame()
    Test.True(window.scan ~= nil)
    Test.True(fake:HasText("Fallback"))
    Test.True(fake:HasText("Presets/"))
end)

Test.Case("Window: closing saves the choices", function()
    local window, fake, Frame, state = Open()
    window.options.tempo = 133
    fake:Close()
    Test.Equal(Frame(), false)
    Test.True(state.extState["HardRockComposer/session.HardRock"]:find("tempo=133", 1, true) ~= nil)
end)

--------------------------------------------------
-- Main.lua
--------------------------------------------------

local function RunMain(withImGui)
    local state = MockReaper.Reset()
    rawset(reaper, "get_action_context", function()
        return true, REPO_ROOT .. "Main.lua"
    end)
    if withImGui then
        rawset(reaper, "ImGui_GetBuiltinPath", function()
            return TESTS_DIR .. "imgui"
        end)
    end
    local ok, err = pcall(dofile, REPO_ROOT .. "Main.lua")
    rawset(reaper, "ImGui_GetBuiltinPath", nil)
    rawset(reaper, "get_action_context", nil)
    assert(ok, err)
    return state
end

Test.Case("Main: without ReaImGui, generates directly", function()
    local state = RunMain(false)
    Test.True(#state.tracks > 0)
    Test.True(table.concat(state.console):find("[INFO] Done.", 1, true) ~= nil)
    Test.Equal(#state.deferred, 0)
end)

Test.Case("Main: with ReaImGui, opens the window and generates on click", function()
    local state = RunMain(true)
    Test.Equal(#state.tracks, 0, "nothing before the click")
    MockReaper.RunDeferred(1)
    local fake = LAST_FAKE_IMGUI
    fake:Click("Generate")
    MockReaper.RunDeferred(1)
    Test.True(#state.tracks > 0)
    fake:Close()
    MockReaper.RunDeferred(2)
    Test.Equal(#state.deferred, 0, "the loop stops when the window is closed")
end)
