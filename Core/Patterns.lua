local Midi = require("Midi")
local Patterns = {}

function Patterns.Apply(patternSets, context)

    for _, patternSet in ipairs(patternSets) do

        for _, pattern in ipairs(patternSet) do

            if pattern.type == "drums" then

                if not Midi.ValidatePattern(pattern) then

                    error(
                        "Invalid MIDI pattern: " ..
                        tostring(pattern.id)
                    )

                end

            end

            context.registry.patterns[pattern.id] = pattern

        end

    end

end

return Patterns