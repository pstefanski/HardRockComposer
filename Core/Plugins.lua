local Reaper = require("Reaper")
local Logger = require("Logger")
local PresetStore = require("PresetStore")

--------------------------------------------------
-- Inserts the plugins declared on each track.
--
-- A declaration can list several candidates; the first one REAPER can load
-- wins:
--
--     plugin = {
--         "VST3: UADx 1176 Rev A Compressor",      -- inherits `preset`
--         "AU: UADx 1176 Rev A Compressor",        -- inherits `preset`
--         { plugin = "VST: ReaComp (Cockos)" }     -- own preset (none here)
--     },
--     preset = "HRC Bass Bus 1176",
--     optional = true
--
-- Presets are looked up in REAPER first, then in the repository (Presets/,
-- see PresetStore and ExportPresets.lua). A missing preset keeps the
-- default settings. A plugin that cannot be
-- loaded stops the build, unless it is declared `optional`. Nothing is
-- logged while plugins load: everything is summarized at the end of the
-- build (LogSummary).
--------------------------------------------------

local Plugins = {}

--------------------------------------------------
-- Private
--------------------------------------------------

-- Normalizes a declaration into a list of { plugin, preset } candidates.
function Plugins.Candidates(pluginData)

    local declared = pluginData.plugin

    if type(declared) ~= "table" then

        declared = {declared}

    end

    local candidates = {}

    for _, candidate in ipairs(declared) do

        if type(candidate) == "table" then

            table.insert(candidates, {
                plugin = candidate.plugin,
                preset = candidate.preset
            })

        else

            table.insert(candidates, {
                plugin = candidate,
                preset = pluginData.preset
            })

        end

    end

    return candidates

end

local function InsertFirstAvailable(track, candidates)

    for index, candidate in ipairs(candidates) do

        local fx = Reaper.InsertFX(track, candidate.plugin)

        if fx then

            return fx, candidate, index

        end

    end

    return nil

end

local function CandidateNames(candidates)

    local names = {}

    for _, candidate in ipairs(candidates) do

        table.insert(names, "'" .. candidate.plugin .. "'")

    end

    return table.concat(names, ", ")

end

-- Applies the state saved in Presets/ when it was exported from the same
-- plugin, in the same format.
local function LoadStoredPreset(track, fx, candidate)

    local stored = PresetStore.Load(candidate.preset)

    if not stored or stored.plugin ~= candidate.plugin then
        return false
    end

    if stored.fx_type ~= Reaper.GetFXType(track, fx.index) then
        return false
    end

    return Reaper.SetFXState(track, fx.index, stored.state) == true

end

local function ConfigureOutputs(context, pluginData, trackEntry, fx)

    if not pluginData.outputChannels then

        return

    end

    if pluginData.outputChannels % 2 ~= 0 then

        error("Plugin output channel count must be even: " .. pluginData.id)

    end

    Reaper.SetTrackChannelCount(trackEntry.track, pluginData.outputChannels)
    Reaper.MapFXOutputsToTrackChannels(trackEntry.track, fx.index, pluginData.outputChannels)
    Reaper.SetMainSend(trackEntry.track, false)

    for _, output in ipairs(pluginData.outputs or {}) do

        local destination = context.registry.tracks[output.destination]

        if not destination then

            error("Unknown plugin output destination: " .. tostring(output.destination))

        end

        if type(output.pair) ~= "number" or output.pair % 1 ~= 0 then

            error("Invalid plugin output pair: " .. tostring(output.pair))

        end

        local sourceChannel = (output.pair - 1) * 2

        if output.pair < 1 or sourceChannel + 2 > pluginData.outputChannels then

            error("Invalid plugin output pair: " .. tostring(output.pair))

        end

        Reaper.CreateStereoSend(trackEntry.track, destination.track, sourceChannel)

    end

end

local function ApplyPlugin(context, trackEntry, pluginData)

    if not pluginData.id or not pluginData.plugin then

        error("Invalid plugin declaration on track: " .. trackEntry.data.id)

    end

    if context.registry.plugins[pluginData.id] then

        error("Duplicate plugin id: " .. pluginData.id)

    end

    local candidates = Plugins.Candidates(pluginData)

    local reportEntry = {
        id = pluginData.id,
        track = trackEntry.data.id,
        requested = candidates[1].plugin
    }

    table.insert(context.report.plugins, reportEntry)

    local fx, candidate, rank = InsertFirstAvailable(trackEntry.track, candidates)

    if not fx then

        if not pluginData.optional then

            error("Unable to load plugin '" .. pluginData.id .. "' on track '" .. trackEntry.data.id ..
                      "' (tried " .. CandidateNames(candidates) .. ")", 0)

        end

        reportEntry.status = "missing"

        return

    end

    reportEntry.status = rank == 1 and "loaded" or "substituted"
    reportEntry.used = candidate.plugin

    if candidate.preset then

        reportEntry.preset = candidate.preset

        if Reaper.LoadPreset(trackEntry.track, fx.index, candidate.preset) then

            reportEntry.presetStatus = "loaded"

        elseif LoadStoredPreset(trackEntry.track, fx, candidate) then

            reportEntry.presetStatus = "file"

        else

            reportEntry.presetStatus = "missing"
            reportEntry.missingPreset = candidate.preset

        end

    end

    context.registry.plugins[pluginData.id] = {

        data = pluginData,

        track = trackEntry,

        fx = fx,

        name = Reaper.GetFXName(trackEntry.track, fx.index),

        plugin = candidate.plugin,

        preset = candidate.preset,

        presetStatus = reportEntry.presetStatus

    }

    ConfigureOutputs(context, pluginData, trackEntry, fx)

end

--------------------------------------------------
-- Public
--------------------------------------------------

function Plugins.Apply(context)

    context.report = context.report or {}
    context.report.plugins = {}

    for _, trackEntry in ipairs(context.tracks) do

        for _, pluginData in ipairs(trackEntry.data.plugins or {}) do

            ApplyPlugin(context, trackEntry, pluginData)

        end

    end

end

-- Counts the report entries by status.
function Plugins.Summary(context)

    local summary = {
        loaded = 0,
        substituted = {},
        missing = {},
        presetsLoaded = 0,
        presetsFromFile = 0,
        missingPresets = {}
    }

    for _, entry in ipairs((context.report or {}).plugins or {}) do

        if entry.status == "loaded" then

            summary.loaded = summary.loaded + 1

        elseif entry.status == "substituted" then

            table.insert(summary.substituted, entry)

        elseif entry.status == "missing" then

            table.insert(summary.missing, entry)

        end

        if entry.presetStatus == "loaded" then

            summary.presetsLoaded = summary.presetsLoaded + 1

        elseif entry.presetStatus == "file" then

            summary.presetsFromFile = summary.presetsFromFile + 1

        elseif entry.presetStatus == "missing" then

            table.insert(summary.missingPresets, entry)

        end

    end

    return summary

end

local function Join(entries, format)

    local parts = {}

    for _, entry in ipairs(entries) do
        table.insert(parts, format(entry))
    end

    return table.concat(parts, ", ")

end

-- One line per category.
function Plugins.LogSummary(context)

    local summary = Plugins.Summary(context)

    Logger.Info(string.format("Plugins: %d loaded, %d substituted, %d missing", summary.loaded,
        #summary.substituted, #summary.missing))

    if #summary.substituted > 0 then

        Logger.Info("  Substituted: " .. Join(summary.substituted, function(entry)
            return entry.id .. " (" .. entry.requested .. " -> " .. entry.used .. ")"
        end))

    end

    if #summary.missing > 0 then

        Logger.Warning("  Skipped (optional): " .. Join(summary.missing, function(entry)
            return entry.id .. " (" .. entry.requested .. ")"
        end))

    end

    local presetCount = summary.presetsLoaded + summary.presetsFromFile + #summary.missingPresets

    if presetCount > 0 then

        Logger.Info(string.format("Presets: %d loaded, %d from Presets/, %d not found", summary.presetsLoaded,
            summary.presetsFromFile, #summary.missingPresets))

    end

    if #summary.missingPresets > 0 then

        Logger.Warning("  Not found, default settings kept: " .. Join(summary.missingPresets, function(entry)
            return entry.missingPreset
        end))

    end

end

return Plugins
