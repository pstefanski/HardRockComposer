local Tracks = require("Tracks")

local Builder = {}

function Builder.Build(layout)

    local context = {

        groups = {},
        tracks = {}

    }

    Tracks.Create(layout, context)

    return context

end

return Builder