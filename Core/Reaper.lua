local Reaper = {}

----------------------------------------------------------
-- Project
----------------------------------------------------------

function Reaper.ResetProject()

    while reaper.CountTracks(0) > 0 do

        local track = reaper.GetTrack(0, 0)

        reaper.DeleteTrack(track)

    end

end

----------------------------------------------------------
-- Tracks
----------------------------------------------------------

function Reaper.CreateTrack(name)

    local index = reaper.CountTracks(0)

    reaper.InsertTrackAtIndex(index, true)

    local track = reaper.GetTrack(0, index)

    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)

    return track

end

----------------------------------------------------------
-- Folder
----------------------------------------------------------

function Reaper.BeginFolder(track)

    reaper.SetMediaTrackInfo_Value(track, "I_FOLDERDEPTH", 1)

end

function Reaper.EndFolder(track)

    reaper.SetMediaTrackInfo_Value(track, "I_FOLDERDEPTH", -1)

end

----------------------------------------------------------
-- Colors
----------------------------------------------------------

function Reaper.SetTrackColor(track, rgb)

    local color = reaper.ColorToNative(rgb[1], rgb[2], rgb[3])

    reaper.SetTrackColor(track, color | 0x1000000)

end

----------------------------------------------------------
-- Rounting
----------------------------------------------------------

function Reaper.CreateSend(sourceTrack, destinationTrack)

    return reaper.CreateTrackSend(sourceTrack, destinationTrack)

end

function Reaper.SetSendMode(track, sendIndex, mode)

    local modes = {
        post_fader = 0,
        pre_fx = 1,
        post_fx = 3
    }

    local value = modes[mode]

    if value == nil then

        error("Unknown send mode: " .. tostring(mode))

    end

    reaper.SetTrackSendInfo_Value(track, 0, sendIndex, "I_SENDMODE", value)

end

function Reaper.SetMainSend(track, enabled)

    reaper.SetMediaTrackInfo_Value(track, "B_MAINSEND", enabled and 1 or 0)

end

--------------------------------------------------
-- Track Properties
--------------------------------------------------

function Reaper.SetTrackVolume(track, db)

    local linear = 10 ^ (db / 20)

    reaper.SetMediaTrackInfo_Value(track, "D_VOL", linear)

end

function Reaper.SetTrackPan(track, pan)

    reaper.SetMediaTrackInfo_Value(track, "D_PAN", pan)

end

function Reaper.SetTrackMute(track, mute)

    reaper.SetMediaTrackInfo_Value(track, "B_MUTE", mute and 1 or 0)

end

function Reaper.SetTrackSolo(track, solo)

    reaper.SetMediaTrackInfo_Value(track, "I_SOLO", solo and 1 or 0)

end

--------------------------------------------------
-- FX
--------------------------------------------------

function Reaper.InsertFX(track, pluginName)

    local index = reaper.TrackFX_AddByName(track, pluginName, false, -1)

    if index < 0 then

        return nil

    end

    return {

        track = track,

        index = index

    }

end

function Reaper.GetFXName(track, index)

    local success, name = reaper.TrackFX_GetFXName(track, index, "")

    if not success then

        return nil

    end

    return name

end

function Reaper.LoadPreset(track, index, preset)

    return reaper.TrackFX_SetPreset(track, index, preset)

end

function Reaper.SetTrackChannelCount(track, channelCount)

    reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", channelCount)

end

function Reaper.MapFXOutputsToTrackChannels(track, fxIndex, channelCount)

    for channel = 0, channelCount - 1 do

        local mask = 1 << channel
        local success = reaper.TrackFX_SetPinMappings(track, fxIndex, 1, channel, mask, 0)

        if not success then

            error("Unable to map FX output pin: " .. tostring(channel))

        end

    end

end

function Reaper.CreateStereoSend(sourceTrack, destinationTrack, sourceChannel)

    local sendIndex = reaper.CreateTrackSend(sourceTrack, destinationTrack)

    if sendIndex < 0 then

        error("Unable to create audio send")

    end

    reaper.SetTrackSendInfo_Value(sourceTrack, 0, sendIndex, "I_SRCCHAN", sourceChannel)
    reaper.SetTrackSendInfo_Value(sourceTrack, 0, sendIndex, "I_DSTCHAN", 0)

    return sendIndex

end

--------------------------------------------------
-- Markers
--------------------------------------------------

function Reaper.ClearMarkers()

    local _, numMarkers, numRegions = reaper.CountProjectMarkers(0)

    for i = numMarkers + numRegions - 1, 0, -1 do

        local _, isRegion, _, _, _, index = reaper.EnumProjectMarkers(i)

        reaper.DeleteProjectMarker(0, index, isRegion)

    end

end

function Reaper.AddMarker(name, position)

    reaper.AddProjectMarker(0, false, position, 0, name, -1)

end

--------------------------------------------------
-- Regions
--------------------------------------------------

function Reaper.AddRegion(name, startTime, endTime, rgb)

    local color = 0

    if rgb then

        color = reaper.ColorToNative(rgb[1], rgb[2], rgb[3])

        color = color | 0x1000000

    end

    reaper.AddProjectMarker2(0, true, startTime, endTime, name, -1, color)

end

--------------------------------------------------
-- MIDI
--------------------------------------------------

function Reaper.CreateMidiItem(track, startQN, endQN)

    local item = reaper.CreateNewMIDIItemInProj(track, startQN, endQN, true)

    if not item then
        error("Unable to create MIDI item")
    end

    return item

end

function Reaper.GetActiveTake(item)

    return reaper.GetActiveTake(item)

end

function Reaper.InsertMidiNote(take, startPPQ, endPPQ, pitch, velocity)

    local success = reaper.MIDI_InsertNote(take, false, false, startPPQ, endPPQ, 0, pitch, velocity, false)

    if not success then
        error("Unable to insert MIDI note")
    end

end

function Reaper.SortMidi(take)

    reaper.MIDI_Sort(take)

end

--------------------------------------------------
-- Timing
--------------------------------------------------

function Reaper.SetTempo(bpm)

    reaper.SetCurrentBPM(0, bpm, true)

end

function Reaper.TimeToPPQ(take, time)

    return reaper.MIDI_GetPPQPosFromProjTime(take, time)

end

function Reaper.QNToTime(qn)

    return reaper.TimeMap2_QNToTime(0, qn)

end

function Reaper.QNToPPQ(take, qn)

    return reaper.MIDI_GetPPQPosFromProjQN(take, qn)

end

function Reaper.UpdateArrange()

    reaper.UpdateArrange()

end

return Reaper
