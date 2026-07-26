local Reaper = {}

function Reaper.CreateTrack(name)
    local index = reaper.CountTracks(0)

    reaper.InsertTrackAtIndex(index, true)

    local track = reaper.GetTrack(0, index)

    reaper.GetSetMediaTrackInfo_String(
        track,
        "P_NAME",
        name,
        true
    )

    return track
end

return Reaper