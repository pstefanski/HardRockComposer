local Tracks = require("Tracks")
local Routing = require("Routing")
local Properties = require("Properties")

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

    Routing.Apply(context)

    Properties.Apply(context)

    return context

end

return Builder