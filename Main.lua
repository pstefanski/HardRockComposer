local root = ({reaper.get_action_context()})[2]
root = root:match("^(.*[\\/])")

package.path =
      root .. "?.lua;"
   .. root .. "Core\\?.lua;"
   .. root .. "Data\\?.lua;"
   .. package.path

local Version = require("Version")
local Config = require("Config")

local Logger = require("Logger")
local Reaper = require("Reaper")
local Builder = require("Builder")

local TrackLayout = require("TrackLayout")

reaper.ClearConsole()

Logger.Info(Version.NAME)
Logger.Info(Version.VERSION)

reaper.Undo_BeginBlock()

Reaper.ResetProject()

reaper.SetCurrentBPM(
    0,
    Config.Project.Tempo,
    true
)

local context = Builder.Build(TrackLayout)
local eq = context.registry.plugins.eq

reaper.ShowConsoleMsg(

    eq.data.plugin

)

for _, section in ipairs(context.song) do

    reaper.ShowConsoleMsg(

        section.name ..
        " : " ..
        section.startBar ..
        "-" ..
        section.endBar ..
        "\n"

    )

end

reaper.ShowConsoleMsg("\n=== PATTERNS ===\n")

for id, pattern in pairs(context.registry.patterns) do

    reaper.ShowConsoleMsg(
        id ..
        " -> " ..
        pattern.name ..
        "\n"
    )

end

reaper.ShowConsoleMsg("\n=== SONG PATTERNS ===\n")

for _, section in ipairs(context.song) do

    if section.patterns then

        for instrument, patternId in pairs(section.patterns) do

            reaper.ShowConsoleMsg(
                section.name ..
                " / " ..
                instrument ..
                " -> " ..
                patternId ..
                "\n"
            )

        end

    end

end


reaper.Undo_EndBlock(
    "HardRock Composer",
    -1
)

Logger.Info("Done.")