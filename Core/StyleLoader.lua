local Styles = require("Styles.Index")

--------------------------------------------------
-- Loads a style from Styles/<id>/.
--
-- A style returns everything the Builder needs:
--
--     {
--         id, name,
--         settings,      -- SongSettings
--         structure,     -- SongStructure
--         patternSets,   -- { Drums }
--         grooves,       -- Drums.grooves (see DrumGroove)
--         layout         -- the style TrackLayout, or Data/TrackLayout.lua
--     }
--------------------------------------------------

local StyleLoader = {}

function StyleLoader.Available()

    return Styles

end

local function Find(id)

    for _, style in ipairs(Styles) do

        if style.id == id then
            return style
        end

    end

    return nil

end

function StyleLoader.Exists(id)

    return Find(id) ~= nil

end

local function AvailableIds()

    local ids = {}

    for _, style in ipairs(Styles) do
        table.insert(ids, style.id)
    end

    return table.concat(ids, ", ")

end

local function HasModule(name)

    return package.searchpath(name, package.path) ~= nil

end

function StyleLoader.Load(id)

    local entry = Find(id)

    if not entry then

        error("Unknown style '" .. tostring(id) .. "' (available: " .. AvailableIds() .. ")", 0)

    end

    local prefix = "Styles." .. entry.id .. "."

    local drums = require(prefix .. "Drums")

    local layoutModule = HasModule(prefix .. "TrackLayout") and prefix .. "TrackLayout" or "TrackLayout"

    return {

        id = entry.id,

        name = entry.name,

        settings = require(prefix .. "SongSettings"),

        structure = require(prefix .. "SongStructure"),

        patternSets = {drums},

        grooves = drums.grooves or {},

        layout = require(layoutModule)

    }

end

return StyleLoader
