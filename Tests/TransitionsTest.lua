local Test = require("Test")
local Transitions = require("Transitions")

Test.Case("Transitions: a big transition uses the big fill and a crash", function()
    local section = {transition = "big", fill = "fill_snare_pickup"}
    Test.Equal(Transitions.GetFill(section), "fill_big")
    Test.True(Transitions.ShouldCrash(section))
end)

Test.Case("Transitions: otherwise the section fill is used", function()
    local section = {fill = "fill_tom_2beat"}
    Test.Equal(Transitions.GetFill(section), "fill_tom_2beat")
    Test.True(not Transitions.ShouldCrash(section))
    Test.Equal(Transitions.GetFill({}), nil)
end)
