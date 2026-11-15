local Reaper = require("Reaper")

local Project = {}

--------------------------------------------------
-- Prepares the project before any other stage: optionally deletes the
-- existing tracks, removes previous markers/regions and tempo markers,
-- then applies the song tempo and time signature.
--
-- This stage must run before Markers, Regions and Arrangement, because
-- every bar → time conversion depends on the tempo map.
--------------------------------------------------

function Project.Apply(settings, config)

    if config and config.ResetProject then

        Reaper.ResetProject()

    end

    Reaper.ClearMarkers()

    Reaper.ClearTempoMarkers()

    Reaper.SetTempoAndTimeSignature(settings.tempo, settings.beats_per_bar, settings.beat_unit)

end

return Project
