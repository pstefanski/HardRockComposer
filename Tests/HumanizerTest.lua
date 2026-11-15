local Test = require("Test")
local Humanizer = require("Humanizer")

local function Draw(seed, count)
    Humanizer.SetSeed(seed)
    local values = {}
    for i = 1, count do
        values[i] = Humanizer.Random(-8, 8)
    end
    return values
end

Test.Case("Humanizer: the same seed gives the same sequence", function()
    local first = Draw(123, 50)
    local second = Draw(123, 50)
    for i = 1, #first do
        Test.Equal(second[i], first[i], "draw " .. i)
    end
end)

Test.Case("Humanizer: different seeds give different sequences", function()
    local first = table.concat(Draw(1, 20), ",")
    local second = table.concat(Draw(2, 20), ",")
    Test.True(first ~= second, "sequences should differ")
end)

Test.Case("Humanizer: random values stay within bounds", function()
    Humanizer.SetSeed(42)
    for _ = 1, 1000 do
        local value = Humanizer.Random(-8, 8)
        Test.True(value >= -8 and value <= 8, "out of range: " .. value)
    end
end)

Test.Case("Humanizer: velocity stays a valid MIDI velocity", function()
    Humanizer.SetSeed(7)
    for _ = 1, 200 do
        local high = Humanizer.Velocity(125, 10)
        local low = Humanizer.Velocity(3, 10)
        Test.True(high >= 1 and high <= 127, "high velocity " .. high)
        Test.True(low >= 1 and low <= 127, "low velocity " .. low)
    end
end)

Test.Case("Humanizer: a zero amount changes nothing", function()
    Test.Equal(Humanizer.Velocity(100, 0), 100)
    Test.Equal(Humanizer.Timing(0), 0)
end)
