local Reaper = require("Reaper")

local Plugins = {}

--------------------------------------------------
-- Private
--------------------------------------------------

local function CreatePluginEntry(pluginData, trackEntry, fx, name)

    return {

        data = pluginData,

        track = trackEntry,

        fx = fx,

        name = name

    }

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

--------------------------------------------------
-- Public
--------------------------------------------------

function Plugins.Apply(context)

    for _, trackEntry in ipairs(context.tracks) do

        local plugins = trackEntry.data.plugins

        if plugins then

            for _, pluginData in ipairs(plugins) do

                if not pluginData.id or not pluginData.plugin then

                    error("Invalid plugin declaration on track: " .. trackEntry.data.id)

                end

                if context.registry.plugins[pluginData.id] then

                    error("Duplicate plugin id: " .. pluginData.id)

                end

                local fx = Reaper.InsertFX(trackEntry.track, pluginData.plugin)

                if not fx then

                    error("Unable to load plugin '" .. pluginData.plugin .. "' on track: " .. trackEntry.data.id)

                end

                if pluginData.preset and not Reaper.LoadPreset(trackEntry.track, fx.index, pluginData.preset) then

                    error("Unable to load preset '" .. pluginData.preset .. "' for plugin: " .. pluginData.id)

                end

                local name = Reaper.GetFXName(trackEntry.track, fx.index)

                local pluginEntry = CreatePluginEntry(pluginData, trackEntry, fx, name)

                context.registry.plugins[pluginData.id] = pluginEntry

                ConfigureOutputs(context, pluginData, trackEntry, fx)

            end

        end

    end

end

return Plugins
