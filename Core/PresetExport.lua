local Reaper = require("Reaper")
local PresetStore = require("PresetStore")

--------------------------------------------------
-- Saves the state of every plugin whose HRC preset was loaded during the
-- build into Presets/ (see PresetStore).
--------------------------------------------------

local PresetExport = {}

-- Returns one result per plugin declaring a preset:
--     { id, preset, file }            exported
--     { id, preset, reason }          skipped
function PresetExport.Export(context)

    local results = {}

    for _, entry in ipairs(context.report.plugins) do

        local plugin = context.registry.plugins[entry.id]

        if plugin and plugin.preset then

            local result = {
                id = entry.id,
                preset = plugin.preset
            }

            local track = plugin.track.track
            local index = plugin.fx.index

            if plugin.presetStatus ~= "loaded" and plugin.presetStatus ~= "file" then

                result.reason = "preset not found in REAPER"

            else

                local state = Reaper.GetFXState(track, index)
                local fxType = Reaper.GetFXType(track, index)

                if not state then

                    result.reason = "plugin state not readable (" .. tostring(fxType) .. ")"

                else

                    local file, message = PresetStore.Save({
                        preset = plugin.preset,
                        plugin = plugin.plugin,
                        fx_type = fxType,
                        state = state
                    })

                    result.file = file
                    result.reason = message

                end

            end

            table.insert(results, result)

        end

    end

    return results

end

return PresetExport
