-- Engine options.
--
-- Musical settings (tempo, time signature, humanization) live in
-- Data/SongSettings.lua, which is the single source of truth for the song.

local Config = {}

-- Delete every existing track before generating the project.
Config.ResetProject = true

return Config
