local Reaper = require("Reaper")

local Tracks = {}

function Tracks.Create(layout)

    for _, group in ipairs(layout) do

        local folder = Reaper.CreateTrack(group.folder)

        Reaper.BeginFolder(folder)

        local lastTrack

        for _, trackName in ipairs(group.tracks) do

            lastTrack = Reaper.CreateTrack(trackName)

        end

        if lastTrack then
            Reaper.EndFolder(lastTrack)
        end

    end

end

return Tracks