local Reaper = require("Reaper")

local Properties = {}

function Properties.Apply(context)

    for _, entry in ipairs(context.tracks) do

        local properties = entry.data.properties

        if properties then

            if properties.volume ~= nil then
                Reaper.SetTrackVolume(entry.track, properties.volume)
            end

            if properties.pan ~= nil then
                Reaper.SetTrackPan(entry.track, properties.pan)
            end

            if properties.mute ~= nil then
                Reaper.SetTrackMute(entry.track, properties.mute)
            end

            if properties.solo ~= nil then
                Reaper.SetTrackSolo(entry.track, properties.solo)
            end

        end

    end

end

return Properties