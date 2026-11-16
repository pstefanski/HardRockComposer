-- HardRock Composer — export the HRC presets into the repository.
--
-- Run this action on the machine where the HRC presets exist (Windows).
-- It generates the project, which loads every HRC preset, then saves the
-- state of each plugin into Presets/. Commit and push that folder: the
-- other machines apply these states when REAPER does not know the preset.

local root = ({reaper.get_action_context()})[2]:match("^(.*[\\/])")

dofile(root .. "Bootstrap.lua")(root)

local Config = require("Config")
local Logger = require("Logger")
local Reaper = require("Reaper")
local Builder = require("Builder")
local StyleLoader = require("StyleLoader")
local PresetExport = require("PresetExport")
local PresetStore = require("PresetStore")

local TITLE = "HardRock Composer — Export presets"

Reaper.ClearConsole()

local answer = Reaper.ShowMessageBox("This regenerates the current project (all tracks are deleted), " ..
                                         "then saves the HRC presets into:\n\n" .. PresetStore.Directory() ..
                                         "\n\nContinue?", TITLE, 4)

if answer ~= 6 then
    return
end

local loaded, style = pcall(StyleLoader.Load, Config.Style)

if not loaded then
    Logger.Error(tostring(style))
    return
end

Reaper.BeginUndo()

local ok, context = pcall(Builder.Build, style)

Reaper.EndUndo("HardRock Composer: export presets")

if not ok then
    Logger.Error(tostring(context))
    return
end

local exported, skipped = 0, 0

for _, result in ipairs(PresetExport.Export(context)) do

    if result.file then

        exported = exported + 1
        Logger.Info("Exported  " .. result.preset)

    else

        skipped = skipped + 1
        Logger.Warning("Skipped   " .. result.preset .. ": " .. tostring(result.reason))

    end

end

Logger.Info(string.format("%d preset(s) exported, %d skipped.", exported, skipped))

Reaper.ShowMessageBox(string.format("%d preset(s) exported, %d skipped (see the console).\n\n" ..
                                        "Commit and push the Presets folder.", exported, skipped), TITLE, 0)
