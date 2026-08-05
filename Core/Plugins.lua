local Reaper = require("Reaper")

local Plugins = {}

function Plugins.Apply(context)

    for _, entry in ipairs(context.tracks) do

        local plugins = entry.data.plugins

        if plugins then

            for _, plugin in ipairs(plugins) do

                Reaper.InsertFX(
                    entry.track,
                    plugin.plugin
                )

            end

        end

    end

end

return Plugins