--------------------------------------------------
-- Chord symbols and section harmony.
--
-- A section declares its progression:
--
--     chords = { "E5", "D5", "A5", "E5" },   -- one chord per unit
--     chord_bars = 1                          -- bars per chord (default 1)
--
-- The progression repeats until the end of the section. `chord_bars` can
-- be a fraction: 0.5 plays two chords per bar.
--
-- Symbols: a root (A to G, optional # or b), an optional quality and an
-- optional slash bass: "E5", "F#m", "Bb7", "Cmaj7", "Asus4", "D/F#".
--------------------------------------------------

local Harmony = {}

local NATURALS = {
    C = 0,
    D = 2,
    E = 4,
    F = 5,
    G = 7,
    A = 9,
    B = 11
}

local QUALITIES = {
    [""] = true,
    ["5"] = true,
    ["m"] = true,
    ["6"] = true,
    ["m6"] = true,
    ["7"] = true,
    ["m7"] = true,
    ["maj7"] = true,
    ["9"] = true,
    ["m9"] = true,
    ["add9"] = true,
    ["sus2"] = true,
    ["sus4"] = true,
    ["7sus4"] = true,
    ["dim"] = true,
    ["aug"] = true
}

-- Lowest bass note: E1 (MIDI 28), the open low string of a 4-string bass.
Harmony.BASS_LOW = 28

local function PitchClass(name)

    local letter = name:sub(1, 1)
    local accidental = name:sub(2, 2)

    local pitch = NATURALS[letter]

    if accidental == "#" then
        pitch = pitch + 1
    elseif accidental == "b" then
        pitch = pitch - 1
    end

    return pitch % 12

end

-- Returns { symbol, root, quality, bass } (pitch classes 0..11), or nil and
-- an error message.
function Harmony.Parse(symbol)

    if type(symbol) ~= "string" then
        return nil, "chord must be a string"
    end

    local root, rest = symbol:match("^([A-G][#b]?)(.*)$")

    if not root then
        return nil, "unknown chord '" .. symbol .. "'"
    end

    local quality, slash = rest:match("^([^/]*)/(.*)$")

    if not quality then
        quality = rest
    end

    if not QUALITIES[quality] then
        return nil, "unknown chord quality in '" .. symbol .. "'"
    end

    local bass = PitchClass(root)

    if slash then

        if not slash:match("^[A-G][#b]?$") then
            return nil, "unknown slash bass in '" .. symbol .. "'"
        end

        bass = PitchClass(slash)

    end

    return {
        symbol = symbol,
        root = PitchClass(root),
        quality = quality,
        bass = bass
    }

end

-- MIDI pitch of a bass pitch class, in the E1..D#2 register.
function Harmony.BassPitch(pitchClass)

    local pitch = 24 + pitchClass

    if pitch < Harmony.BASS_LOW then
        pitch = pitch + 12
    end

    return pitch

end

-- Returns the parsed chord playing `qn` quarter notes after the start of
-- the section, or nil when the section has no chords.
function Harmony.ChordAt(section, qn, qnPerBar)

    local chords = section.chords

    if not chords or #chords == 0 then
        return nil
    end

    local unitQN = (section.chord_bars or 1) * qnPerBar

    -- Small tolerance so that a note written exactly on a chord change
    -- belongs to the new chord despite floating point rounding.
    local index = math.floor(qn / unitQN + 1e-9) % #chords + 1

    return (Harmony.Parse(chords[index]))

end

-- Returns the chord changes of a section: { { chord, fromQN, toQN } },
-- merging consecutive identical symbols.
function Harmony.Changes(section, qnPerBar)

    local changes = {}

    local chords = section.chords

    if not chords or #chords == 0 then
        return changes
    end

    local unitQN = (section.chord_bars or 1) * qnPerBar
    local sectionQN = section.bars * qnPerBar

    local position = 0
    local index = 1

    while position < sectionQN - 1e-9 do

        local symbol = chords[index]
        local toQN = math.min(position + unitQN, sectionQN)
        local last = changes[#changes]

        if last and last.chord.symbol == symbol then

            last.toQN = toQN

        else

            table.insert(changes, {
                chord = Harmony.Parse(symbol),
                fromQN = position,
                toQN = toQN
            })

        end

        position = toQN
        index = index % #chords + 1

    end

    return changes

end

return Harmony
