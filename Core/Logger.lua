local Reaper = require("Reaper")

local Logger = {}

function Logger.Info(message)
    Reaper.ShowConsoleMsg("[INFO] " .. message .. "\n")
end

function Logger.Warning(message)
    Reaper.ShowConsoleMsg("[WARNING] " .. message .. "\n")
end

function Logger.Error(message)
    Reaper.ShowConsoleMsg("[ERROR] " .. message .. "\n")
end

return Logger
