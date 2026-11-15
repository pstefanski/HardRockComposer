local root = ({reaper.get_action_context()})[2]
root = root:match("^(.*[\\/])")

-- Lua uses the platform separator as the first character of package.config.
local separator = package.config:sub(1, 1)

package.path = table.concat({
    root .. "?.lua",
    root .. "Core" .. separator .. "?.lua",
    root .. "Data" .. separator .. "?.lua",
    package.path
}, ";")

local Version = require("Version")

local Logger = require("Logger")
local Reaper = require("Reaper")
local Builder = require("Builder")

local TrackLayout = require("TrackLayout")

Reaper.ClearConsole()

Logger.Info(Version.NAME)
Logger.Info(Version.VERSION)

Reaper.BeginUndo()

local ok, result = pcall(Builder.Build, TrackLayout)

Reaper.EndUndo("HardRock Composer")

if not ok then
    Logger.Error(tostring(result))
    return
end

Logger.Info("Done.")
