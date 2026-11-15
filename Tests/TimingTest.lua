local Test = require("Test")
local Timing = require("Timing")

local settings = {
    beats_per_bar = 4,
    beat_unit = 4
}

Test.Case("Timing: bar 1 starts at quarter note 0", function()
    Test.Equal(Timing.BarToQN(1, settings), 0)
end)

Test.Case("Timing: bars are beats_per_bar quarter notes long", function()
    Test.Equal(Timing.BarToQN(3, settings), 8)
    Test.Equal(Timing.BarsToQN(16, settings), 64)
    Test.Equal(Timing.BarToQN(2, {beats_per_bar = 3}), 3)
end)

Test.Case("Timing: positions are sixteenth notes inside the bar", function()
    Test.Equal(Timing.PositionToQN(2, 4, settings), 5)
    Test.Equal(Timing.PositionToQN(1, 15, settings), 3.75)
end)
