--------------------------------------------------
-- EZdrummer 3 drum map (default MIDI mapping, checked against the
-- "EZdrummer 3 Bright Room" mapping layout).
--
-- `notes` gives the MIDI note of each articulation. `groups` sorts them by
-- part of the kit; the humanization uses the groups to place each part of
-- the kit slightly ahead of or behind the beat.
--------------------------------------------------

local DrumKit = {}

DrumKit.notes = {

    -- Kick
    kick = 36,

    -- Snare
    snare = 38,
    snare_rimshot = 40,
    snare_edge = 33,
    snare_rim_only = 71,
    side_stick = 37,

    -- Hi-hat, from closed to open
    hat_tight_tip = 63,
    hat_tight_edge = 62,
    closed_hat = 42, -- closed tip
    hat_closed_edge = 22,
    hat_open_tip_1 = 13,
    hat_open_tip_2 = 14,
    semi_open_hat = 15, -- open tip 3
    hat_open_tip_4 = 16,
    hat_open_tip_5 = 17,
    hat_open_edge_1 = 24,
    open_hat = 46, -- open edge 2
    hat_open_edge_3 = 26,
    hat_open_edge_4 = 60,
    hat_open_edge_5 = 124,
    hat_pedal = 44,
    hat_pedal_open = 23,

    -- Toms, from high to low
    high_tom = 48, -- rack tom 1
    mid_tom = 47, -- rack tom 2
    low_tom = 45, -- rack tom 3
    floor_tom = 43, -- floor tom 1
    floor_tom_2 = 41,
    high_tom_rimshot = 82,
    mid_tom_rimshot = 80,
    low_tom_rimshot = 78,
    floor_tom_rimshot = 75,
    floor_tom_2_rimshot = 73,

    -- Crashes (a "muted" hit is the crash choked by hand)
    crash_1 = 86,
    crash_1_bow = 84,
    crash_1_muted = 83,
    crash = 49, -- crash 2
    crash_2_bow = 27,
    crash_2_muted = 50,
    crash_3 = 57,
    crash_3_bow = 31,
    crash_3_muted = 58,
    crash_4 = 98,
    crash_4_bow = 96,
    crash_4_muted = 99,

    -- Effects cymbals
    china = 52,
    china_bow = 108,
    china_muted = 54,
    splash = 55,
    splash_muted = 56,

    -- Ride
    ride = 51, -- bow
    ride_bell = 53,
    ride_edge = 59,
    ride_muted = 118,

    -- Percussion
    tambourine = 3,
    shaker = 2

}

local GROUPS = {
    kick = {"kick"},
    snare = {"snare", "snare_rimshot", "snare_edge", "snare_rim_only", "side_stick"},
    hats = {"hat_tight_tip", "hat_tight_edge", "closed_hat", "hat_closed_edge", "hat_open_tip_1", "hat_open_tip_2",
            "semi_open_hat", "hat_open_tip_4", "hat_open_tip_5", "hat_open_edge_1", "open_hat", "hat_open_edge_3",
            "hat_open_edge_4", "hat_open_edge_5", "hat_pedal", "hat_pedal_open"},
    toms = {"high_tom", "mid_tom", "low_tom", "floor_tom", "floor_tom_2", "high_tom_rimshot", "mid_tom_rimshot",
            "low_tom_rimshot", "floor_tom_rimshot", "floor_tom_2_rimshot"},
    cymbals = {"crash_1", "crash_1_bow", "crash_1_muted", "crash", "crash_2_bow", "crash_2_muted", "crash_3",
               "crash_3_bow", "crash_3_muted", "crash_4", "crash_4_bow", "crash_4_muted", "china", "china_bow",
               "china_muted", "splash", "splash_muted", "ride", "ride_bell", "ride_edge", "ride_muted"},
    percussion = {"tambourine", "shaker"}
}

DrumKit.groups = {}

for group, names in pairs(GROUPS) do

    for _, name in ipairs(names) do
        DrumKit.groups[name] = group
    end

end

DrumKit.GROUP_NAMES = {"kick", "snare", "hats", "toms", "cymbals", "percussion"}

-- Articulations that ring: their notes last longer than a single hit.
local RINGING = {
    crash_1 = true,
    crash = true,
    crash_3 = true,
    crash_4 = true,
    china = true,
    splash = true
}

function DrumKit.Exists(name)

    return DrumKit.notes[name] ~= nil

end

-- Default note length of an articulation, in sixteenths.
function DrumKit.Length(name)

    return RINGING[name] and 1 or 0.25

end

-- Returns { [pitch] = ticks } from { kick = ticks, snare = ticks, ... }.
function DrumKit.OffsetsByPitch(offsetsByGroup)

    local offsets = {}

    for name, pitch in pairs(DrumKit.notes) do

        local ticks = offsetsByGroup[DrumKit.groups[name]]

        if ticks then
            offsets[pitch] = ticks
        end

    end

    return offsets

end

return DrumKit
