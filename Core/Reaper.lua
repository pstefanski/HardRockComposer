local Reaper = {}

----------------------------------------------------------
-- Project
----------------------------------------------------------

function Reaper.ResetProject()

    while reaper.CountTracks(0) > 0 do

        local track = reaper.GetTrack(0,0)

        reaper.DeleteTrack(track)

    end

end

----------------------------------------------------------
-- Tracks
----------------------------------------------------------

function Reaper.CreateTrack(name)

    local index = reaper.CountTracks(0)

    reaper.InsertTrackAtIndex(index,true)

    local track = reaper.GetTrack(0,index)

    reaper.GetSetMediaTrackInfo_String(
        track,
        "P_NAME",
        name,
        true
    )

    return track

end

----------------------------------------------------------
-- Folder
----------------------------------------------------------

function Reaper.BeginFolder(track)

    reaper.SetMediaTrackInfo_Value(
        track,
        "I_FOLDERDEPTH",
        1
    )

end

function Reaper.EndFolder(track)

    reaper.SetMediaTrackInfo_Value(
        track,
        "I_FOLDERDEPTH",
        -1
    )

end

----------------------------------------------------------
-- Colors
----------------------------------------------------------

function Reaper.SetTrackColor(track, rgb)

    local color = reaper.ColorToNative(
        rgb[1],
        rgb[2],
        rgb[3]
    )

    reaper.SetTrackColor(
        track,
        color | 0x1000000
    )

end

----------------------------------------------------------
-- Rounting
----------------------------------------------------------

function Reaper.CreateSend(sourceTrack, destinationTrack)

    return reaper.CreateTrackSend(
        sourceTrack,
        destinationTrack
    )

end

function Reaper.SetMainSend(track, enabled)

    reaper.SetMediaTrackInfo_Value(
        track,
        "B_MAINSEND",
        enabled and 1 or 0
    )

end

return Reaper