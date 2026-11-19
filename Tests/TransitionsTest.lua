local Test = require("Test")
local Transitions = require("Transitions")

Test.Case("Transitions: a fill written by hand always wins", function()
    local section = {transition = "big", fill = "fill_snare_pickup"}
    Test.Equal(Transitions.Resolve(section, nil, false).pattern, "fill_snare_pickup")
    Test.Equal(Transitions.Resolve(section, nil, true).pattern, "fill_snare_pickup")
end)

Test.Case("Transitions: without generated fills, big plays the fill_big pattern", function()
    Test.Equal(Transitions.Resolve({transition = "big"}, nil, false).pattern, "fill_big")
    Test.Equal(Transitions.Resolve({}, {}, false), nil)
    Test.Equal(Transitions.Resolve({transition = "none"}, {}, false), nil)
    Test.Equal(Transitions.Resolve({transition = "build"}, {}, false).kind, "build")
end)

Test.Case("Transitions: with generated fills, the energy of the next section chooses", function()
    Test.Equal(Transitions.Resolve({energy = 0.6}, {energy = 1.0}, true).kind, "big")
    Test.Equal(Transitions.Resolve({energy = 0.6}, {energy = 0.7}, true).kind, "fill")
    Test.Equal(Transitions.Resolve({energy = 1.0}, {energy = 0.5}, true).kind, "fill")
    Test.Equal(Transitions.Resolve({energy = 1.0}, nil, true), nil, "the song ends without a fill")
    Test.Equal(Transitions.Resolve({transition = "pickup", energy = 0.2}, {energy = 1}, true).kind, "pickup")
    Test.Equal(Transitions.Resolve({transition = "none"}, {energy = 1}, true), nil)
end)
