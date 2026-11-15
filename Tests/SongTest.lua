local Test = require("Test")
local Song = require("Song")
local SongStructure = require("SongStructure")

Test.Case("Song: sections are laid out back to back", function()
    local context = {song = {}, registry = {song = {}}}

    Song.Apply(SongStructure, context)

    Test.Equal(#context.song, #SongStructure)
    Test.Equal(context.song[1].startBar, 1)

    for index = 2, #context.song do
        Test.Equal(context.song[index].startBar, context.song[index - 1].endBar + 1, "section " .. index)
    end

    for _, section in ipairs(context.song) do
        Test.Equal(context.registry.song[section.id], section)
        Test.Equal(section.endBar - section.startBar + 1, section.bars, section.id)
    end
end)
