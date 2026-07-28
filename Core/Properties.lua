local Reaper = require("Reaper")

local Properties = {}

function Properties.Apply(context)

    for _, entry in ipairs(context.tracks) do

        local data = entry.data

        if data.volume ~= nil then
            Reaper.SetTrackVolume(entry.track, data.volume)
        end

        if data.pan ~= nil then
            Reaper.SetTrackPan(entry.track, data.pan)
        end

        if data.mute ~= nil then
            Reaper.SetTrackMute(entry.track, data.mute)
        end

        if data.solo ~= nil then
            Reaper.SetTrackSolo(entry.track, data.solo)
        end

    end

end

return Properties