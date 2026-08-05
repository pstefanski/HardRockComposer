local Reaper = require("Reaper")

local Plugins = {}

--------------------------------------------------
-- Private
--------------------------------------------------

local function CreatePluginEntry(pluginData, trackEntry, fx)

    return {

        data = pluginData,

        track = trackEntry,

        fx = fx

    }

end

--------------------------------------------------
-- Public
--------------------------------------------------

function Plugins.Apply(context)

    for _, trackEntry in ipairs(context.tracks) do

        local plugins = trackEntry.data.plugins

        if plugins then

            for _, pluginData in ipairs(plugins) do

                local fx = Reaper.InsertFX(
                    trackEntry.track,
                    pluginData.plugin
                )

                local pluginEntry = CreatePluginEntry(
                    pluginData,
                    trackEntry,
                    fx
                )

                context.registry.plugins[pluginData.id] = pluginEntry

            end

        end

    end

end

return Plugins