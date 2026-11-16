local Config = require("Config")
local Logger = require("Logger")
local StyleLoader = require("StyleLoader")
local Session = require("Session")
local Generator = require("Generator")
local Plugins = require("Plugins")
local PluginScanner = require("PluginScanner")
local Harmony = require("Harmony")
local Timing = require("Timing")

--------------------------------------------------
-- The HardRock Composer window.
--
-- Drawing only: every decision is delegated to Session, Generator and
-- PluginScanner. ReaImGui is passed to Frame(), so the window can be run
-- with a fake ImGui in the tests.
--------------------------------------------------

local Window = {}

Window.__index = Window

local COLORS = {
    ok = 0x6BCB77FF,
    fallback = 0xF4A261FF,
    skipped = 0x9E9E9EFF,
    missing = 0xE76F51FF,
    error = 0xE76F51FF
}

local STATUS_LABELS = {
    ok = "OK",
    fallback = "Fallback",
    skipped = "Skipped",
    missing = "Missing"
}

local BASS_MODES = {{
    id = "kick",
    label = "On the kick"
}, {
    id = "eighths",
    label = "Eighth notes"
}, {
    id = "boogie",
    label = "Boogie"
}}

local PLAY_LABELS = {
    always = "Always",
    never = "Never",
    seed = "Seed"
}

local function ComboItems(labels)

    return table.concat(labels, "\0") .. "\0"

end

local function IndexOf(list, predicate)

    for index, item in ipairs(list) do
        if predicate(item) then
            return index
        end
    end

    return 1

end

--------------------------------------------------
-- State
--------------------------------------------------

function Window.New()

    local self = setmetatable({}, Window)

    self.styles = StyleLoader.Available()

    local lastStyle = Session.LastStyle()

    self:SelectStyle(StyleLoader.Exists(lastStyle) and lastStyle or Config.Style)

    return self

end

function Window:SelectStyle(id)

    self.style = StyleLoader.Load(id)
    self.options = Session.Load(self.style)
    self.scan = nil
    self.result = nil

end

function Window:Save()

    Session.Save(self.options)

end

function Window:Generate()

    self:Save()

    local ok, result = Generator.Run(self.style, self.options)

    if ok then

        self.result = {
            ok = true,
            sections = #result.song,
            summary = Plugins.Summary(result)
        }

    else

        self.result = {
            ok = false,
            message = result
        }

    end

end

function Window:Scan()

    self.scan = PluginScanner.Scan(self.style.layout)

end

function Window:ResetOptions()

    local target = self.options.target

    self.options = Session.Defaults(self.style)
    self.options.target = target

end

--------------------------------------------------
-- Song tab
--------------------------------------------------

function Window:DrawSong(ImGui, ctx)

    local options = self.options
    local settings = self.style.settings
    local changed, value

    ImGui.SetNextItemWidth(ctx, 160)
    changed, value = ImGui.InputDouble(ctx, "Tempo (BPM, quarter note)", options.tempo, 1, 10, "%.1f")

    if changed then
        options.tempo = math.max(20, math.min(400, value))
    end

    ImGui.Text(ctx, string.format("Time signature: %d/%d (set by the style)", settings.beats_per_bar,
        settings.beat_unit))

    local keyIndex = IndexOf(Harmony.KEYS, function(key)
        return key == options.key
    end)

    ImGui.SetNextItemWidth(ctx, 160)
    changed, value = ImGui.Combo(ctx, "Key", keyIndex - 1, ComboItems(Harmony.KEYS))

    if changed then
        options.key = Harmony.KEYS[value + 1]
    end

    ImGui.SetNextItemWidth(ctx, 160)
    changed, value = ImGui.InputInt(ctx, "Structure seed", options.structure_seed)

    if changed then
        options.structure_seed = value
    end

    ImGui.SameLine(ctx)

    if ImGui.Button(ctx, "Random seed") then
        options.structure_seed = math.random(1, 9999)
    end

    ImGui.SetNextItemWidth(ctx, 160)
    changed, value = ImGui.SliderInt(ctx, "Count-in (bars)", options.count_in, 0, 4)

    if changed then
        options.count_in = value
    end

    if options.bass_mode then

        local labels = {}

        for _, mode in ipairs(BASS_MODES) do
            table.insert(labels, mode.label)
        end

        local bassIndex = IndexOf(BASS_MODES, function(mode)
            return mode.id == options.bass_mode
        end)

        ImGui.SetNextItemWidth(ctx, 160)
        changed, value = ImGui.Combo(ctx, "Bass", bassIndex - 1, ComboItems(labels))

        if changed then
            options.bass_mode = BASS_MODES[value + 1].id
        end

    end

    if options.swing then

        ImGui.SetNextItemWidth(ctx, 160)
        changed, value = ImGui.SliderDouble(ctx, "Swing", options.swing, 0, 1, "%.2f")

        if changed then
            options.swing = value
        end

    end

    ImGui.Spacing(ctx)
    ImGui.SeparatorText(ctx, "Generate into")

    changed, value = ImGui.RadioButtonEx(ctx, "The current project (its tracks are replaced)", options.target,
        "replace")

    if changed then
        options.target = value
    end

    changed, value = ImGui.RadioButtonEx(ctx, "A new project tab", options.target, "new_tab")

    if changed then
        options.target = value
    end

    ImGui.Spacing(ctx)

    if ImGui.Button(ctx, "Reset to style defaults") then
        self:ResetOptions()
    end

end

--------------------------------------------------
-- Sections tab
--------------------------------------------------

function Window:DrawSections(ImGui, ctx)

    local options = self.options
    local qnPerBar = Timing.QNPerBar(self.style.settings)
    local pending = nil

    local flags = ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg

    if ImGui.BeginTable(ctx, "sections", 5, flags) then

        ImGui.TableSetupColumn(ctx, "Section", ImGui.TableColumnFlags_WidthStretch)
        ImGui.TableSetupColumn(ctx, "Bars", ImGui.TableColumnFlags_WidthFixed, 90)
        ImGui.TableSetupColumn(ctx, "Energy", ImGui.TableColumnFlags_WidthFixed, 110)
        ImGui.TableSetupColumn(ctx, "Play", ImGui.TableColumnFlags_WidthFixed, 90)
        ImGui.TableSetupColumn(ctx, "", ImGui.TableColumnFlags_WidthFixed, 110)
        ImGui.TableHeadersRow(ctx)

        for index, section in ipairs(options.sections) do

            local changed, value

            ImGui.PushID(ctx, tostring(index))
            ImGui.TableNextRow(ctx)

            ImGui.TableNextColumn(ctx)
            ImGui.SetNextItemWidth(ctx, -1)
            changed, value = ImGui.InputText(ctx, "##name", section.name)

            if changed and value ~= "" then
                section.name = value
            end

            ImGui.TableNextColumn(ctx)
            ImGui.SetNextItemWidth(ctx, -1)
            changed, value = ImGui.InputInt(ctx, "##bars", section.bars)

            if changed then
                section.bars = math.max(1, math.min(256, value))
            end

            ImGui.TableNextColumn(ctx)
            ImGui.SetNextItemWidth(ctx, -1)
            changed, value = ImGui.SliderDouble(ctx, "##energy", section.energy, 0, 1, "%.2f")

            if changed then
                section.energy = value
            end

            ImGui.TableNextColumn(ctx)
            ImGui.SetNextItemWidth(ctx, -1)

            local choices = {"always", "never"}

            if section.play == "seed" or self:HasChance(section.source) then
                table.insert(choices, "seed")
            end

            local labels = {}

            for _, choice in ipairs(choices) do
                table.insert(labels, PLAY_LABELS[choice])
            end

            local playIndex = IndexOf(choices, function(choice)
                return choice == section.play
            end)

            changed, value = ImGui.Combo(ctx, "##play", playIndex - 1, ComboItems(labels))

            if changed then
                section.play = choices[value + 1]
            end

            ImGui.TableNextColumn(ctx)

            if ImGui.SmallButton(ctx, "Up") then
                pending = {"move", index, -1}
            end

            ImGui.SameLine(ctx)

            if ImGui.SmallButton(ctx, "Dn") then
                pending = {"move", index, 1}
            end

            ImGui.SameLine(ctx)

            if ImGui.SmallButton(ctx, "+") then
                pending = {"duplicate", index}
            end

            ImGui.SameLine(ctx)

            if ImGui.SmallButton(ctx, "x") then
                pending = {"remove", index}
            end

            ImGui.PopID(ctx)

        end

        ImGui.EndTable(ctx)

    end

    -- The list is changed after drawing, never while iterating it.
    if pending then

        if pending[1] == "move" then
            Session.MoveSection(options, pending[2], pending[3])
        elseif pending[1] == "duplicate" then
            Session.DuplicateSection(options, pending[2])
        else
            Session.RemoveSection(options, pending[2])
        end

    end

    local bars, optional = 0, 0

    for _, section in ipairs(options.sections) do

        if section.play == "always" then
            bars = bars + section.bars
        elseif section.play == "seed" then
            optional = optional + section.bars
        end

    end

    local seconds = bars * qnPerBar * 60 / options.tempo

    ImGui.Text(ctx, string.format("Length: %d bars (%d:%02d)", bars, math.floor(seconds / 60), math.floor(seconds % 60)))

    if optional > 0 then
        ImGui.TextDisabled(ctx, string.format("+ up to %d bars of optional sections, drawn from the seed", optional))
    end

end

function Window:HasChance(sourceId)

    for _, section in ipairs(self.style.structure) do
        if section.id == sourceId then
            return section.chance ~= nil
        end
    end

    return false

end

--------------------------------------------------
-- Plugins tab
--------------------------------------------------

function Window:DrawPlugins(ImGui, ctx)

    if ImGui.Button(ctx, "Scan installed plugins") then
        self:Scan()
    end

    ImGui.TextDisabled(ctx, "Estimate from the installed plugins: the generation report is authoritative.")

    if not self.scan then
        return
    end

    local flags = ImGui.TableFlags_Borders | ImGui.TableFlags_RowBg

    if ImGui.BeginTable(ctx, "plugins", 4, flags) then

        ImGui.TableSetupColumn(ctx, "Plugin", ImGui.TableColumnFlags_WidthStretch)
        ImGui.TableSetupColumn(ctx, "Track", ImGui.TableColumnFlags_WidthFixed, 110)
        ImGui.TableSetupColumn(ctx, "Status", ImGui.TableColumnFlags_WidthFixed, 80)
        ImGui.TableSetupColumn(ctx, "Preset", ImGui.TableColumnFlags_WidthFixed, 90)
        ImGui.TableHeadersRow(ctx)

        for _, entry in ipairs(self.scan) do

            ImGui.TableNextRow(ctx)

            ImGui.TableNextColumn(ctx)
            ImGui.Text(ctx, entry.used or entry.requested)

            if ImGui.IsItemHovered(ctx) then
                ImGui.SetTooltip(ctx, entry.installed or ("Not installed: " .. entry.requested))
            end

            ImGui.TableNextColumn(ctx)
            ImGui.Text(ctx, entry.track)

            ImGui.TableNextColumn(ctx)
            ImGui.TextColored(ctx, COLORS[entry.status], STATUS_LABELS[entry.status])

            ImGui.TableNextColumn(ctx)

            if entry.preset == nil then
                ImGui.TextDisabled(ctx, "-")
            elseif entry.presetFile then
                ImGui.Text(ctx, "Presets/")
            else
                ImGui.TextDisabled(ctx, "REAPER only")
            end

        end

        ImGui.EndTable(ctx)

    end

end

--------------------------------------------------
-- Frame
--------------------------------------------------

function Window:DrawResult(ImGui, ctx)

    local result = self.result

    if not result then
        return
    end

    ImGui.Separator(ctx)

    if result.ok then

        local summary = result.summary

        ImGui.TextColored(ctx, COLORS.ok, string.format("Generated %d sections.", result.sections))
        ImGui.Text(ctx, string.format("Plugins: %d loaded, %d substituted, %d missing", summary.loaded,
            #summary.substituted, #summary.missing))
        ImGui.Text(ctx, string.format("Presets: %d loaded, %d from Presets/, %d not found", summary.presetsLoaded,
            summary.presetsFromFile, #summary.missingPresets))

    else

        ImGui.TextColored(ctx, COLORS.error, "Generation failed:")
        ImGui.TextWrapped(ctx, result.message)

    end

end

-- Draws one frame. Returns false once the window is closed.
function Window:Frame(ImGui, ctx)

    ImGui.SetNextWindowSize(ctx, 640, 620, ImGui.Cond_FirstUseEver)

    local visible, open = ImGui.Begin(ctx, "HardRock Composer", true)

    if visible then

        local names = {}

        for _, style in ipairs(self.styles) do
            table.insert(names, style.name)
        end

        local styleIndex = IndexOf(self.styles, function(style)
            return style.id == self.style.id
        end)

        ImGui.SetNextItemWidth(ctx, 200)

        local changed, value = ImGui.Combo(ctx, "Style", styleIndex - 1, ComboItems(names))

        if changed then
            self:Save()
            self:SelectStyle(self.styles[value + 1].id)
        end

        ImGui.SameLine(ctx)

        if ImGui.Button(ctx, "Generate") then
            self:Generate()
        end

        if ImGui.BeginTabBar(ctx, "tabs") then

            if ImGui.BeginTabItem(ctx, "Song") then
                self:DrawSong(ImGui, ctx)
                ImGui.EndTabItem(ctx)
            end

            if ImGui.BeginTabItem(ctx, "Sections") then
                self:DrawSections(ImGui, ctx)
                ImGui.EndTabItem(ctx)
            end

            if ImGui.BeginTabItem(ctx, "Plugins") then
                self:DrawPlugins(ImGui, ctx)
                ImGui.EndTabItem(ctx)
            end

            ImGui.EndTabBar(ctx)

        end

        self:DrawResult(ImGui, ctx)

        ImGui.End(ctx)

    end

    if not open then
        self:Save()
    end

    return open

end

return Window
