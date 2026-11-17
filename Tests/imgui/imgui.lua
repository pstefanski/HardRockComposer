-- Fake of ReaImGui's builtin "imgui" module: require("imgui")(version).
local FakeImGui = require("FakeImGui")

return function(version)
    assert(version == "0.10", "unexpected ReaImGui API version " .. tostring(version))
    local fake = FakeImGui.New()
    _G.LAST_FAKE_IMGUI = fake
    return fake.api
end
