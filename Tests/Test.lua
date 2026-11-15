--------------------------------------------------
-- Minimal test framework (no external dependency).
--------------------------------------------------

local Test = {
    cases = {}
}

function Test.Case(name, fn)

    table.insert(Test.cases, {
        name = name,
        fn = fn
    })

end

local function Fail(message, level)

    error(message, (level or 1) + 2)

end

local function Format(value)

    if type(value) == "string" then
        return string.format("%q", value)
    end

    return tostring(value)

end

function Test.Equal(actual, expected, label)

    if actual ~= expected then
        Fail((label and label .. ": " or "") .. "expected " .. Format(expected) .. ", got " .. Format(actual))
    end

end

function Test.Near(actual, expected, tolerance, label)

    if type(actual) ~= "number" or math.abs(actual - expected) > (tolerance or 1e-9) then
        Fail((label and label .. ": " or "") .. "expected ~" .. Format(expected) .. ", got " .. Format(actual))
    end

end

function Test.True(value, label)

    if not value then
        Fail(label or "expected a truthy value")
    end

end

-- Asserts that fn raises an error whose message contains `fragment`.
function Test.Raises(fn, fragment)

    local ok, err = pcall(fn)

    if ok then
        Fail("expected an error containing " .. Format(fragment))
    end

    if fragment and not tostring(err):find(fragment, 1, true) then
        Fail("expected an error containing " .. Format(fragment) .. ", got " .. Format(err))
    end

end

-- Asserts that a list of messages has one containing `fragment`.
function Test.Contains(messages, fragment)

    for _, message in ipairs(messages) do

        if message:find(fragment, 1, true) then
            return
        end

    end

    Fail("no message contains " .. Format(fragment) .. " in:\n    " .. table.concat(messages, "\n    "))

end

function Test.DeepCopy(value)

    if type(value) ~= "table" then
        return value
    end

    local copy = {}

    for key, item in pairs(value) do
        copy[key] = Test.DeepCopy(item)
    end

    return copy

end

function Test.Run()

    local failures = 0

    for _, case in ipairs(Test.cases) do

        local ok, err = xpcall(case.fn, debug.traceback)

        if ok then

            print("  ok    " .. case.name)

        else

            failures = failures + 1

            print("  FAIL  " .. case.name .. "\n        " .. tostring(err):gsub("\n", "\n        "))

        end

    end

    print(string.format("\n%d test(s), %d failure(s)", #Test.cases, failures))

    return failures == 0

end

return Test
