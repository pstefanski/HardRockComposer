local Reaper = require("Reaper")
local Timing = require("Timing")
local MidiWriter = require("MidiWriter")
local Humanizer = require("Humanizer")
local Transitions = require("Transitions")
local MidiNotes = require("Patterns.MidiNotes")
local DrumGroove = require("DrumGroove")
local DrumKit = require("DrumKit")
local DrumFill = require("DrumFill")

--------------------------------------------------
-- Writes the drum MIDI of every section.
--
-- The drum plan of a section says which pattern plays on which part of
-- each bar (opening, variations, fill at the end). Other instruments read
-- the same plan, e.g. the bass follows the kick drum.
--
-- A section plays either a generated groove (see DrumGroove):
--
--     patterns = { drums = { groove = "verse" } }
--
-- or patterns written by hand:
--
--     patterns = { drums = { primary = "...", variation = "...", opening = "..." } }
--
-- With patterns, the variation plays every fourth bar.
--------------------------------------------------

local Arrangement = {}

local DRUM_TRACK = "ezd_midi"

local function Lookup(registry, role, id)

    local pattern = registry.patterns[id]

    if not pattern then

        error("Unknown " .. role .. " pattern: " .. tostring(id))

    end

    return pattern

end

-- Fills of a registry built without DrumFill.Apply (tests, old callers).
local function FillSetup(registry, qnPerBar)

    return registry.drumFills or {
        rules = DrumFill.Rules(nil),
        seed = 1,
        timing = {
            barLength = qnPerBar * 4,
            beatLength = 4,
            count = qnPerBar,
            triplet = false
        },
        generated = false
    }

end

-- Generated transition at the end of a section: { fills = { [bar] = pattern },
-- builds = { [bar] = pattern } }.
local function GeneratedEnding(kind, section, nextSection, setup)

    local rules, timing = setup.rules, setup.timing
    local bars = section.bars
    local generator = DrumFill.Generator(setup.seed, section.id, bars)

    local ending = {
        fills = {},
        builds = {}
    }

    if kind == "build" then

        local count = (bars >= 8 and generator:Float() < 0.5) and 2 or 1
        count = math.min(count, bars)

        for index, pattern in ipairs(DrumFill.Build(rules, timing, count)) do
            ending.builds[bars - count + index] = pattern
        end

    elseif kind == "pickup" then

        ending.fills[bars] = DrumFill.Fill(rules, timing, generator, 1, {
            pickup = true
        })

    else

        local beats = timing.count

        if kind == "fill" then

            beats = 2

            if nextSection and (nextSection.energy or 1) > (section.energy or 1) then
                beats = 3
            end

            beats = math.min(beats, timing.count)

        end

        ending.fills[bars] = DrumFill.Fill(rules, timing, generator, beats)

    end

    return ending

end

-- Returns the list of segments played in a section, in writing order:
--
--     { bar = 1..bars, barQN = offset from the section start,
--       pattern, fromQN, toQN }   -- window inside the bar, in QN
--
-- options = {
--     previous = section,         -- the section before (for the arrival crash)
--     state = { crashes = 0 }     -- shared by the sections of a song, so that
--                                 -- the arrival crashes alternate
-- }
--
-- Returns nil when the section has no drum pattern.
function Arrangement.DrumPlan(section, nextSection, registry, qnPerBar, options)

    if not (section.patterns and section.patterns.drums) then

        return nil

    end

    options = options or {}

    local definition = section.patterns.drums

    local primaryId, variationId, openingId, groove

    if type(definition) == "table" and definition.groove then

        groove = registry.grooves and registry.grooves[definition.groove]

        if not groove then
            error("Unknown drum groove: " .. tostring(definition.groove))
        end

    elseif type(definition) == "string" then

        primaryId = definition

    else

        primaryId = definition.primary
        variationId = definition.variation
        openingId = definition.opening

    end

    local primary = not groove and Lookup(registry, "drum", primaryId)
    local variation = variationId and Lookup(registry, "drum variation", variationId)
    local opening = openingId and Lookup(registry, "drum opening", openingId)

    local setup = FillSetup(registry, qnPerBar)
    local rules = setup.rules

    --------------------------------------------------
    -- What ends the bars: fills, builds, arrivals
    --------------------------------------------------

    local fills = {}
    local builds = {}
    local arrivals = {}

    local transition = Transitions.Resolve(section, nextSection, setup.generated)

    if transition and transition.pattern then

        local fill = Lookup(registry, "fill", transition.pattern)
        local fillBeats = fill.transitionBeats or 1

        if fillBeats <= 0 or fillBeats > qnPerBar then

            error("Invalid transition length for fill: " .. tostring(transition.pattern))

        end

        fills[section.bars] = fill

    elseif transition then

        local ending = GeneratedEnding(transition.kind, section, nextSection, setup)

        fills, builds = ending.fills, ending.builds

    end

    if setup.generated then

        -- The section lands with a crash after the transition of the previous one.
        if options.previous and Transitions.Resolve(options.previous, section, true) then
            arrivals[1] = true
        end

        -- Phrase fills inside a generated groove: a pickup after 4 bars, a
        -- fill after 8 bars, followed by a crash.
        if groove then

            for bar = 4, section.bars - 1, 4 do

                if not (fills[bar] or builds[bar] or builds[bar + 1]) then

                    local generator = DrumFill.Generator(setup.seed, section.id, bar)

                    if bar % 8 == 0 and generator:Float() < rules.phrase then

                        fills[bar] = DrumFill.Fill(rules, setup.timing, generator, generator:Int(1, 2))
                        arrivals[bar + 1] = true

                    elseif generator:Float() < rules.pickup then

                        fills[bar] = DrumFill.Fill(rules, setup.timing, generator, 1, {
                            pickup = true
                        })

                    end

                end

            end

        end

    end

    --------------------------------------------------
    -- Segments
    --------------------------------------------------

    local state = options.state or {
        crashes = 0
    }

    local segments = {}

    local function Add(bar, pattern, fromQN, toQN)

        if toQN <= fromQN then
            return
        end

        table.insert(segments, {
            bar = bar,
            barQN = (bar - 1) * qnPerBar,
            pattern = pattern,
            fromQN = fromQN,
            toQN = toQN
        })

    end

    for bar = 1, section.bars do

        local pattern = primary

        if groove then

            pattern = DrumGroove.BarPattern(groove, bar)

        elseif fills[bar] and bar == section.bars then

            -- The bar of a fill written by hand never uses the opening.
            if variation and bar % 4 == 0 then
                pattern = variation
            end

        elseif opening and bar == 1 then

            pattern = opening

        elseif variation and bar % 4 == 0 then

            pattern = variation

        end

        if builds[bar] then

            pattern = builds[bar]

        elseif arrivals[bar] then

            local crashes = rules.crashes
            local voice = crashes[state.crashes % #crashes + 1]

            state.crashes = state.crashes + 1

            pattern = DrumFill.Arrival(pattern, voice, rules.crash)

        end

        local fill = fills[bar]

        if fill then

            local fillStartQN = qnPerBar - (fill.transitionBeats or 1)

            Add(bar, pattern, 0, fillStartQN)
            Add(bar, fill, fillStartQN, qnPerBar)

        else

            Add(bar, pattern, 0, pattern.bars * qnPerBar)

        end

    end

    return segments

end

-- Count-in: one side stick per felt beat, accent on the first beat of each
-- bar. Written without humanization.
local function WriteCountIn(track, countIn, settings, qnPerBar)

    local count, beatLength = Timing.Beats(settings)

    local notes = {}

    for beat = 1, count do

        table.insert(notes, {
            pitch = MidiNotes.drums.side_stick,
            position = (beat - 1) * beatLength,
            length = 1,
            velocity = beat == 1 and 110 or 90
        })

    end

    local item = MidiWriter.CreateItem(track, 0, countIn.bars * qnPerBar)
    local take = Reaper.GetActiveTake(item)

    for bar = 1, countIn.bars do

        MidiWriter.WritePattern(take, {
            bars = 1,
            notes = notes
        }, (bar - 1) * qnPerBar, qnPerBar, {})

    end

    Reaper.SortMidi(take)

end

function Arrangement.Apply(context, settings)

    --------------------------------------------------
    -- Humanization
    --------------------------------------------------

    if settings.humanization and settings.humanization.enabled then

        Humanizer.SetSeed(settings.humanization.seed)

    end

    --------------------------------------------------
    -- MIDI Track
    --------------------------------------------------

    local drumTrackEntry = context.registry.tracks[DRUM_TRACK]

    if not drumTrackEntry then

        error("Missing MIDI track: " .. DRUM_TRACK)

    end

    local drumTrack = drumTrackEntry.track

    local qnPerBar = Timing.QNPerBar(settings)

    -- Each part of the kit sits slightly ahead of or behind the beat.
    local humanization = settings.humanization
    local offsets = humanization and humanization.feel and DrumKit.OffsetsByPitch(humanization.feel)

    --------------------------------------------------
    -- Sections
    --------------------------------------------------

    -- Shared by the sections, so that the arrival crashes alternate.
    local state = {
        crashes = 0
    }

    for index, section in ipairs(context.song) do

        local plan = Arrangement.DrumPlan(section, context.song[index + 1], context.registry, qnPerBar, {
            previous = context.song[index - 1],
            state = state
        })

        if plan then

            local feel = {
                energy = section.energy or 1,
                humanization = settings.humanization,
                swing = settings.swing,
                offsets = offsets
            }

            local startQN = Timing.BarToQN(section.startBar, settings)
            local endQN = Timing.BarToQN(section.endBar + 1, settings)

            local item = MidiWriter.CreateItem(drumTrack, startQN, endQN)
            local take = Reaper.GetActiveTake(item)

            for _, segment in ipairs(plan) do

                MidiWriter.WriteBetween(take, segment.pattern, startQN + segment.barQN, segment.fromQN, segment.toQN,
                    feel)

            end

            Reaper.SortMidi(take)

        end

    end

    if context.countIn then

        WriteCountIn(drumTrack, context.countIn, settings, qnPerBar)

    end

    Reaper.UpdateArrange()

end

return Arrangement
