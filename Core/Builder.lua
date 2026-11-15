local Tracks = require("Tracks")
local Routing = require("Routing")
local Properties = require("Properties")
local Song = require("Song")
local Markers = require("Markers")
local Regions = require("Regions")
local Plugins = require("Plugins")
local Patterns = require("Patterns")
local Arrangement = require("Arrangement")
local ColorsPalette = require("ColorsPalette")
local Project = require("Project")
local Validator = require("Validator")
local Config = require("Config")

local Builder = {}

--------------------------------------------------
-- Build stages
--------------------------------------------------

local stages = {{
    name = "Project",

    apply = function(style, context)

        Project.Apply(style.settings, Config)

    end
}, {
    name = "Tracks",

    apply = function(style, context)

        Tracks.Apply(style.layout, context)

    end
}, {
    name = "Routing",

    apply = function(style, context)

        Routing.Apply(context)

    end
}, {
    name = "Properties",

    apply = function(style, context)

        Properties.Apply(context)

    end
}, {
    name = "Plugins",

    apply = function(style, context)

        Plugins.Apply(context)

    end
}, {
    name = "Song",

    apply = function(style, context)

        Song.Apply(style.structure, context, style.settings)

    end
}, {
    name = "Markers",

    apply = function(style, context)

        Markers.Apply(context, style.settings)

    end
}, {
    name = "Regions",

    apply = function(style, context)

        Regions.Apply(context, style.settings)

    end
}, {
    name = "Patterns",

    apply = function(style, context)

        Patterns.Apply(style.patternSets, context)

    end
}, {
    name = "Arrangement",

    apply = function(style, context)

        Arrangement.Apply(context, style.settings)

    end
}}

--------------------------------------------------
-- Builder
--------------------------------------------------

-- style: see StyleLoader.Load
function Builder.Build(style)

    Validator.Assert({

        layout = style.layout,
        structure = style.structure,
        patternSets = style.patternSets,
        settings = style.settings,
        palette = ColorsPalette

    })

    local context = {

        groups = {},
        tracks = {},
        song = {},
        report = {},

        registry = {

            groups = {},
            tracks = {},
            plugins = {},
            song = {},
            patterns = {}

        }

    }

    for _, stage in ipairs(stages) do

        stage.apply(style, context)

    end

    return context

end

return Builder
