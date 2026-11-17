local Reaper = require("Reaper")
local Harmony = require("Harmony")
local Serialize = require("Serialize")

--------------------------------------------------
-- The user's choices for a style, edited in the window and remembered
-- between REAPER sessions:
--
--     {
--         style = "HardRock",
--         tempo = 140,
--         key = "E",
--         structure_seed = 1,
--         count_in = 0,            -- bars, 0 = none
--         bass_mode = "eighths",   -- nil when the style has no bass
--         swing = 0.3,             -- nil when the style has no swing setting
--         target = "replace",      -- "replace" the current project or "new_tab"
--         sections = {
--             { source = "intro", name = "Intro", bars = 8, energy = 0.3, play = "always" },
--             ...                  -- play: "always", "never" or "seed" (sections with chance)
--         }
--     }
--
-- Session.Apply turns a style and these choices into the style that is built.
--------------------------------------------------

local Session = {}

local EXT_SECTION = "HardRockComposer"

Session.PLAY = {"always", "never", "seed"}
Session.TARGETS = {"replace", "new_tab"}

local function DeepCopy(value)

    if type(value) ~= "table" then
        return value
    end

    local copy = {}

    for key, item in pairs(value) do
        copy[key] = DeepCopy(item)
    end

    return copy

end

Session.DeepCopy = DeepCopy

local function FindSection(style, id)

    for _, section in ipairs(style.structure) do

        if section.id == id then
            return section
        end

    end

    return nil

end

local function DefaultSections(style)

    local sections = {}

    for _, section in ipairs(style.structure) do

        table.insert(sections, {
            source = section.id,
            name = section.name,
            bars = section.bars,
            energy = section.energy or 1,
            play = section.chance ~= nil and "seed" or "always"
        })

    end

    return sections

end

function Session.Defaults(style)

    local settings = style.settings

    return {
        style = style.id,
        tempo = settings.tempo,
        key = settings.key or "E",
        structure_seed = settings.structure_seed or 1,
        count_in = settings.count_in and settings.count_in.bars or 0,
        bass_mode = settings.bass and (settings.bass.mode or "kick") or nil,
        swing = settings.swing and settings.swing.amount or nil,
        target = "replace",
        sections = DefaultSections(style)
    }

end

local function Contains(list, value)

    for _, item in ipairs(list) do
        if item == value then
            return true
        end
    end

    return false

end

local function IsNumber(value)

    return type(value) == "number" and value == value

end

-- Repairs choices saved by an older version or edited by hand: unknown or
-- invalid values fall back to the style defaults.
function Session.Normalize(style, options)

    local defaults = Session.Defaults(style)

    if type(options) ~= "table" or options.style ~= style.id then
        return defaults
    end

    local result = DeepCopy(defaults)

    if IsNumber(options.tempo) and options.tempo > 0 and options.tempo <= 960 then
        result.tempo = options.tempo
    end

    if Harmony.KeyPitch(options.key) then
        result.key = options.key
    end

    if math.type(options.structure_seed) == "integer" then
        result.structure_seed = options.structure_seed
    end

    if math.type(options.count_in) == "integer" and options.count_in >= 0 and options.count_in <= 8 then
        result.count_in = options.count_in
    end

    if defaults.bass_mode and type(options.bass_mode) == "string" then
        result.bass_mode = options.bass_mode
    end

    if defaults.swing and IsNumber(options.swing) and options.swing >= 0 and options.swing <= 1 then
        result.swing = options.swing
    end

    if Contains(Session.TARGETS, options.target) then
        result.target = options.target
    end

    if type(options.sections) == "table" then

        local sections = {}

        for _, entry in ipairs(options.sections) do

            local source = type(entry) == "table" and FindSection(style, entry.source)

            if source then

                local section = {
                    source = source.id,
                    name = type(entry.name) == "string" and entry.name ~= "" and entry.name or source.name,
                    bars = math.type(entry.bars) == "integer" and entry.bars >= 1 and entry.bars or source.bars,
                    energy = IsNumber(entry.energy) and entry.energy >= 0 and entry.energy <= 1 and entry.energy or
                        (source.energy or 1),
                    play = Contains(Session.PLAY, entry.play) and entry.play or "always"
                }

                if section.play == "seed" and source.chance == nil then
                    section.play = "always"
                end

                table.insert(sections, section)

            end

        end

        if #sections > 0 then
            result.sections = sections
        end

    end

    return result

end

--------------------------------------------------
-- Applying the choices
--------------------------------------------------

local function UniqueId(base, used)

    if not used[base] then
        return base
    end

    local index = 2

    while used[base .. "_" .. index] do
        index = index + 1
    end

    return base .. "_" .. index

end

-- Returns a copy of `style` with the choices applied.
function Session.Apply(style, options)

    local result = DeepCopy(style)
    local settings = result.settings

    settings.tempo = options.tempo
    settings.structure_seed = options.structure_seed
    settings.count_in = options.count_in > 0 and {
        bars = options.count_in
    } or nil

    if settings.bass and options.bass_mode then
        settings.bass.mode = options.bass_mode
    end

    if settings.swing and options.swing then
        settings.swing.amount = options.swing
    end

    local semitones = 0

    if settings.key and Harmony.KeyPitch(options.key) then

        semitones = (Harmony.KeyPitch(options.key) - Harmony.KeyPitch(settings.key)) % 12
        settings.key = options.key

    end

    local structure = {}
    local used = {}

    for _, entry in ipairs(options.sections) do

        local source = FindSection(style, entry.source)

        if source and entry.play ~= "never" then

            local section = DeepCopy(source)

            section.id = UniqueId(source.id, used)
            section.name = entry.name
            section.bars = entry.bars
            section.energy = entry.energy

            if entry.play == "always" then
                section.chance = nil
            end

            if section.chords then

                for index, symbol in ipairs(section.chords) do
                    section.chords[index] = Harmony.Transpose(symbol, semitones)
                end

            end

            used[section.id] = true

            table.insert(structure, section)

        end

    end

    result.structure = structure

    return result

end

--------------------------------------------------
-- Editing the sections
--------------------------------------------------

function Session.MoveSection(options, index, offset)

    local target = index + offset
    local sections = options.sections

    if target < 1 or target > #sections then
        return false
    end

    sections[index], sections[target] = sections[target], sections[index]

    return true

end

function Session.DuplicateSection(options, index)

    local copy = DeepCopy(options.sections[index])

    table.insert(options.sections, index + 1, copy)

end

function Session.RemoveSection(options, index)

    if #options.sections <= 1 then
        return false
    end

    table.remove(options.sections, index)

    return true

end

--------------------------------------------------
-- Persistence (REAPER ExtState)
--------------------------------------------------

function Session.Load(style)

    local text = Reaper.GetExtState(EXT_SECTION, "session." .. style.id)

    return Session.Normalize(style, Serialize.Decode(text))

end

function Session.Save(options)

    Reaper.SetExtState(EXT_SECTION, "session." .. options.style, Serialize.Encode(options))
    Reaper.SetExtState(EXT_SECTION, "style", options.style)

end

-- The style used last time, or nil.
function Session.LastStyle()

    return Reaper.GetExtState(EXT_SECTION, "style")

end

return Session
