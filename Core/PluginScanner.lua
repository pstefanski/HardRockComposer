local Reaper = require("Reaper")
local Plugins = require("Plugins")
local PresetStore = require("PresetStore")

--------------------------------------------------
-- Estimates, before generating, which candidate of each plugin declaration
-- REAPER will load, by comparing the candidates with the list of installed
-- FX.
--
-- This is an estimate: the build itself (REAPER loading the plugin) is the
-- only authority. The matching mimics REAPER's: same format family when the
-- candidate names one ("VST3:" also matches "VST3i:"), then a
-- case-insensitive search of the name.
--------------------------------------------------

local PluginScanner = {}

local FAMILIES = {
    VST3 = {
        VST3 = true,
        VST3i = true
    },
    VST = {
        VST = true,
        VSTi = true,
        VST2 = true,
        VST2i = true
    },
    VST2 = {
        VST = true,
        VSTi = true,
        VST2 = true,
        VST2i = true
    },
    AU = {
        AU = true,
        AUi = true
    },
    CLAP = {
        CLAP = true,
        CLAPi = true
    },
    JS = {
        JS = true
    }
}

local function Split(name)

    local prefix, rest = name:match("^(%w+):%s*(.+)$")

    if prefix then
        return prefix, rest
    end

    return nil, name

end

function PluginScanner.Matches(candidate, installed)

    local prefix, query = Split(candidate)
    local installedPrefix, installedName = Split(installed)

    if prefix then

        local family = FAMILIES[prefix]

        if not family or not family[installedPrefix] then
            return false
        end

    end

    return installedName:lower():find(query:lower(), 1, true) ~= nil

end

local function FindInstalled(candidate, installed)

    for _, name in ipairs(installed) do

        if PluginScanner.Matches(candidate, name) then
            return name
        end

    end

    return nil

end

-- Returns one entry per plugin declaration of the layout:
--
--     { id, track, status, requested, used, installed, preset, presetFile }
--
-- status: "ok" (first candidate), "fallback" (another candidate),
--         "skipped" (optional, none found) or "missing" (required, none found).
function PluginScanner.Status(layout, installed)

    local entries = {}

    for _, group in ipairs(layout) do

        for _, track in ipairs(group.tracks) do

            for _, declaration in ipairs(track.plugins or {}) do

                local candidates = Plugins.Candidates(declaration)

                local entry = {
                    id = declaration.id,
                    track = track.name,
                    requested = candidates[1].plugin,
                    status = declaration.optional and "skipped" or "missing"
                }

                for rank, candidate in ipairs(candidates) do

                    local found = FindInstalled(candidate.plugin, installed)

                    if found then

                        entry.status = rank == 1 and "ok" or "fallback"
                        entry.used = candidate.plugin
                        entry.installed = found
                        entry.preset = candidate.preset
                        entry.presetFile = candidate.preset ~= nil and PresetStore.Load(candidate.preset) ~= nil

                        break

                    end

                end

                table.insert(entries, entry)

            end

        end

    end

    return entries

end

function PluginScanner.Scan(layout)

    return PluginScanner.Status(layout, Reaper.InstalledFX())

end

return PluginScanner
