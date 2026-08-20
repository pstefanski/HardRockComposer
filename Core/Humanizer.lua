local Humanizer = {}

local state = 1

function Humanizer.SetSeed(seed)

    state = seed

end

function Humanizer.Random(min, max)

    state = (state * 1103515245 + 12345) % 2147483648

    local normalized = state / 2147483648

    return math.floor(min + normalized * (max - min + 1))

end

function Humanizer.Velocity(velocity, amount)

    if amount <= 0 then
        return velocity
    end

    local variation = Humanizer.Random(-amount, amount)

    return math.max(1, math.min(127, velocity + variation))

end

function Humanizer.Timing(amount)

    if amount <= 0 then
        return 0
    end

    return Humanizer.Random(-amount, amount)

end

return Humanizer
