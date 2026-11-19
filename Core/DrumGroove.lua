local Random = require("Random")
local Timing = require("Timing")
local DrumKit = require("DrumKit")

--------------------------------------------------
-- Generates drum grooves from the rules of a style.
--
-- A style declares its grooves in Drums.lua (`Drums.grooves`), one per
-- kind of section. Positions are sixteenths from the start of the bar
-- (0 to 15 in 4/4, 0 to 23 in 12/8). Every part is optional.
--
--     verse = {
--         phrase = 4,                  -- bars before the groove repeats: 1, 2 or 4
--
--         pulse = {                    -- the time-keeping voice
--             voice = "closed_hat",    -- a DrumKit articulation
--             every = 2,               -- one hit every 2 sixteenths (or positions = {...})
--             velocity = 84,
--             accent = 104,            -- velocity on the beats (optional)
--             open = {                 -- open hi-hat at the end of answer bars (optional)
--                 voice = "open_hat", positions = {14}, chance = 0.5, velocity = 98
--             }
--         },
--
--         kick = {
--             positions = {0, 8},      -- played in every bar
--             velocity = 112,
--             options = {              -- { position, chance [, velocity] }
--                 {10, 0.5}, {6, 0.25, 96}
--             }
--         },
--
--         snare = { positions = {4, 12}, velocity = 114, rimshot = 0.3 },   -- rimshot: chance
--
--         ghosts = { positions = {7, 15, 3}, chance = 0.4, velocity = 36, max = 2 },
--
--         extras = {                   -- any other optional hit
--             { voice = "high_tom", position = 7, chance = 0.5, velocity = 92 }
--         },
--
--         opening = { voice = "crash", velocity = 122 }   -- first bar of the section
--     }
--
-- The phrase follows a call-and-answer shape: bar A is drawn from the
-- rules, the answer bar changes one optional kick and may open the
-- hi-hat, the last bar of the phrase varies again and always opens the
-- hi-hat (when the groove has an open hi-hat):
--
--     phrase = 1   A
--     phrase = 2   A  end
--     phrase = 4   A  answer  A  end
--
-- The draws only depend on the drum seed and the groove name, so every
-- section using a groove plays the same phrase.
--------------------------------------------------

local DrumGroove = {}

DrumGroove.PHRASES = {
    [1] = true,
    [2] = true,
    [4] = true
}

local function NameHash(name)

    local hash = 0

    for index = 1, #name do
        hash = (hash * 31 + name:byte(index)) % 2147483648
    end

    return hash

end

-- Seed of the generator of one groove.
function DrumGroove.Seed(drumSeed, name)

    return Random.Mix(Random.Mix(drumSeed or 1) ~ NameHash(name))

end

-- Positions of a part: its list, or one every `every` sixteenths.
function DrumGroove.Positions(part, barLength)

    if part.positions then
        return part.positions
    end

    local positions = {}

    if part.every then

        for position = part.from or 0, barLength - 1, part.every do
            table.insert(positions, position)
        end

    end

    return positions

end

--------------------------------------------------
-- Choices: what the optional rules play in one bar
--------------------------------------------------

local function Draw(list, chance, generator)

    local chosen = {}

    for index, entry in ipairs(list or {}) do
        chosen[index] = generator:Float() < chance(entry)
    end

    return chosen

end

local function CopyChoices(choices)

    local copy = {}

    for key, value in pairs(choices) do

        if type(value) == "table" then

            copy[key] = {}

            for index, chosen in pairs(value) do
                copy[key][index] = chosen
            end

        else

            copy[key] = value

        end

    end

    return copy

end

local function Flip(list, generator)

    if #list > 0 then

        local index = generator:Int(1, #list)

        list[index] = not list[index]

    end

end

local function FirstChoices(groove, generator)

    local choices = {}

    choices.kicks = Draw(groove.kick and groove.kick.options, function(option)
        return option[2]
    end, generator)

    local ghosts = groove.ghosts

    choices.ghosts = Draw(ghosts and ghosts.positions, function()
        return ghosts.chance or 0.5
    end, generator)

    if ghosts and ghosts.max then

        local count = 0

        for index, chosen in ipairs(choices.ghosts) do

            if chosen then

                count = count + 1

                if count > ghosts.max then
                    choices.ghosts[index] = false
                end

            end

        end

    end

    choices.extras = Draw(groove.extras, function(extra)
        return extra.chance or 1
    end, generator)

    choices.opens = {}

    choices.rimshot = groove.snare ~= nil and groove.snare.rimshot ~= nil and generator:Float() < groove.snare.rimshot

    return choices

end

local function OpenPositions(groove)

    local open = groove.pulse and groove.pulse.open

    return open and open.positions or {}

end

local function AnswerChoices(groove, first, generator)

    local choices = CopyChoices(first)

    Flip(choices.kicks, generator)

    local open = groove.pulse and groove.pulse.open

    choices.opens = Draw(OpenPositions(groove), function()
        return open.chance or 0.5
    end, generator)

    return choices

end

local function EndChoices(groove, answer, generator)

    local choices = CopyChoices(answer)

    Flip(choices.kicks, generator)
    Flip(choices.ghosts, generator)

    for index in ipairs(OpenPositions(groove)) do
        choices.opens[index] = true
    end

    return choices

end

--------------------------------------------------
-- Rendering a bar
--------------------------------------------------

local function Velocity(part, position, beatLength)

    if part.accent and position % beatLength == 0 then
        return part.accent
    end

    return part.velocity

end

local function Render(groove, choices, context, withOpening)

    local notes = {}
    local taken = {}

    local function Add(name, position, velocity)

        local pitch = DrumKit.notes[name]
        local key = pitch .. "@" .. position

        if taken[key] then
            return
        end

        taken[key] = true

        table.insert(notes, {
            pitch = pitch,
            position = position,
            length = DrumKit.Length(name),
            velocity = velocity
        })

    end

    local opening = withOpening and groove.opening

    if opening then
        Add(opening.voice or "crash", 0, opening.velocity or 120)
    end

    local pulse = groove.pulse

    if pulse then

        local opened = {}

        for index, position in ipairs(OpenPositions(groove)) do

            if choices.opens[index] then
                opened[position] = true
            end

        end

        for _, position in ipairs(DrumGroove.Positions(pulse, context.barLength)) do

            if opened[position] then

                Add(pulse.open.voice or "open_hat", position, pulse.open.velocity or Velocity(pulse, position,
                    context.beatLength))

            elseif not (opening and position == 0) then

                Add(pulse.voice, position, Velocity(pulse, position, context.beatLength))

            end

        end

    end

    local kick = groove.kick

    if kick then

        for _, position in ipairs(DrumGroove.Positions(kick, context.barLength)) do
            Add("kick", position, Velocity(kick, position, context.beatLength))
        end

        for index, option in ipairs(kick.options or {}) do

            if choices.kicks[index] then
                Add("kick", option[1], option[3] or kick.velocity)
            end

        end

    end

    local snare = groove.snare
    local backbeat = {}

    if snare then

        local voice = choices.rimshot and "snare_rimshot" or (snare.voice or "snare")

        for _, position in ipairs(DrumGroove.Positions(snare, context.barLength)) do

            backbeat[position] = true

            Add(voice, position, Velocity(snare, position, context.beatLength))

        end

    end

    local ghosts = groove.ghosts

    if ghosts then

        for index, position in ipairs(ghosts.positions) do

            if choices.ghosts[index] and not backbeat[position] then
                Add(ghosts.voice or "snare", position, ghosts.velocity or 36)
            end

        end

    end

    for index, extra in ipairs(groove.extras or {}) do

        if choices.extras[index] then
            Add(extra.voice, extra.position, extra.velocity)
        end

    end

    table.sort(notes, function(a, b)

        if a.position ~= b.position then
            return a.position < b.position
        end

        return a.pitch < b.pitch

    end)

    return notes

end

local function Pattern(name, index, notes)

    return {
        id = name .. "#" .. index,
        name = name,
        type = "drums",
        resolution = 16,
        bars = 1,
        notes = notes
    }

end

--------------------------------------------------
-- Phrases
--------------------------------------------------

-- Returns the phrase of a groove:
--
--     { name, bars = { pattern, ... }, opening = pattern or nil }
--
-- `opening` replaces the first bar of a section when the groove has an
-- opening hit.
function DrumGroove.Phrase(name, groove, drumSeed, settings)

    local generator = Random.New(DrumGroove.Seed(drumSeed, name))

    local _, beatLength = Timing.Beats(settings)

    local context = {
        barLength = Timing.QNPerBar(settings) * 4,
        beatLength = beatLength
    }

    local first = FirstChoices(groove, generator)
    local answer = AnswerChoices(groove, first, generator)
    local last = EndChoices(groove, answer, generator)

    local shapes = {
        [1] = {first},
        [2] = {first, last},
        [4] = {first, answer, first, last}
    }

    local phrase = {
        name = name,
        bars = {}
    }

    for index, choices in ipairs(shapes[groove.phrase or 4]) do
        phrase.bars[index] = Pattern(name, index, Render(groove, choices, context, false))
    end

    if groove.opening then
        phrase.opening = Pattern(name, "opening", Render(groove, first, context, true))
    end

    return phrase

end

-- Generates the phrase of every groove into context.registry.grooves.
function DrumGroove.Apply(grooves, context, settings)

    context.registry.grooves = context.registry.grooves or {}

    for name, groove in pairs(grooves or {}) do
        context.registry.grooves[name] = DrumGroove.Phrase(name, groove, settings.drum_seed, settings)
    end

end

-- Pattern played in bar `bar` (1-based) of a section using `phrase`.
function DrumGroove.BarPattern(phrase, bar)

    if bar == 1 and phrase.opening then
        return phrase.opening
    end

    return phrase.bars[(bar - 1) % #phrase.bars + 1]

end

return DrumGroove
