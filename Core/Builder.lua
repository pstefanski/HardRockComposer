local Tracks = require("Tracks")
local Routing = require("Routing")
local Properties = require("Properties")

local Builder = {}

--------------------------------------------------
-- Build stages
--------------------------------------------------

local stages = {

    {
        name = "Tracks",

        apply = function(layout, context)

            Tracks.Apply(layout, context)

        end
    },

    {
        name = "Routing",

        apply = function(_, context)

            Routing.Apply(context)

        end
    },

    {
        name = "Properties",

        apply = function(_, context)

            Properties.Apply(context)

        end
    }

}

--------------------------------------------------
-- Builder
--------------------------------------------------

function Builder.Build(layout)

    local context = {

        groups = {},
        tracks = {},

        registry = {

            groups = {},
            tracks = {}

        }

    }

    for _, stage in ipairs(stages) do

        stage.apply(layout, context)

    end

    return context

end

return Builder