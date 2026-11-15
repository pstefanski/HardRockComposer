local Reaper = require("Reaper")
local Logger = require("Logger")

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
-- A missing preset only produces a warning. A plugin that cannot be loaded
-- stops the build, unless it is declared `optional`.
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

        Logger.Warning("Optional plugin skipped: " .. pluginData.id .. " (tried " .. CandidateNames(candidates) .. ")")

        return

    end

    reportEntry.status = rank == 1 and "loaded" or "substituted"
    reportEntry.used = candidate.plugin

    if candidate.preset and not Reaper.LoadPreset(trackEntry.track, fx.index, candidate.preset) then

        reportEntry.missingPreset = candidate.preset

        Logger.Warning("Preset '" .. candidate.preset .. "' not found for " .. pluginData.id ..
                           ": default settings kept")

    end

    context.registry.plugins[pluginData.id] = {

        data = pluginData,

        track = trackEntry,

        fx = fx,

        name = Reaper.GetFXName(trackEntry.track, fx.index),

        plugin = candidate.plugin

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

        if entry.missingPreset then

            table.insert(summary.missingPresets, entry)

        end

    end

    return summary

end

function Plugins.LogSummary(context)

    local summary = Plugins.Summary(context)

    Logger.Info(string.format("Plugins: %d loaded, %d substituted, %d missing, %d preset(s) missing", summary.loaded,
        #summary.substituted, #summary.missing, #summary.missingPresets))

    for _, entry in ipairs(summary.substituted) do

        Logger.Info("  substituted  " .. entry.id .. ": " .. entry.requested .. " -> " .. entry.used)

    end

    for _, entry in ipairs(summary.missing) do

        Logger.Info("  missing      " .. entry.id .. ": " .. entry.requested)

    end

    for _, entry in ipairs(summary.missingPresets) do

        Logger.Info("  no preset    " .. entry.id .. ": " .. entry.missingPreset)

    end

end

return Plugins
