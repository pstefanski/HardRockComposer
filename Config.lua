-- Engine options.
--
-- Musical settings (tempo, time signature, swing, humanization) live in
-- the style: Styles/<Style>/SongSettings.lua.

local Config = {}

-- Style to generate: a folder name listed in Styles/Index.lua.
Config.Style = "HardRock"

-- Delete every existing track before generating the project.
Config.ResetProject = true

return Config
