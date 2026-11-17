local Reaper = require("Reaper")
local Logger = require("Logger")
local Builder = require("Builder")
local Plugins = require("Plugins")
local Session = require("Session")

--------------------------------------------------
-- Generates a project from a style and the user's choices (Session).
-- Shared by the window and the direct generation (no ReaImGui).
--------------------------------------------------

local Generator = {}

-- Returns true and the build context, or false and an error message.
function Generator.Run(style, options)

    local configured = Session.Apply(style, options)

    if options.target == "new_tab" then
        Reaper.NewProjectTab()
    end

    Logger.Info("Style: " .. style.name)

    Reaper.BeginUndo()

    local ok, result = pcall(Builder.Build, configured)

    Reaper.EndUndo("HardRock Composer: " .. style.name)

    if not ok then
        Logger.Error(tostring(result))
        return false, tostring(result)
    end

    Plugins.LogSummary(result)

    Logger.Info("Done.")

    return true, result

end

return Generator
