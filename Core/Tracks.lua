local Reaper = require("Reaper")
local Colors = require("Colors")

local Tracks = {}

function Tracks.Create(layout)

    for _, group in ipairs(layout) do

        local folder = Reaper.CreateTrack(group.name)
        Colors.Apply(folder, group)

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