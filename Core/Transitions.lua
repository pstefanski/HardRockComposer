local Transitions = {}

function Transitions.GetFill(section, nextSection)

    if section.transition == "big" then

        return "fill_big"

    end

    return section.fill

end

function Transitions.ShouldCrash(section)

    return section.transition == "big"

end

return Transitions
