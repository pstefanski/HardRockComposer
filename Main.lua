local root = ({reaper.get_action_context()})[2]:match("^(.*[\\/])")

dofile(root .. "Bootstrap.lua")(root)

local Version = require("Version")
local Config = require("Config")
local Logger = require("Logger")
local Reaper = require("Reaper")
local StyleLoader = require("StyleLoader")
local Session = require("Session")
local Generator = require("Generator")
local App = require("UI.App")

Reaper.ClearConsole()

Logger.Info(Version.NAME)
Logger.Info(Version.VERSION)

-- With ReaImGui: open the window. Without it: generate directly with the
-- choices saved by the window, or the style defaults.
if App.IsAvailable() then

    App.Run()

    return

end

local styleId = Session.LastStyle()

if not StyleLoader.Exists(styleId) then
    styleId = Config.Style
end

local loaded, style = pcall(StyleLoader.Load, styleId)

if not loaded then
    Logger.Error(tostring(style))
    return
end

Generator.Run(style, Session.Load(style))
