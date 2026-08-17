local Reaper = require("Reaper")
local Timing = require("Timing")
local MidiWriter = require("MidiWriter")
local MidiTracks = require("MidiTracks")

local Arrangement = {}

function Arrangement.Apply(
    context,
    settings
)

    Reaper.SetTempo(settings.tempo)

    local drumTrack =
        MidiTracks.Create("Drums MIDI")

    for _, section in ipairs(context.song) do

        --------------------------------------------------
        -- Drum pattern
        --------------------------------------------------

        if section.patterns
        and section.patterns.drums then

            local patternId =
                section.patterns.drums

            local pattern =
                context.registry.patterns[
                    patternId
                ]

            if not pattern then

                error(
                    "Unknown drum pattern: " ..
                    tostring(patternId)
                )

            end

            --------------------------------------------------
            -- Fill validation
            --------------------------------------------------

            local fillPattern = nil

            if section.fill then

                fillPattern =
                    context.registry.patterns[
                        section.fill
                    ]

                if not fillPattern then

                    error(
                        "Unknown fill pattern: " ..
                        tostring(section.fill)
                    )

                end

            end

            --------------------------------------------------
            -- Section timing
            --------------------------------------------------

            local startQN =
                Timing.BarToQN(
                    section.startBar,
                    settings
                )

            local endQN =
                Timing.BarToQN(
                    section.endBar + 1,
                    settings
                )

            --------------------------------------------------
            -- MIDI item
            --------------------------------------------------

            local item =
                MidiWriter.CreateItem(
                    drumTrack,
                    startQN,
                    endQN
                )

            local take =
                Reaper.GetActiveTake(
                    item
                )

            --------------------------------------------------
            -- Main pattern
            --------------------------------------------------

            local normalBars =
                section.bars

            if fillPattern then

                normalBars =
                    normalBars - 1

            end

            if normalBars > 0 then

                MidiWriter.WritePattern(
                    take,
                    pattern,
                    startQN,
                    settings.beats_per_bar,
                    normalBars
                )

            end

            --------------------------------------------------
            -- Fill
            --------------------------------------------------

            if fillPattern then

                local fillStartQN =
                    startQN
                    + (
                        normalBars
                        * settings.beats_per_bar
                    )

                MidiWriter.WritePatternAtBar(
                    take,
                    fillPattern,
                    fillStartQN,
                    settings.beats_per_bar
                )

            end

        end

    end

    Reaper.UpdateArrange()

end

return Arrangement