local Tracks = require("Tracks")

local Builder = {}

function Builder.Build(layout)

    local context = {

        groups = {},
        tracks = {},

        registry = {

            groups = {},
            tracks = {}

        }

    }

    Tracks.Create(layout, context)

    return context

end

return Builder