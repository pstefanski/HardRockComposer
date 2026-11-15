local Random = require("Random")

local Humanizer = {}

local generator = Random.New(1)

function Humanizer.SetSeed(seed)

    generator = Random.New(seed)

end

function Humanizer.Random(min, max)

    return generator:Int(min, max)

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
