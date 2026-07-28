local Reaper = require("Reaper")
local Colors = require("Colors")

local Tracks = {}

function Tracks.Create(layout, context)

    for _, group in ipairs(layout) do

        --------------------------------------------------
        -- Folder
        --------------------------------------------------

        local folderTrack = Reaper.CreateTrack(group.name)

        Colors.Apply(folderTrack, group)

        Reaper.BeginFolder(folderTrack)

        table.insert(context.groups, {

            data = group,

            track = folderTrack

        })

        --------------------------------------------------
        -- Tracks
        --------------------------------------------------

        local lastTrack = nil

        for _, track in ipairs(group.tracks) do

            lastTrack = Reaper.CreateTrack(track.name)

            Colors.Apply(lastTrack, track)

            table.insert(context.tracks, {

                data = track,

                track = lastTrack,

                group = group

            })

        end

        if lastTrack then
            Reaper.EndFolder(lastTrack)
        end

    end

end

return Tracks