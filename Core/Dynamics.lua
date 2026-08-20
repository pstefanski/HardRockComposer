local Dynamics = {}

function Dynamics.Velocity(velocity, energy)

    energy = energy or 1

    local minimum = 0.65

    local scale = minimum + (1 - minimum) * energy

    local result = velocity * scale

    if result < 1 then
        result = 1
    end

    if result > 127 then
        result = 127
    end

    return math.floor(result + 0.5)

end

return Dynamics
