--------------------------------------------------
-- Deterministic pseudo-random generator (linear congruential).
--
-- The same seed always gives the same sequence, on every platform, so a
-- generated project can be reproduced exactly.
--------------------------------------------------

local Random = {}

Random.__index = Random

local MODULUS = 2147483648

function Random.New(seed)

    return setmetatable({
        state = seed or 1
    }, Random)

end

-- Spreads a small seed over the whole state space. Without it, the first
-- draws of consecutive seeds (1, 2, 3, ...) are strongly correlated.
function Random.Mix(seed)

    local x = math.floor(seed or 1) % MODULUS

    x = (((x >> 16) ~ x) * 0x45d9f3b) % MODULUS
    x = (((x >> 16) ~ x) * 0x45d9f3b) % MODULUS
    x = (x >> 16) ~ x

    return x

end

-- Uniform float in [0, 1[.
function Random:Float()

    self.state = (self.state * 1103515245 + 12345) % MODULUS

    return self.state / MODULUS

end

-- Uniform integer in [min, max].
function Random:Int(min, max)

    return math.floor(min + self:Float() * (max - min + 1))

end

return Random
