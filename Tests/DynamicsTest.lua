local Test = require("Test")
local Dynamics = require("Dynamics")

Test.Case("Dynamics: full energy keeps the velocity", function()
    Test.Equal(Dynamics.Velocity(100, 1), 100)
    Test.Equal(Dynamics.Velocity(100, nil), 100)
end)

Test.Case("Dynamics: zero energy scales the velocity to 65%", function()
    Test.Equal(Dynamics.Velocity(100, 0), 65)
end)

Test.Case("Dynamics: results are clamped to the MIDI range", function()
    Test.Equal(Dynamics.Velocity(1, 0), 1)
    Test.Equal(Dynamics.Velocity(200, 1), 127)
end)
