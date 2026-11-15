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
local Config = require("Config")

local Logger = require("Logger")
local Reaper = require("Reaper")
local Builder = require("Builder")
local Plugins = require("Plugins")

local StyleLoader = require("StyleLoader")

Reaper.ClearConsole()

Logger.Info(Version.NAME)
Logger.Info(Version.VERSION)

local loaded, style = pcall(StyleLoader.Load, Config.Style)

if not loaded then
    Logger.Error(tostring(style))
    return
end

Logger.Info("Style: " .. style.name)

Reaper.BeginUndo()

local ok, result = pcall(Builder.Build, style)

Reaper.EndUndo("HardRock Composer")

if not ok then
    Logger.Error(tostring(result))
    return
end

Plugins.LogSummary(result)

Logger.Info("Done.")
