local Midi = require("Midi")
local Transitions = require("Transitions")

--------------------------------------------------
-- Validates every declarative data file before the build starts.
--
-- All problems are collected and reported together, so a broken data
-- file never leaves a half-generated project behind.
--------------------------------------------------

local Validator = {}

local SEND_MODES = {
    post_fader = true,
    pre_fx = true,
    post_fx = true
}

local TRANSITIONS = {
    big = true
}

local DRUM_MIDI_TRACK = "ezd_midi"

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function IsNonEmptyString(value)

    return type(value) == "string" and value ~= ""

end

local function IsInteger(value)

    return type(value) == "number" and value % 1 == 0

end

local function NewReport()

    local report = {
        errors = {}
    }

    function report:Add(where, message)

        table.insert(self.errors, where .. ": " .. message)

    end

    return report

end

local function CheckColor(report, where, color, palette)

    if color ~= nil and not palette[color] then

        report:Add(where, "unknown color '" .. tostring(color) .. "'")

    end

end

--------------------------------------------------
-- Settings
--------------------------------------------------

local function ValidateSettings(report, settings)

    local where = "SongSettings"

    if type(settings.tempo) ~= "number" or settings.tempo <= 0 or settings.tempo > 960 then

        report:Add(where, "tempo must be a number between 1 and 960")

    end

    if not IsInteger(settings.beats_per_bar) or settings.beats_per_bar < 1 then

        report:Add(where, "beats_per_bar must be a positive integer")

    end

    -- The MIDI engine counts bars in quarter notes; other units come with the
    -- shuffle/12-8 work planned for the styles sprint.
    if settings.beat_unit ~= 4 then

        report:Add(where, "beat_unit must be 4 (other units are not supported yet)")

    end

    local humanization = settings.humanization

    if humanization ~= nil then

        if type(humanization) ~= "table" then

            report:Add(where, "humanization must be a table")

            return

        end

        if humanization.enabled then

            if type(humanization.seed) ~= "number" then
                report:Add(where, "humanization.seed must be a number")
            end

            for _, field in ipairs({"velocity", "timing"}) do

                local value = humanization[field]

                if type(value) ~= "number" or value < 0 then
                    report:Add(where, "humanization." .. field .. " must be a positive number")
                end

            end

        end

    end

end

--------------------------------------------------
-- Track layout
--------------------------------------------------

local function CollectTrackIds(report, layout)

    local trackIds = {}
    local groupIds = {}

    for groupIndex, group in ipairs(layout) do

        local groupWhere = "TrackLayout group #" .. groupIndex

        if not IsNonEmptyString(group.id) then

            report:Add(groupWhere, "missing id")

        elseif groupIds[group.id] then

            report:Add(groupWhere, "duplicate group id '" .. group.id .. "'")

        else

            groupIds[group.id] = true

        end

        if type(group.tracks) ~= "table" then

            report:Add(groupWhere, "missing tracks list")

        else

            for trackIndex, track in ipairs(group.tracks) do

                if not IsNonEmptyString(track.id) then

                    report:Add(groupWhere .. " track #" .. trackIndex, "missing id")

                elseif trackIds[track.id] then

                    report:Add("track '" .. track.id .. "'", "duplicate track id")

                else

                    trackIds[track.id] = true

                end

            end

        end

    end

    return trackIds

end

local function CheckDestination(report, where, sourceId, destination, trackIds)

    if not IsNonEmptyString(destination) then

        report:Add(where, "missing destination")

    elseif not trackIds[destination] then

        report:Add(where, "unknown destination '" .. destination .. "'")

    elseif destination == sourceId then

        report:Add(where, "a track cannot send to itself")

    end

end

local function ValidateSend(report, where, sourceId, send, trackIds)

    CheckDestination(report, where, sourceId, send.destination, trackIds)

    if send.mode ~= nil and not SEND_MODES[send.mode] then

        report:Add(where, "unknown send mode '" .. tostring(send.mode) .. "'")

    end

    if send.volume ~= nil and type(send.volume) ~= "number" then

        report:Add(where, "send volume must be a number (dB)")

    end

end

local function ValidateRouting(report, track, trackIds)

    local routing = track.routing

    if routing == nil then
        return
    end

    local where = "track '" .. track.id .. "' routing"

    if routing.output ~= nil then

        CheckDestination(report, where .. ".output", track.id, routing.output, trackIds)

    end

    for index, output in ipairs(routing.outputs or {}) do

        ValidateSend(report, where .. ".outputs[" .. index .. "]", track.id, output, trackIds)

    end

    for index, send in ipairs(routing.sends or {}) do

        ValidateSend(report, where .. ".sends[" .. index .. "]", track.id, send, trackIds)

    end

end

local function ValidatePlugins(report, track, trackIds, pluginIds)

    for index, plugin in ipairs(track.plugins or {}) do

        local where = "track '" .. track.id .. "' plugin #" .. index

        if not IsNonEmptyString(plugin.id) then

            report:Add(where, "missing id")

        elseif pluginIds[plugin.id] then

            report:Add(where, "duplicate plugin id '" .. plugin.id .. "'")

        else

            pluginIds[plugin.id] = true

            where = "plugin '" .. plugin.id .. "'"

        end

        if not IsNonEmptyString(plugin.plugin) then

            report:Add(where, "missing plugin name")

        end

        if plugin.outputChannels ~= nil then

            local channels = plugin.outputChannels

            if not IsInteger(channels) or channels < 2 or channels % 2 ~= 0 then

                report:Add(where, "outputChannels must be a positive even integer")

            else

                for outputIndex, output in ipairs(plugin.outputs or {}) do

                    local outputWhere = where .. " output #" .. outputIndex

                    if not IsInteger(output.pair) or output.pair < 1 or output.pair * 2 > channels then

                        report:Add(outputWhere, "invalid pair '" .. tostring(output.pair) .. "'")

                    end

                    CheckDestination(report, outputWhere, track.id, output.destination, trackIds)

                end

            end

        elseif plugin.outputs ~= nil then

            report:Add(where, "outputs require outputChannels")

        end

    end

end

local function ValidateLayout(report, layout, palette)

    local trackIds = CollectTrackIds(report, layout)
    local pluginIds = {}

    for _, group in ipairs(layout) do

        CheckColor(report, "group '" .. tostring(group.id) .. "'", group.color, palette)

        for _, track in ipairs(group.tracks or {}) do

            if IsNonEmptyString(track.id) then

                local where = "track '" .. track.id .. "'"

                if not IsNonEmptyString(track.name) then
                    report:Add(where, "missing name")
                end

                CheckColor(report, where, track.color, palette)

                ValidateRouting(report, track, trackIds)

                ValidatePlugins(report, track, trackIds, pluginIds)

            end

        end

    end

    return trackIds

end

--------------------------------------------------
-- Patterns
--------------------------------------------------

local function ValidatePatterns(report, patternSets, settings)

    local patterns = {}

    for _, patternSet in ipairs(patternSets) do

        for index, pattern in ipairs(patternSet) do

            local where = "pattern #" .. index

            if not IsNonEmptyString(pattern.id) then

                report:Add(where, "missing id")

            elseif patterns[pattern.id] then

                report:Add("pattern '" .. pattern.id .. "'", "duplicate pattern id")

            else

                patterns[pattern.id] = pattern

                where = "pattern '" .. pattern.id .. "'"

            end

            if not IsInteger(pattern.bars) or pattern.bars < 1 then

                report:Add(where, "bars must be a positive integer")

            end

            if not Midi.ValidatePattern(pattern) then

                report:Add(where, "invalid notes (pitch, position, length and velocity must be numbers)")

            end

            local beats = pattern.transitionBeats

            if beats ~= nil and (type(beats) ~= "number" or beats <= 0 or
                (IsInteger(settings.beats_per_bar) and beats > settings.beats_per_bar)) then

                report:Add(where, "transitionBeats must be between 0 and beats_per_bar")

            end

        end

    end

    return patterns

end

--------------------------------------------------
-- Song structure
--------------------------------------------------

local function CheckPatternReference(report, where, role, id, patterns)

    if id == nil then
        return
    end

    if not patterns[id] then

        report:Add(where, "unknown " .. role .. " pattern '" .. tostring(id) .. "'")

    end

end

local function ValidateStructure(report, structure, patterns, palette, trackIds)

    local sectionIds = {}
    local usesDrums = false

    for index, section in ipairs(structure) do

        local where = "section #" .. index

        if not IsNonEmptyString(section.id) then

            report:Add(where, "missing id")

        elseif sectionIds[section.id] then

            report:Add("section '" .. section.id .. "'", "duplicate section id")

        else

            sectionIds[section.id] = true

            where = "section '" .. section.id .. "'"

        end

        if not IsNonEmptyString(section.name) then
            report:Add(where, "missing name")
        end

        if not IsInteger(section.bars) or section.bars < 1 then
            report:Add(where, "bars must be a positive integer")
        end

        CheckColor(report, where, section.color, palette)

        if section.energy ~= nil and (type(section.energy) ~= "number" or section.energy < 0 or section.energy > 1) then
            report:Add(where, "energy must be between 0 and 1")
        end

        if section.transition ~= nil and not TRANSITIONS[section.transition] then
            report:Add(where, "unknown transition '" .. tostring(section.transition) .. "'")
        end

        local drums = section.patterns and section.patterns.drums

        if drums ~= nil then

            usesDrums = true

            if type(drums) == "string" then

                CheckPatternReference(report, where, "drum", drums, patterns)

            elseif type(drums) == "table" then

                if drums.primary == nil then
                    report:Add(where, "drums.primary is required")
                end

                CheckPatternReference(report, where, "primary", drums.primary, patterns)
                CheckPatternReference(report, where, "variation", drums.variation, patterns)
                CheckPatternReference(report, where, "opening", drums.opening, patterns)

            else

                report:Add(where, "patterns.drums must be a pattern id or a table")

            end

            CheckPatternReference(report, where, "fill", Transitions.GetFill(section, structure[index + 1]), patterns)

        end

    end

    if usesDrums and not trackIds[DRUM_MIDI_TRACK] then

        report:Add("TrackLayout", "drum patterns require a '" .. DRUM_MIDI_TRACK .. "' track")

    end

end

--------------------------------------------------
-- Public
--------------------------------------------------

-- data = { layout, structure, patternSets, settings, palette }
-- Returns the list of error messages (empty when the data is valid).
function Validator.Validate(data)

    local report = NewReport()

    ValidateSettings(report, data.settings)

    local trackIds = ValidateLayout(report, data.layout, data.palette)

    local patterns = ValidatePatterns(report, data.patternSets, data.settings)

    ValidateStructure(report, data.structure, patterns, data.palette, trackIds)

    return report.errors

end

-- Raises a single error listing every problem found.
function Validator.Assert(data)

    local errors = Validator.Validate(data)

    if #errors > 0 then

        error("Invalid project data (" .. #errors .. " error(s)):\n  - " .. table.concat(errors, "\n  - "), 0)

    end

end

return Validator
