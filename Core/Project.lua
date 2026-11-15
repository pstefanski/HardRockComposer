local Reaper = require("Reaper")
local Logger = require("Logger")

local Project = {}

--------------------------------------------------
-- Prepares the project before any other stage: optionally deletes the
-- existing tracks and the FX of REAPER's master track, removes previous
-- markers/regions and tempo markers, then applies the song tempo and time
-- signature.
--
-- Mix processing belongs to the Master Bus track: REAPER's master track
-- stays clean.
--
-- This stage must run before Markers, Regions and Arrangement, because
-- every bar → time conversion depends on the tempo map.
--------------------------------------------------

function Project.Apply(settings, config)

    if config and config.ResetProject then

        Reaper.ResetProject()

        local removed = Reaper.ClearTrackFX(Reaper.GetMasterTrack())

        for _, name in ipairs(removed) do

            Logger.Warning("Removed from REAPER master: " .. tostring(name))

        end

    end

    Reaper.ClearMarkers()

    Reaper.ClearTempoMarkers()

    Reaper.SetTempoAndTimeSignature(settings.tempo, settings.beats_per_bar, settings.beat_unit)

end

return Project
