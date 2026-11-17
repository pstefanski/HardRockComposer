local Logger = require("Logger")
local Reaper = require("Reaper")
local Window = require("UI.Window")

--------------------------------------------------
-- Opens the HardRock Composer window (requires ReaImGui).
--------------------------------------------------

local App = {}

-- ReaImGui API version the window is written for.
App.IMGUI_VERSION = "0.10"

function App.IsAvailable()

    return reaper.ImGui_GetBuiltinPath ~= nil

end

function App.Run()

    package.path = reaper.ImGui_GetBuiltinPath() .. "/?.lua;" .. package.path

    local ImGui = require("imgui")(App.IMGUI_VERSION)
    local ctx = ImGui.CreateContext("HardRock Composer")
    local window = Window.New()

    local function Loop()

        local ok, open = xpcall(window.Frame, debug.traceback, window, ImGui, ctx)

        if not ok then
            Logger.Error(tostring(open))
            return
        end

        if open then
            Reaper.Defer(Loop)
        end

    end

    Reaper.Defer(Loop)

end

return App
