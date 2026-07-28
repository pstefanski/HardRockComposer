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

        local groupEntry = {
            data = group,
            track = folderTrack
        }

        table.insert(context.groups, groupEntry)
        context.registry.groups[group.id] = groupEntry

        --------------------------------------------------
        -- Tracks
        --------------------------------------------------

        local lastTrack = nil

        for _, track in ipairs(group.tracks) do

            lastTrack = Reaper.CreateTrack(track.name)

            Colors.Apply(lastTrack, track)

            local trackEntry = {
                data = track,
                track = lastTrack,
                group = groupEntry
            }

            table.insert(context.tracks, trackEntry)
            context.registry.tracks[track.id] = trackEntry

        end

        if lastTrack then
            Reaper.EndFolder(lastTrack)
        end

    end

end

return Tracks