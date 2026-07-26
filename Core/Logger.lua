local Logger = {}

function Logger.Info(message)
    reaper.ShowConsoleMsg("[INFO] " .. message .. "\n")
end

function Logger.Warning(message)
    reaper.ShowConsoleMsg("[WARNING] " .. message .. "\n")
end

function Logger.Error(message)
    reaper.ShowConsoleMsg("[ERROR] " .. message .. "\n")
end

return Logger