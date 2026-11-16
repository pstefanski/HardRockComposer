local Reaper = {}

----------------------------------------------------------
-- Console & Undo
----------------------------------------------------------

function Reaper.ClearConsole()

    reaper.ClearConsole()

end

function Reaper.ShowConsoleMsg(message)

    reaper.ShowConsoleMsg(message)

end

-- Returns the button pressed: 1 OK, 2 Cancel, 6 Yes, 7 No.
-- Types: 0 OK, 1 OK/Cancel, 4 Yes/No.
function Reaper.ShowMessageBox(message, title, boxType)

    return reaper.ShowMessageBox(message, title, boxType or 0)

end

function Reaper.BeginUndo()

    reaper.Undo_BeginBlock()

end

function Reaper.EndUndo(description)

    reaper.Undo_EndBlock(description, -1)

end

----------------------------------------------------------
-- Project
----------------------------------------------------------

function Reaper.GetMasterTrack()

    return reaper.GetMasterTrack(0)

end

-- Deletes every FX of a track and returns the names of the removed FX.
function Reaper.ClearTrackFX(track)

    local removed = {}

    for index = reaper.TrackFX_GetCount(track) - 1, 0, -1 do

        local _, name = reaper.TrackFX_GetFXName(track, index, "")

        table.insert(removed, 1, name)

        reaper.TrackFX_Delete(track, index)

    end

    return removed

end

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

function Reaper.SetSendVolume(track, sendIndex, db)

    local linear = 10 ^ (db / 20)

    reaper.SetTrackSendInfo_Value(track, 0, sendIndex, "D_VOL", linear)

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

function Reaper.SetTrackTCPVisible(track, visible)

    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", visible and 1 or 0)

end

function Reaper.SetTrackSpacerAbove(track, enabled)

    reaper.SetMediaTrackInfo_Value(track, "I_SPACER", enabled and 1 or 0)

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

-- Plugin state (VST2/VST3 only), as REAPER's base64 chunk. Returns nil
-- when the state cannot be read (e.g. AU plugins).
function Reaper.GetFXState(track, index)

    local success, state = reaper.TrackFX_GetNamedConfigParm(track, index, "vst_chunk")

    if not success or state == "" then
        return nil
    end

    return state

end

function Reaper.SetFXState(track, index, state)

    return reaper.TrackFX_SetNamedConfigParm(track, index, "vst_chunk", state)

end

-- "VST3", "VST", "AU", "JS", "CLAP"...
function Reaper.GetFXType(track, index)

    local success, fxType = reaper.TrackFX_GetNamedConfigParm(track, index, "fx_type")

    return success and fxType or nil

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
-- Text items
--------------------------------------------------

-- Creates an empty item showing `text` in the arrange view.
function Reaper.CreateTextItem(track, startTime, endTime, text)

    local item = reaper.AddMediaItemToTrack(track)

    reaper.SetMediaItemInfo_Value(item, "D_POSITION", startTime)
    reaper.SetMediaItemInfo_Value(item, "D_LENGTH", endTime - startTime)
    reaper.GetSetMediaItemInfo_String(item, "P_NOTES", text, true)

    return item

end

--------------------------------------------------
-- Envelopes
--------------------------------------------------

local ACTION_TOGGLE_VOLUME_ENVELOPE = 40406

-- Returns the volume envelope of a track, creating it when needed.
function Reaper.GetVolumeEnvelope(track)

    local envelope = reaper.GetTrackEnvelopeByName(track, "Volume")

    if envelope then
        return envelope
    end

    -- The API cannot create a track envelope directly: the action
    -- "Track: Toggle track volume envelope visible" creates it on the
    -- selected track.
    reaper.SetOnlyTrackSelected(track)
    reaper.Main_OnCommand(ACTION_TOGGLE_VOLUME_ENVELOPE, 0)
    reaper.SetTrackSelected(track, false)

    envelope = reaper.GetTrackEnvelopeByName(track, "Volume")

    if not envelope then
        error("Unable to create the volume envelope")
    end

    return envelope

end

-- Adds a square point (the value holds until the next point).
function Reaper.AddEnvelopePointDB(envelope, time, db)

    local mode = reaper.GetEnvelopeScalingMode(envelope)
    local value = reaper.ScaleToEnvelopeMode(mode, 10 ^ (db / 20))

    reaper.InsertEnvelopePoint(envelope, time, value, 1, 0, false, true)

end

function Reaper.SortEnvelope(envelope)

    reaper.Envelope_SortPoints(envelope)

end

--------------------------------------------------
-- Timing
--------------------------------------------------

function Reaper.ClearTempoMarkers()

    for i = reaper.CountTempoTimeSigMarkers(0) - 1, 0, -1 do

        reaper.DeleteTempoTimeSigMarker(0, i)

    end

end

function Reaper.SetTempoAndTimeSignature(bpm, numerator, denominator)

    reaper.SetCurrentBPM(0, bpm, false)

    local success = reaper.SetTempoTimeSigMarker(0, -1, 0, -1, -1, bpm, numerator, denominator, false)

    if not success then
        error("Unable to set tempo and time signature")
    end

    reaper.UpdateTimeline()

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
