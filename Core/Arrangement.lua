local Reaper = require("Reaper")
local Timing = require("Timing")
local MidiWriter = require("MidiWriter")
local Humanizer = require("Humanizer")

local Arrangement = {}

function Arrangement.Apply(context, settings)

    Reaper.SetTempo(settings.tempo)

    if settings.humanization and settings.humanization.enabled then

        Humanizer.SetSeed(settings.humanization.seed)

    end

    local drumTrackEntry = context.registry.tracks.ezd_midi
    local humanization = settings.humanization

    if not drumTrackEntry then

        error("Missing MIDI track: ez_midi")

    end

    local drumTrack = drumTrackEntry.track

    for _, section in ipairs(context.song) do

        --------------------------------------------------
        -- Drum pattern
        --------------------------------------------------

        if section.patterns and section.patterns.drums then

            local drumDefinition = section.patterns.drums

            local primaryId
            local variationId

            if type(drumDefinition) == "string" then

                primaryId = drumDefinition

            else

                primaryId = drumDefinition.primary
                variationId = drumDefinition.variation

            end

            local pattern = context.registry.patterns[primaryId]

            if not pattern then

                error("Unknown drum pattern: " .. tostring(primaryId))

            end

            local variationPattern = nil

            if variationId then

                variationPattern = context.registry.patterns[variationId]

                if not variationPattern then

                    error("Unknown drum variation: " .. tostring(variationId))

                end

            end

            --------------------------------------------------
            -- Fill validation
            --------------------------------------------------

            local fillPattern = nil

            if section.fill then

                fillPattern = context.registry.patterns[section.fill]

                if not fillPattern then

                    error("Unknown fill pattern: " .. tostring(section.fill))

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

            if fillPattern then

                normalBars = normalBars - 1

            end

            if normalBars > 0 then

                for bar = 1, normalBars do

                    local selectedPattern = pattern

                    if variationPattern and bar % 4 == 0 then

                        selectedPattern = variationPattern

                    end

                    local barQN = startQN + ((bar - 1) * settings.beats_per_bar)

                    MidiWriter.WritePatternAtBar(take, selectedPattern, barQN, settings.beats_per_bar, humanization)

                end

            end

            --------------------------------------------------
            -- Fill
            --------------------------------------------------

            if fillPattern then

                local fillStartQN = startQN + (normalBars * settings.beats_per_bar)

                MidiWriter.WritePatternAtBar(take, fillPattern, fillStartQN, settings.beats_per_bar, humanization)

            end

        end

    end

    Reaper.UpdateArrange()

end

return Arrangement
