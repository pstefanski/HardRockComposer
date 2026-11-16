# Presets

Plugin states of the `HRC …` presets, one file per preset, written by
`ExportPresets.lua`. Do not edit them by hand.

When REAPER does not know an HRC preset (for example on a machine where it
was never saved), the generation applies the state stored here instead,
provided the same plugin is loaded in the same format (VST3 state on a VST3
plugin).

## Updating the presets

1. On the machine where the HRC presets exist, run the
   `ExportPresets.lua` action in REAPER. It regenerates the current project.
2. Commit and push the `Presets/` folder.
