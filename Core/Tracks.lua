local Reaper = require("Reaper")
local Colors = require("Colors")

local Tracks = {}

function Tracks.Create(layout)

    for _, group in ipairs(layout) do

        local folder = Reaper.CreateTrack(group.folder)

        Colors.Apply(folder, {
            color = group.tracks[1].color
        })

        Reaper.BeginFolder(folder)

        local lastTrack = nil

        for _, track in ipairs(group.tracks) do

            lastTrack = Reaper.CreateTrack(track.name)
            Colors.Apply(lastTrack, track)

        end

        if lastTrack then
            Reaper.EndFolder(lastTrack)
        end

    end

end

return Tracks