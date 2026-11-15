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
    Test.Equal(Timing.BarToQN(2, {beats_per_bar = 3, beat_unit = 4}), 3)
end)

Test.Case("Timing: positions are sixteenth notes inside the bar", function()
    Test.Equal(Timing.PositionToQN(2, 4, settings), 5)
    Test.Equal(Timing.PositionToQN(1, 15, settings), 3.75)
end)

Test.Case("Timing: bar length follows the time signature", function()
    Test.Equal(Timing.QNPerBar({beats_per_bar = 4, beat_unit = 4}), 4)
    Test.Equal(Timing.QNPerBar({beats_per_bar = 12, beat_unit = 8}), 6)
    Test.Equal(Timing.QNPerBar({beats_per_bar = 6, beat_unit = 8}), 3)
    Test.Equal(Timing.BarToQN(3, {beats_per_bar = 12, beat_unit = 8}), 12)
end)

Test.Case("Timing: no swing keeps the grid straight", function()
    Test.Equal(Timing.SwingOffsetQN(2, nil), 0)
    Test.Equal(Timing.SwingOffsetQN(2, {amount = 0}), 0)
end)

Test.Case("Timing: eighth swing only moves the off-beat eighths", function()
    local swing = {amount = 1, subdivision = 8}
    Test.Equal(Timing.SwingOffsetQN(0, swing), 0)
    Test.Equal(Timing.SwingOffsetQN(4, swing), 0)
    Test.Equal(Timing.SwingOffsetQN(1, swing), 0)
    -- Full swing puts the off-beat on the last triplet: 1/2 + 1/6 = 2/3.
    Test.Near(0.5 + Timing.SwingOffsetQN(2, swing), 2 / 3)
    Test.Near(Timing.SwingOffsetQN(14, {amount = 0.5, subdivision = 8}), 1 / 12)
end)

Test.Case("Timing: sixteenth swing moves the odd sixteenths", function()
    local swing = {amount = 1, subdivision = 16}
    Test.Equal(Timing.SwingOffsetQN(2, swing), 0)
    Test.Near(0.25 + Timing.SwingOffsetQN(1, swing), 1 / 3)
end)
