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

        if section.patterns
        and section.patterns.drums then

            local patternId =
                section.patterns.drums

            local pattern =
                context.registry.patterns[
                    patternId
                ]

            if pattern then

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

                MidiWriter.WritePattern(
                    take,
                    pattern,
                    startQN,
                    settings.beats_per_bar,
                    section.bars
                )

            end

        end

    end

    Reaper.UpdateArrange()

end

return Arrangement