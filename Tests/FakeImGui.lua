--------------------------------------------------
-- Stand-in for ReaImGui used to run the window in the tests.
--
-- Only the functions the window uses exist: calling any other one fails,
-- which catches typos. Widgets return "unchanged" unless the test scripted
-- an interaction:
--
--     fake:Click("Generate")              -- next Button/SmallButton with this id
--     fake:Click("2/x")                   -- id inside PushID("2")
--     fake:Set("Key", 7)                  -- next widget with this id returns true, 7
--     fake:Close()                        -- the window is closed on the next frame
--------------------------------------------------

local FakeImGui = {}

function FakeImGui.New()

    local fake = {
        texts = {},
        calls = {},
        clicks = {},
        values = {},
        ids = {},
        closing = false
    }

    local api = {}

    local function Id(label)
        if #fake.ids == 0 then
            return label
        end
        return table.concat(fake.ids, "/") .. "/" .. label
    end

    local function Scripted(label)
        local id = Id(label)
        local value = fake.values[id]
        if value ~= nil then
            fake.values[id] = nil
            return true, value
        end
        return false
    end

    local function Widget(label, current)
        local changed, value = Scripted(label)
        if changed then
            return true, value
        end
        return false, current
    end

    local function Clicked(label)
        local id = Id(label)
        if fake.clicks[id] then
            fake.clicks[id] = nil
            return true
        end
        return false
    end

    local function Text(_, text)
        table.insert(fake.texts, text)
    end

    function api.CreateContext()
        return {}
    end

    function api.SetNextWindowSize() end

    function api.Begin()
        fake.texts = {}
        if fake.closing then
            fake.closing = false
            return true, false
        end
        return true, true
    end

    function api.End() end
    function api.SameLine() end
    function api.Spacing() end
    function api.Separator() end
    function api.SetNextItemWidth() end
    function api.EndTabBar() end
    function api.EndTabItem() end
    function api.EndTable() end
    function api.TableSetupColumn() end
    function api.TableHeadersRow() end
    function api.TableNextRow() end
    function api.TableNextColumn() end
    function api.SetTooltip() end

    function api.BeginTabBar()
        return true
    end

    function api.BeginTabItem()
        return true
    end

    function api.BeginTable()
        return true
    end

    function api.IsItemHovered()
        return false
    end

    function api.PushID(_, id)
        assert(type(id) == "string", "PushID expects a string id")
        table.insert(fake.ids, id)
    end

    function api.PopID()
        assert(#fake.ids > 0, "PopID without PushID")
        table.remove(fake.ids)
    end

    function api.Button(_, label)
        return Clicked(label)
    end

    function api.SmallButton(_, label)
        return Clicked(label)
    end

    function api.Combo(_, label, current, items)
        assert(math.type(current) == "integer", "Combo expects an integer index for " .. label)
        assert(type(items) == "string" and items:sub(-1) == "\0", "Combo items must end with \\0")
        return Widget(label, current)
    end

    function api.InputInt(_, label, value)
        assert(math.type(value) == "integer", "InputInt expects an integer for " .. label)
        return Widget(label, value)
    end

    function api.InputDouble(_, label, value)
        assert(type(value) == "number", "InputDouble expects a number for " .. label)
        return Widget(label, value)
    end

    function api.InputText(_, label, value)
        assert(type(value) == "string", "InputText expects a string")
        return Widget(label, value)
    end

    function api.SliderInt(_, label, value, min, max)
        assert(math.type(value) == "integer" and math.type(min) == "integer" and math.type(max) == "integer",
            "SliderInt expects integers for " .. label)
        return Widget(label, value)
    end

    function api.SliderDouble(_, label, value, min, max)
        assert(type(value) == "number" and type(min) == "number" and type(max) == "number",
            "SliderDouble expects numbers for " .. label)
        return Widget(label, value)
    end

    function api.RadioButtonEx(_, label, value, button)
        assert(math.type(value) == "integer" and math.type(button) == "integer",
            "RadioButtonEx expects integers for " .. label)
        if Scripted(label) then
            return true, button
        end
        return false, value
    end

    api.Text = Text
    api.TextDisabled = Text
    api.TextWrapped = Text
    api.SeparatorText = Text

    function api.TextColored(_, color, text)
        assert(math.type(color) == "integer", "TextColored expects an RGBA integer")
        Text(nil, text)
    end

    api.Cond_FirstUseEver = 1 << 0
    api.TableFlags_Borders = 1 << 1
    api.TableFlags_RowBg = 1 << 2
    api.TableColumnFlags_WidthFixed = 1 << 3
    api.TableColumnFlags_WidthStretch = 1 << 4

    setmetatable(api, {
        __index = function(_, name)
            error("FakeImGui: ImGui." .. tostring(name) .. " is not available", 2)
        end
    })

    fake.api = api

    function fake:Click(id)
        self.clicks[id] = true
    end

    function fake:Set(id, value)
        self.values[id] = value
    end

    function fake:Close()
        self.closing = true
    end

    function fake:HasText(fragment)
        for _, text in ipairs(self.texts) do
            if text:find(fragment, 1, true) then
                return true
            end
        end
        return false
    end

    return fake

end

return FakeImGui
