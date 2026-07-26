local Logger = {}

local function printMessage(level, message)
    reaper.ShowConsoleMsg(string.format("[%s] %s\n", level, message))
end

function Logger.Info(message)
    printMessage("INFO", message)
end

function Logger.Warning(message)
    printMessage("WARNING", message)
end

function Logger.Error(message)
    printMessage("ERROR", message)
end

return Logger