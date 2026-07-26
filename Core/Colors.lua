local Reaper = require("Reaper")

local Palette = require("ColorsPalette")

local Colors = {}

function Colors.Apply(trackRef, trackData)

    if not trackData.color then
        return
    end

    local rgb = Palette[trackData.color]

    if not rgb then
        return
    end

    Reaper.SetTrackColor(trackRef, rgb)

end

return Colors