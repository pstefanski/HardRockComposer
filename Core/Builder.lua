local Tracks = require("Tracks")
local Routing = require("Routing")
local Properties = require("Properties")
local Song = require("Song")
local SongStructure = require("SongStructure")
local Markers = require("Markers")
local Regions = require("Regions")
local Plugins = require("Plugins")
local Patterns = require("Patterns")
local DrumPatterns = require("Patterns.Drums")
local Arrangement = require("Arrangement")
local SongSettings = require("SongSettings")

local Builder = {}

--------------------------------------------------
-- Build stages
--------------------------------------------------

local stages = {{
    name = "Tracks",

    apply = function(layout, context)

        Tracks.Apply(layout, context)

    end
}, {
    name = "Routing",

    apply = function(_, context)

        Routing.Apply(context)

    end
}, {
    name = "Properties",

    apply = function(_, context)

        Properties.Apply(context)

    end
}, {
    name = "Song",

    apply = function(_, context)

        Song.Apply(SongStructure, context)

    end
}, {
    name = "Markers",

    apply = function(_, context)

        Markers.Apply(context, SongSettings)

    end
}, {
    name = "Regions",

    apply = function(_, context)

        Regions.Apply(context, SongSettings)

    end
}, {
    name = "Patterns",

    apply = function(_, context)

        Patterns.Apply({DrumPatterns}, context)

    end
}, {
    name = "Arrangement",

    apply = function(_, context)

        Arrangement.Apply(context, SongSettings)

    end
}, {
    name = "Plugins",

    apply = function(_, context)

        Plugins.Apply(context)

    end
}}

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
            song = {},
            patterns = {}

        }

    }

    for _, stage in ipairs(stages) do

        stage.apply(layout, context)

    end

    return context

end

return Builder
