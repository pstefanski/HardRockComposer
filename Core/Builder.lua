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
local MidiTracks = require("MidiTracks")
local MidiWriter = require("MidiWriter")
local Reaper = require("Reaper")

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
        name = "Markers",

        apply = function(_, context)

            Markers.Apply(context)

        end
    },

    {
        name = "Regions",

        apply = function(_, context)

            Regions.Apply(context)

        end
    },

    {
        name = "Patterns",

        apply = function(_, context)

            Patterns.Apply(
                {
                    DrumPatterns
                },
                context
            )

        end
    },

    {
        name = "MIDI Test",

        apply = function(_, context)

            local pattern =
                context.registry.patterns.verse_basic

            if not pattern then
                return
            end

            local track =
                MidiTracks.Create("MIDI Test")

            local item =
                MidiWriter.CreateItem(
                    track,
                    0,
                    2
                )

            local take =
                Reaper.GetActiveTake(item)

            MidiWriter.WritePattern(
                take,
                pattern,
                960
            )

            Reaper.UpdateArrange()

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