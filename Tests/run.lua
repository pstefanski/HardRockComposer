-- Runs the test suite outside REAPER:
--
--     lua Tests/run.lua

local here = (arg and arg[0] or ""):match("^(.*[\\/])") or "./"
local root = here .. ".." .. package.config:sub(1, 1)
local separator = package.config:sub(1, 1)

package.path = table.concat({
    here .. "?.lua",
    root .. "?.lua",
    root .. "Core" .. separator .. "?.lua",
    root .. "Data" .. separator .. "?.lua",
    package.path
}, ";")

local MockReaper = require("MockReaper")

reaper = MockReaper.api

local Test = require("Test")

local suites = {
    "TimingTest",
    "HumanizerTest",
    "DynamicsTest",
    "TransitionsTest",
    "SongTest",
    "ValidatorTest",
    "BuildTest",
    "PluginsTest"
}

for _, suite in ipairs(suites) do
    require(suite)
end

os.exit(Test.Run() and 0 or 1)
