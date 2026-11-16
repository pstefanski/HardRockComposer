local root = ({reaper.get_action_context()})[2]:match("^(.*[\\/])")

dofile(root .. "Bootstrap.lua")(root)

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
