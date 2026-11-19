local Random = require("Random")
local Timing = require("Timing")
local DrumKit = require("DrumKit")
local DrumGroove = require("DrumGroove")

--------------------------------------------------
-- Generates drum fills, snare builds and arrivals.
--
-- A fill is put together from one-beat cells, drawn from the seed:
--
--     snare        every subdivision on the snare
--     toms         a descent over two toms
--     snare_toms   snare, then a tom
--     kick_snare   snare-snare-kick-kick (straight) or snare-tom-kick (triplets)
--     flam         flams on the snare (a soft grace note just before)
--
-- The first half of a fill favours the snare, the second half the toms,
-- and the toms always come down to the lowest one. Velocities rise across
-- the fill, the kick plays every beat under it, and the time-keeping
-- cymbal stops (the fill replaces the end of the bar).
--
-- A style tunes its fills in Drums.lua (every field is optional):
--
--     Drums.fills = {
--         toms = { "high_tom", "mid_tom", "low_tom", "floor_tom" },   -- high to low
--         cells = { "snare", "toms", "snare_toms", "kick_snare", "flam" },
--         velocity = { from = 92, to = 124 },  -- crescendo of a fill
--         kick = 104,                          -- kick under a fill
--         pickup = 0.5,                        -- chance of a pickup after 4 bars
--         phrase = 0.7,                        -- chance of a fill after 8 bars
--         crashes = { "crash", "crash_1" },    -- arrival crashes, in turn
--         crash = 122                          -- arrival crash velocity
--     }
--
-- In 12/8 the cells use the triplet grid of the dotted-quarter beat.
--------------------------------------------------

local DrumFill = {}

DrumFill.CELLS = {
    snare = true,
    toms = true,
    snare_toms = true,
    kick_snare = true,
    flam = true
}

DrumFill.DEFAULTS = {
    toms = {"high_tom", "mid_tom", "low_tom", "floor_tom"},
    cells = {"snare", "toms", "snare_toms", "kick_snare", "flam"},
    velocity = {
        from = 92,
        to = 124
    },
    kick = 104,
    pickup = 0.5,
    phrase = 0.7,
    crashes = {"crash", "crash_1"},
    crash = 122
}

-- Cells that open a fill and cells that end it.
local EARLY = {"snare", "kick_snare", "flam", "snare_toms"}
local LATE = {"toms", "snare_toms", "kick_snare"}
local PICKUP = {"snare", "snare_toms", "kick_snare"}

local FLAM_GRACE = 0.2 -- in sixteenths

-- Returns the style rules completed with the defaults.
function DrumFill.Rules(fills)

    local rules = {}

    for key, value in pairs(DrumFill.DEFAULTS) do
        rules[key] = value
    end

    for key, value in pairs(fills or {}) do
        rules[key] = value
    end

    return rules

end

-- Grid of a bar: { barLength, beatLength, count, triplet }.
function DrumFill.Timing(settings)

    local count, beatLength = Timing.Beats(settings)

    -- Integers when possible, so that the positions print cleanly.
    local function Integer(value)
        return math.tointeger(value) or value
    end

    beatLength = Integer(beatLength)

    return {
        barLength = Integer(Timing.QNPerBar(settings) * 4),
        beatLength = beatLength,
        count = Integer(count),
        triplet = beatLength % 3 == 0
    }

end

-- Generator of the fill at the end of `bar` in a section.
function DrumFill.Generator(drumSeed, sectionId, bar)

    return Random.New(DrumGroove.Seed(drumSeed, "fill:" .. tostring(sectionId) .. "#" .. bar))

end

-- Prepares the fills of a song into context.registry.drumFills:
--
--     { rules, seed, timing, generated }
--
-- `generated` is true when the style declares Drums.fills: its transitions
-- are then generated instead of looked up in the patterns.
function DrumFill.Apply(fills, context, settings)

    context.registry.drumFills = {
        rules = DrumFill.Rules(fills),
        seed = settings.drum_seed or 1,
        timing = DrumFill.Timing(settings),
        generated = fills ~= nil
    }

end

--------------------------------------------------
-- Cells
--------------------------------------------------

-- Exact division, kept as an integer when possible (cleaner positions).
local function Divide(a, b)

    if a % b == 0 then
        return a // b
    end

    return a / b

end

-- Subdivisions of a beat: `dense` for the rolls, `sparse` for the flams.
local function Grid(timing)

    local length = timing.beatLength

    if timing.triplet then

        local step = Divide(length, 3)

        return {0, step, 2 * step}, {0, 2 * step}

    end

    local step = Divide(length, 4)

    return {0, step, 2 * step, 3 * step}, {0, 2 * step}

end

local function Pick(list, allowed, generator)

    local choices = {}

    for _, cell in ipairs(list) do
        if allowed[cell] then
            table.insert(choices, cell)
        end
    end

    if #choices == 0 then

        for _, cell in ipairs(DrumFill.DEFAULTS.cells) do
            if allowed[cell] then
                table.insert(choices, cell)
            end
        end

    end

    return choices[generator:Int(1, #choices)]

end

local function AllowedCells(rules)

    local allowed = {}

    for _, cell in ipairs(rules.cells) do
        allowed[cell] = true
    end

    return allowed

end

-- Number of tom steps a cell uses (to land on the lowest tom).
local TOM_STEPS = {
    toms = 2,
    snare_toms = 1
}

-- Hits of one cell: list of { voice, offset, grace }.
local function CellHits(cell, timing, tom)

    local dense, sparse = Grid(timing)
    local hits = {}
    local half = math.ceil(#dense / 2)

    if cell == "snare" then

        for _, offset in ipairs(dense) do
            table.insert(hits, {"snare", offset})
        end

    elseif cell == "toms" then

        for index, offset in ipairs(dense) do
            table.insert(hits, {index <= half and tom(0) or tom(1), offset})
        end

    elseif cell == "snare_toms" then

        for index, offset in ipairs(dense) do
            table.insert(hits, {index <= half and "snare" or tom(0), offset})
        end

    elseif cell == "kick_snare" then

        local voices = timing.triplet and {"snare", tom(0), "kick"} or {"snare", "snare", "kick", "kick"}

        for index, offset in ipairs(dense) do
            table.insert(hits, {voices[index], offset})
        end

    else -- flam

        for _, offset in ipairs(sparse) do
            table.insert(hits, {"snare", offset, true})
        end

    end

    return hits

end

--------------------------------------------------
-- Patterns
--------------------------------------------------

local function Clamp(velocity)

    return math.max(1, math.min(127, math.floor(velocity + 0.5)))

end

local function Sort(notes)

    table.sort(notes, function(a, b)

        if a.position ~= b.position then
            return a.position < b.position
        end

        return a.pitch < b.pitch

    end)

    return notes

end

local function NewPattern(id, notes, transitionQN)

    return {
        id = id,
        name = id,
        type = "drums",
        resolution = 16,
        bars = 1,
        transitionBeats = transitionQN,
        notes = Sort(notes)
    }

end

-- Adds a note, one per pitch and position.
local function Adder(notes)

    local taken = {}

    return function(voice, position, velocity, swingPosition)

        local pitch = DrumKit.notes[voice]
        local key = pitch .. "@" .. position

        if taken[key] then
            return
        end

        taken[key] = true

        table.insert(notes, {
            pitch = pitch,
            position = position,
            length = DrumKit.Length(voice),
            velocity = Clamp(velocity),
            swingPosition = swingPosition
        })

    end

end

-- A fill of `beats` beats at the end of the bar.
--
-- options = { pickup = true }   -- a light pickup: lower velocities, no kick
--                               -- under it, and maybe only half a beat
function DrumFill.Fill(rules, timing, generator, beats, options)

    options = options or {}

    local allowed = AllowedCells(rules)
    local start = timing.barLength - beats * timing.beatLength
    local length = beats * timing.beatLength

    -- Cells, beat by beat.
    local cells = {}

    for beat = 1, beats do

        local list

        if options.pickup then
            list = PICKUP
        elseif beats == 1 then
            list = rules.cells
        elseif beat <= beats / 2 then
            list = EARLY
        else
            list = LATE
        end

        cells[beat] = Pick(list, allowed, generator)

    end

    -- The toms come down so that the fill ends on the lowest one.
    local toms = rules.toms
    local steps = 0

    for _, cell in ipairs(cells) do
        steps = steps + (TOM_STEPS[cell] or 0)
    end

    local cursor = math.max(1, #toms - steps + 1)

    local from = rules.velocity.from
    local to = rules.velocity.to

    if options.pickup then
        from, to = from - 20, from
    end

    local notes = {}
    local Add = Adder(notes)

    -- A pickup may only take the second half of the beat.
    local firstOffset = 0

    if options.pickup and not timing.triplet and generator:Float() < 0.5 then
        firstOffset = Divide(timing.beatLength, 2)
    end

    for beat, cell in ipairs(cells) do

        local beatStart = start + (beat - 1) * timing.beatLength

        local function Tom(shift)
            return toms[math.min(#toms, cursor + shift)]
        end

        for _, hit in ipairs(CellHits(cell, timing, Tom)) do

            local voice, offset, grace = hit[1], hit[2], hit[3]
            local position = beatStart + offset

            if position >= start + firstOffset then

                local progress = (position - start) / math.max(1, length - 1)
                local velocity = from + (to - from) * progress

                if offset == 0 then
                    velocity = velocity + 6
                end

                Add(voice, position, velocity)

                if grace then
                    Add(voice, position - FLAM_GRACE, velocity * 0.5, position)
                end

            end

        end

        cursor = math.min(#toms, cursor + (TOM_STEPS[cell] or 0))

        if not options.pickup then
            Add("kick", beatStart, rules.kick)
        end

    end

    local transitionQN = (length - firstOffset) / 4

    return NewPattern(options.pickup and "pickup" or "fill", notes, transitionQN)

end

-- A snare build over `bars` bars: eighths then sixteenths (in 12/8,
-- triplets then sextuplets), rising from soft to loud, with the kick on
-- every beat. Returns one pattern per bar.
function DrumFill.Build(rules, timing, bars)

    local barLength = timing.barLength
    local total = bars * barLength
    local slow = timing.triplet and Divide(timing.beatLength, 3) or Divide(timing.beatLength, 2)
    local fast = Divide(slow, 2)

    local patterns = {}

    for bar = 1, bars do

        local notes = {}
        local Add = Adder(notes)

        local position = 0

        while position < barLength do

            local at = (bar - 1) * barLength + position

            -- Single bar: eighths then sixteenths; two bars: one rate per bar.
            local step

            if bars == 1 then
                step = position < barLength / 2 and slow or fast
            else
                step = bar < bars and slow or fast
            end

            local velocity = 64 + (rules.velocity.to - 64) * at / math.max(1, total - 1)

            Add("snare", position, velocity)

            position = position + step

        end

        for beat = 0, timing.count - 1 do
            Add("kick", beat * timing.beatLength, rules.kick)
        end

        patterns[bar] = NewPattern("build#" .. bar, notes, barLength / 4)

    end

    return patterns

end

-- Copy of `pattern` that lands with a crash and a kick on its first beat.
-- The hi-hat or cymbal played there gives way to the crash.
function DrumFill.Arrival(pattern, voice, velocity)

    local notes = {}
    local kick = false

    for _, note in ipairs(pattern.notes) do

        local group = DrumKit.groups[DrumKit.NameOf(note.pitch)]

        if note.position == 0 and (group == "hats" or group == "cymbals") then

            velocity = math.max(velocity, note.velocity)

        else

            if note.position == 0 and note.pitch == DrumKit.notes.kick then
                kick = true
            end

            table.insert(notes, note)

        end

    end

    table.insert(notes, {
        pitch = DrumKit.notes[voice],
        position = 0,
        length = DrumKit.Length(voice),
        velocity = velocity
    })

    if not kick then

        table.insert(notes, {
            pitch = DrumKit.notes.kick,
            position = 0,
            length = DrumKit.Length("kick"),
            velocity = velocity
        })

    end

    local copy = {}

    for key, value in pairs(pattern) do
        copy[key] = value
    end

    copy.id = tostring(pattern.id) .. "+arrival"
    copy.notes = Sort(notes)

    return copy

end

return DrumFill
