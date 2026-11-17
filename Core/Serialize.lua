--------------------------------------------------
-- Turns plain data (tables of strings, numbers and booleans) into a Lua
-- literal and back. Used to keep the user's choices in REAPER's ExtState.
--
-- Reading evaluates the text without access to any library: it can only
-- produce data.
--------------------------------------------------

local Serialize = {}

local function IsIdentifier(key)

    return type(key) == "string" and key:match("^[%a_][%w_]*$") ~= nil

end

local function Encode(value, out)

    local kind = type(value)

    if kind == "string" then

        table.insert(out, string.format("%q", value))

    elseif kind == "number" then

        if math.type(value) == "integer" then
            table.insert(out, string.format("%d", value))
        else
            table.insert(out, string.format("%.17g", value))
        end

    elseif kind == "boolean" then

        table.insert(out, tostring(value))

    elseif kind == "table" then

        table.insert(out, "{")

        -- Array part first, then the other keys in a stable order.
        local count = #value

        for index = 1, count do
            Encode(value[index], out)
            table.insert(out, ",")
        end

        local keys = {}

        for key in pairs(value) do
            if not (math.type(key) == "integer" and key >= 1 and key <= count) then
                table.insert(keys, key)
            end
        end

        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)

        for _, key in ipairs(keys) do

            if IsIdentifier(key) then
                table.insert(out, key)
            else
                table.insert(out, "[")
                Encode(key, out)
                table.insert(out, "]")
            end

            table.insert(out, "=")
            Encode(value[key], out)
            table.insert(out, ",")

        end

        table.insert(out, "}")

    else

        error("Cannot serialize a " .. kind)

    end

end

function Serialize.Encode(value)

    local out = {}

    Encode(value, out)

    return table.concat(out)

end

-- Returns the decoded value, or nil when the text is not valid data.
function Serialize.Decode(text)

    if type(text) ~= "string" or text == "" then
        return nil
    end

    local chunk = load("return " .. text, "data", "t", {})

    if not chunk then
        return nil
    end

    local ok, value = pcall(chunk)

    if not ok then
        return nil
    end

    return value

end

return Serialize
