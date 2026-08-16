local Patterns = {}

function Patterns.Apply(patternSets, context)

    for _, patternSet in ipairs(patternSets) do

        for _, pattern in ipairs(patternSet) do

            context.registry.patterns[pattern.id] = pattern

        end

    end

end

return Patterns