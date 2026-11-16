--------------------------------------------------
-- In-memory stand-in for the REAPER API.
--
-- Only the functions used by Core/Reaper.lua are implemented. Every call
-- updates a plain Lua state that tests can inspect.
--------------------------------------------------

local MockReaper = {}

local PPQ = 960

local state

function MockReaper.Reset()

    state = {
        console = {},
        tracks = {},
        master = {
            name = "MASTER",
            info = {},
            sends = {},
            fx = {}
        },
        markers = {},
        tempoMarkers = {},
        bpm = 120,
        items = {},
        -- Simulate the machine: exact names, or predicates for whole families.
        missingPlugins = {},
        missingPresets = {},
        isPluginMissing = function()
            return false
        end,
        isPresetMissing = function()
            return false
        end,
        nextMarkerIndex = 1
    }

    return state

end

function MockReaper.State()

    return state

end

local function QNToTime(qn)

    -- The mock only supports a single, constant tempo.
    return qn * 60 / state.bpm

end

local function IndexOf(track)

    for index, candidate in ipairs(state.tracks) do

        if candidate == track then
            return index
        end

    end

    error("Unknown mock track")

end

local api = {}

--------------------------------------------------
-- Console & undo
--------------------------------------------------

function api.ClearConsole()
    state.console = {}
end

function api.ShowConsoleMsg(message)
    table.insert(state.console, message)
end

function api.Undo_BeginBlock()
end

function api.Undo_EndBlock()
end

--------------------------------------------------
-- Tracks
--------------------------------------------------

function api.CountTracks()
    return #state.tracks
end

function api.GetTrack(_, index)
    return state.tracks[index + 1]
end

function api.InsertTrackAtIndex(index)
    table.insert(state.tracks, index + 1, {
        name = "",
        info = {},
        sends = {},
        fx = {}
    })
end

function api.DeleteTrack(track)
    table.remove(state.tracks, IndexOf(track))
end

function api.GetSetMediaTrackInfo_String(track, key, value, set)
    if key == "P_NAME" and set then
        track.name = value
    end
    return true, track.name
end

function api.SetMediaTrackInfo_Value(track, key, value)
    track.info[key] = value
    return true
end

function api.ColorToNative(r, g, b)
    return r | (g << 8) | (b << 16)
end

function api.SetTrackColor(track, color)
    track.color = color
end

--------------------------------------------------
-- Sends
--------------------------------------------------

function api.CreateTrackSend(source, destination)
    table.insert(source.sends, {
        destination = destination,
        info = {}
    })
    return #source.sends - 1
end

function api.SetTrackSendInfo_Value(track, _, sendIndex, key, value)
    track.sends[sendIndex + 1].info[key] = value
    return true
end

--------------------------------------------------
-- FX
--------------------------------------------------

function api.TrackFX_AddByName(track, name)
    if state.missingPlugins[name] or state.isPluginMissing(name) then
        return -1
    end
    table.insert(track.fx, {
        name = name,
        pins = {}
    })
    return #track.fx - 1
end

function api.GetMasterTrack()
    return state.master
end

function api.TrackFX_GetCount(track)
    return #track.fx
end

function api.TrackFX_Delete(track, index)
    table.remove(track.fx, index + 1)
    return true
end

function api.TrackFX_GetFXName(track, index)
    return true, track.fx[index + 1].name
end

function api.TrackFX_SetPreset(track, index, preset)
    if state.missingPresets[preset] or state.isPresetMissing(preset) then
        return false
    end
    track.fx[index + 1].preset = preset
    return true
end

function api.TrackFX_SetPinMappings(track, index, isOutput, pin, low)
    track.fx[index + 1].pins[pin] = low
    return true
end

--------------------------------------------------
-- Markers & regions
--------------------------------------------------

local function AddMarker(isRegion, position, regionEnd, name, color)
    table.insert(state.markers, {
        isRegion = isRegion,
        position = position,
        regionEnd = regionEnd,
        name = name,
        color = color,
        index = state.nextMarkerIndex
    })
    state.nextMarkerIndex = state.nextMarkerIndex + 1
end

function api.CountProjectMarkers()
    local markers, regions = 0, 0
    for _, marker in ipairs(state.markers) do
        if marker.isRegion then
            regions = regions + 1
        else
            markers = markers + 1
        end
    end
    return markers + regions, markers, regions
end

function api.EnumProjectMarkers(i)
    local marker = state.markers[i + 1]
    if not marker then
        return 0
    end
    return i + 1, marker.isRegion, marker.position, marker.regionEnd, marker.name, marker.index
end

function api.DeleteProjectMarker(_, index, isRegion)
    for position, marker in ipairs(state.markers) do
        if marker.index == index and marker.isRegion == isRegion then
            table.remove(state.markers, position)
            return true
        end
    end
    return false
end

function api.AddProjectMarker(_, isRegion, position, regionEnd, name)
    AddMarker(isRegion, position, regionEnd, name, 0)
end

function api.AddProjectMarker2(_, isRegion, position, regionEnd, name, _, color)
    AddMarker(isRegion, position, regionEnd, name, color)
end

--------------------------------------------------
-- Text items & envelopes
--------------------------------------------------

function api.AddMediaItemToTrack(track)
    local item = {
        track = track,
        info = {}
    }
    track.textItems = track.textItems or {}
    table.insert(track.textItems, item)
    return item
end

function api.SetMediaItemInfo_Value(item, key, value)
    item.info[key] = value
    return true
end

function api.GetSetMediaItemInfo_String(item, key, value, set)
    if set then
        item.info[key] = value
    end
    return true, item.info[key]
end

function api.GetTrackEnvelopeByName(track, name)
    return track.envelopes and track.envelopes[name]
end

function api.SetOnlyTrackSelected(track)
    state.selectedTrack = track
end

function api.SetTrackSelected(track, selected)
    if not selected and state.selectedTrack == track then
        state.selectedTrack = nil
    end
end

function api.Main_OnCommand(command)
    if command == 40406 and state.selectedTrack then
        local track = state.selectedTrack
        track.envelopes = track.envelopes or {}
        track.envelopes.Volume = track.envelopes.Volume or {
            points = {}
        }
    end
end

function api.GetEnvelopeScalingMode()
    return 0
end

function api.ScaleToEnvelopeMode(_, value)
    return value
end

function api.InsertEnvelopePoint(envelope, time, value, shape)
    table.insert(envelope.points, {
        time = time,
        value = value,
        shape = shape
    })
    return true
end

function api.Envelope_SortPoints(envelope)
    table.sort(envelope.points, function(a, b)
        return a.time < b.time
    end)
    return true
end

--------------------------------------------------
-- Tempo
--------------------------------------------------

function api.CountTempoTimeSigMarkers()
    return #state.tempoMarkers
end

function api.DeleteTempoTimeSigMarker(_, index)
    table.remove(state.tempoMarkers, index + 1)
    return true
end

function api.SetCurrentBPM(_, bpm)
    state.bpm = bpm
end

function api.SetTempoTimeSigMarker(_, _, position, _, _, bpm, numerator, denominator)
    table.insert(state.tempoMarkers, {
        position = position,
        bpm = bpm,
        numerator = numerator,
        denominator = denominator
    })
    state.bpm = bpm
    return true
end

function api.UpdateTimeline()
end

function api.UpdateArrange()
end

function api.TimeMap2_QNToTime(_, qn)
    return QNToTime(qn)
end

--------------------------------------------------
-- MIDI
--------------------------------------------------

function api.CreateNewMIDIItemInProj(track, startQN, endQN)
    local item = {
        track = track,
        startQN = startQN,
        endQN = endQN
    }
    item.take = {
        item = item,
        notes = {}
    }
    table.insert(state.items, item)
    return item
end

function api.GetActiveTake(item)
    return item.take
end

function api.MIDI_GetPPQPosFromProjQN(take, qn)
    return (qn - take.item.startQN) * PPQ
end

function api.MIDI_GetPPQPosFromProjTime(take, time)
    return api.MIDI_GetPPQPosFromProjQN(take, time * state.bpm / 60)
end

function api.MIDI_InsertNote(take, _, _, startPPQ, endPPQ, _, pitch, velocity)
    table.insert(take.notes, {
        startPPQ = startPPQ,
        endPPQ = endPPQ,
        pitch = pitch,
        velocity = velocity
    })
    return true
end

function api.MIDI_Sort(take)
    table.sort(take.notes, function(a, b)
        if a.startPPQ == b.startPPQ then
            return a.pitch < b.pitch
        end
        return a.startPPQ < b.startPPQ
    end)
end

--------------------------------------------------

-- Fail loudly when the engine uses an API function the mock lacks.
setmetatable(api, {
    __index = function(_, name)
        error("MockReaper: reaper." .. tostring(name) .. " is not implemented", 2)
    end
})

MockReaper.api = api
MockReaper.PPQ = PPQ

MockReaper.Reset()

return MockReaper
