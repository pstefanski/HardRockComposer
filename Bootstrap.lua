-- Shared setup of the REAPER entry scripts (Main.lua, ExportPresets.lua).
--
--     local root = ({reaper.get_action_context()})[2]:match("^(.*[\\/])")
--     dofile(root .. "Bootstrap.lua")(root)

return function(root)

    -- Lua uses the platform separator as the first character of package.config.
    local separator = package.config:sub(1, 1)

    package.path = table.concat({
        root .. "?.lua",
        root .. "Core" .. separator .. "?.lua",
        root .. "Data" .. separator .. "?.lua",
        package.path
    }, ";")

    require("PresetStore").SetDirectory(root .. "Presets" .. separator)

end
