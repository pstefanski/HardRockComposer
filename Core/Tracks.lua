local Reaper = require("Reaper")

local Tracks = {}

function Tracks.Create(layout)

    for _, folder in ipairs(layout) do

        Reaper.CreateTrack(folder.folder)

        for _, trackName in ipairs(folder.tracks) do
            Reaper.CreateTrack(trackName)
        end

    end

end

return Tracks