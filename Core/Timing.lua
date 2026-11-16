--------------------------------------------------
-- Musical time conversions.
--
-- The engine counts in quarter notes (QN), like REAPER. Pattern positions
-- are sixteenth notes from the start of the bar.
--------------------------------------------------

local Timing = {}

-- Length of one bar in quarter notes: 4/4 → 4, 3/4 → 3, 12/8 → 6, 6/8 → 3.
function Timing.QNPerBar(settings)

    return settings.beats_per_bar * 4 / settings.beat_unit

end

function Timing.BarToQN(bar, settings)

    return (bar - 1) * Timing.QNPerBar(settings)

end

function Timing.BarsToQN(bars, settings)

    return bars * Timing.QNPerBar(settings)

end

function Timing.PositionToQN(bar, position, settings)

    return Timing.BarToQN(bar, settings) + position / 4

end

-- Felt beats of a bar: returns the beat count and the beat length in
-- sixteenths. Compound meters (6/8, 9/8, 12/8) count dotted quarters.
function Timing.Beats(settings)

    if settings.beat_unit == 8 and settings.beats_per_bar % 3 == 0 then

        return settings.beats_per_bar / 3, 6

    end

    return settings.beats_per_bar, 16 / settings.beat_unit

end

--------------------------------------------------
-- Swing
--
-- swing = { amount = 0..1, subdivision = 8 | 16 }
--
-- amount 0 keeps the grid straight; amount 1 moves every off-beat to the
-- triplet position (full shuffle). Only off-beats of the chosen
-- subdivision move:
--   8  → the "and" of each beat (positions 2, 6, 10, 14)
--   16 → every odd sixteenth (positions 1, 3, 5, ...)
--------------------------------------------------

local SWING_DELAY_QN = {

    -- Off-beat eighth: 1/2 → 2/3 of a quarter note.
    [8] = 2 / 3 - 1 / 2,

    -- Off-beat sixteenth: 1/4 → 1/3 of a quarter note.
    [16] = 1 / 3 - 1 / 4

}

function Timing.SwingOffsetQN(position, swing)

    if not swing or not swing.amount or swing.amount <= 0 then
        return 0
    end

    local subdivision = swing.subdivision or 8

    local isOffBeat

    if subdivision == 8 then
        isOffBeat = position % 4 == 2
    else
        isOffBeat = position % 2 == 1
    end

    if not isOffBeat then
        return 0
    end

    return swing.amount * SWING_DELAY_QN[subdivision]

end

return Timing
