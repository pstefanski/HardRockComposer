local Reaper = require("Reaper")
local Timing = require("Timing")
local MidiWriter = require("MidiWriter")
local Humanizer = require("Humanizer")
local Transitions = require("Transitions")
local MidiNotes = require("Patterns.MidiNotes")
local DrumGroove = require("DrumGroove")
local DrumKit = require("DrumKit")

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

-- Returns the list of segments played in a section, in writing order:
--
--     { bar = 1..bars, barQN = offset from the section start,
--       pattern, fromQN, toQN }   -- window inside the bar, in QN
--
-- Returns nil when the section has no drum pattern.
function Arrangement.DrumPlan(section, nextSection, registry, qnPerBar)

    if not (section.patterns and section.patterns.drums) then

        return nil

    end

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

    local fillId = Transitions.GetFill(section, nextSection)
    local fill = fillId and Lookup(registry, "fill", fillId)

    local segments = {}

    local function Add(bar, pattern, fromQN, toQN)

        table.insert(segments, {
            bar = bar,
            barQN = (bar - 1) * qnPerBar,
            pattern = pattern,
            fromQN = fromQN,
            toQN = toQN
        })

    end

    local completeBars = fill and section.bars - 1 or section.bars

    for bar = 1, completeBars do

        local pattern = primary

        if groove then

            pattern = DrumGroove.BarPattern(groove, bar)

        elseif opening and bar == 1 then

            pattern = opening

        elseif variation and bar % 4 == 0 then

            pattern = variation

        end

        Add(bar, pattern, 0, pattern.bars * qnPerBar)

    end

    if fill then

        local fillBeats = fill.transitionBeats or 1
        local fillStartQN = qnPerBar - fillBeats

        if fillBeats <= 0 or fillBeats > qnPerBar then

            error("Invalid transition length for fill: " .. tostring(fillId))

        end

        local pattern = primary

        if groove then

            pattern = DrumGroove.BarPattern(groove, section.bars)

        elseif variation and section.bars % 4 == 0 then

            pattern = variation

        end

        Add(section.bars, pattern, 0, fillStartQN)
        Add(section.bars, fill, fillStartQN, qnPerBar)

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

    for index, section in ipairs(context.song) do

        local plan = Arrangement.DrumPlan(section, context.song[index + 1], context.registry, qnPerBar)

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
