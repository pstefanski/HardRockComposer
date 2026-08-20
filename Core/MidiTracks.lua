local Reaper = require("Reaper")

local MidiTracks = {}

function MidiTracks.Create(name)

    local track = Reaper.CreateTrack(name)

    return track

end

return MidiTracks
