local Reaper = require("Reaper")
local Timing = require("Timing")
local MidiWriter = require("MidiWriter")
local Humanizer = require("Humanizer")
local Transitions = require("Transitions")

local Arrangement = {}

function Arrangement.Apply(context, settings)

    Reaper.SetTempo(settings.tempo)

    --------------------------------------------------
    -- Humanization
    --------------------------------------------------

    if settings.humanization and settings.humanization.enabled then

        Humanizer.SetSeed(settings.humanization.seed)

    end

    --------------------------------------------------
    -- MIDI Track
    --------------------------------------------------

    local drumTrackEntry = context.registry.tracks.ezd_midi

    if not drumTrackEntry then

        error("Missing MIDI track: ez_midi")

    end

    local drumTrack = drumTrackEntry.track

    --------------------------------------------------
    -- Sections
    --------------------------------------------------

    for index, section in ipairs(context.song) do

        local nextSection = context.song[index + 1]

        local energy = section.energy or 1

        --------------------------------------------------
        -- Drum pattern
        --------------------------------------------------

        if section.patterns and section.patterns.drums then

            local drumDefinition = section.patterns.drums

            local primaryId
            local variationId
            local openingId

            if type(drumDefinition) == "string" then

                primaryId = drumDefinition

            else

                primaryId = drumDefinition.primary

                variationId = drumDefinition.variation

                openingId = drumDefinition.opening

            end

            local pattern = context.registry.patterns[primaryId]

            if not pattern then

                error("Unknown drum pattern: " .. tostring(primaryId))

            end

            local variationPattern = nil

            local openingPattern = nil

            if variationId then

                variationPattern = context.registry.patterns[variationId]

                if not variationPattern then

                    error("Unknown drum variation: " .. tostring(variationId))

                end

            end

            if openingId then

                openingPattern = context.registry.patterns[openingId]

                if not openingPattern then

                    error("Unknown drum opening pattern: " .. tostring(openingId))

                end

            end

            --------------------------------------------------
            -- Fill
            --------------------------------------------------

            local fillId = Transitions.GetFill(section, nextSection)

            local fillPattern = nil

            if fillId then

                fillPattern = context.registry.patterns[fillId]

                if not fillPattern then

                    error("Unknown fill pattern: " .. tostring(fillId))

                end

            end

            --------------------------------------------------
            -- Section timing
            --------------------------------------------------

            local startQN = Timing.BarToQN(section.startBar, settings)

            local endQN = Timing.BarToQN(section.endBar + 1, settings)

            --------------------------------------------------
            -- MIDI item
            --------------------------------------------------

            local item = MidiWriter.CreateItem(drumTrack, startQN, endQN)

            local take = Reaper.GetActiveTake(item)

            --------------------------------------------------
            -- Main pattern
            --------------------------------------------------

            local normalBars = section.bars

            --------------------------------------------------
            -- Pattern generation
            --------------------------------------------------

            local completeBars = fillPattern and normalBars - 1 or normalBars

            for bar = 1, completeBars do

                local selectedPattern = pattern

                if openingPattern and bar == 1 then

                    selectedPattern = openingPattern

                elseif variationPattern and bar % 4 == 0 then

                    selectedPattern = variationPattern

                end

                local barQN = startQN + ((bar - 1) * settings.beats_per_bar)

                MidiWriter.WritePatternAtBar(take, selectedPattern, barQN, settings.beats_per_bar,
                    settings.humanization, energy)

            end

            --------------------------------------------------
            -- Fill
            --------------------------------------------------

            if fillPattern then

                local finalBarQN = startQN + ((normalBars - 1) * settings.beats_per_bar)
                local fillBeats = fillPattern.transitionBeats or 1
                local fillStartBeat = settings.beats_per_bar - fillBeats
                local selectedPattern = pattern

                if fillBeats <= 0 or fillBeats > settings.beats_per_bar then

                    error("Invalid transition length for fill: " .. tostring(fillId))

                end

                if variationPattern and normalBars % 4 == 0 then

                    selectedPattern = variationPattern

                end

                MidiWriter.WritePatternUntilBeat(take, selectedPattern, finalBarQN, settings.beats_per_bar,
                    fillStartBeat, settings.humanization, energy)

                MidiWriter.WritePatternBetweenBeats(take, fillPattern, finalBarQN, settings.beats_per_bar,
                    fillStartBeat, settings.beats_per_bar, settings.humanization, energy)

            end

            Reaper.SortMidi(take)

        end

    end

    Reaper.UpdateArrange()

end

return Arrangement
