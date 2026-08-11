local Tracks = require("Tracks")
local Routing = require("Routing")
local Properties = require("Properties")
local Song = require("Song")
local SongStructure = require("SongStructure")
local Plugins = require("Plugins")

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
    },

    {
        name = "Song",

        apply = function(_, context)

            Song.Apply(
                SongStructure,
                context
            )

        end
    },

    {
        name = "Plugins",

        apply = function(_, context)

            Plugins.Apply(context)

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
        song = {},

        registry = {

            groups = {},
            tracks = {},
            plugins = {},
            song = {}

        }

    }

    for _, stage in ipairs(stages) do

        stage.apply(layout, context)

    end

    return context

end

return Builder