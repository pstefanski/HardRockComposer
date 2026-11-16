local Reaper = require("Reaper")
local Timing = require("Timing")

--------------------------------------------------
-- Drives track levels with the energy of each section.
--
--     automation = {
--         volume = { low = -3, high = 0 }   -- dB at energy 0 and energy 1
--     }
--
-- The offset is added to the track volume (`properties.volume`) and written
-- as a volume envelope, one point at the start of every section.
--------------------------------------------------

local Automation = {}

function Automation.VolumeAt(volume, baseDb, energy)

    return baseDb + volume.low + (volume.high - volume.low) * energy

end

function Automation.Apply(context, settings)

    for _, entry in ipairs(context.tracks) do

        local volume = entry.data.automation and entry.data.automation.volume

        if volume and #context.song > 0 then

            local baseDb = entry.data.properties and entry.data.properties.volume or 0
            local envelope = Reaper.GetVolumeEnvelope(entry.track)

            for _, section in ipairs(context.song) do

                local time = Reaper.QNToTime(Timing.BarToQN(section.startBar, settings))
                local db = Automation.VolumeAt(volume, baseDb, section.energy or 1)

                Reaper.AddEnvelopePointDB(envelope, time, db)

            end

            Reaper.SortEnvelope(envelope)

        end

    end

end

return Automation
