local Test = require("Test")
local StyleLoader = require("StyleLoader")

local Style = StyleLoader.Load("HardRock")
local TrackLayout = Style.layout
local SongStructure = Style.structure
local SongSettings = Style.settings
local DrumPatterns = Style.patternSets[1]
local Song = require("Song")

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

local function SectionIds(structure, seed)
    local context = {song = {}, registry = {song = {}}}
    Song.Apply(structure, context, {structure_seed = seed})
    local ids = {}
    for _, section in ipairs(context.song) do
        table.insert(ids, section.id)
    end
    return table.concat(ids, ",")
end

local OPTIONAL = {
    {id = "a", name = "A", bars = 4},
    {id = "b", name = "B", bars = 4, chance = 0.5},
    {id = "c", name = "C", bars = 4, chance = 0.5},
    {id = "d", name = "D", bars = 4, chance = 0},
    {id = "e", name = "E", bars = 4, chance = 1}
}

Test.Case("Song: optional sections depend on the seed only", function()
    Test.Equal(SectionIds(OPTIONAL, 7), SectionIds(OPTIONAL, 7))
    local variants = {}
    for seed = 1, 20 do
        variants[SectionIds(OPTIONAL, seed)] = true
    end
    local count = 0
    for _ in pairs(variants) do
        count = count + 1
    end
    Test.True(count > 1, "different seeds should give different songs")
end)

Test.Case("Song: chance 0 drops a section and chance 1 keeps it", function()
    for seed = 1, 20 do
        local ids = SectionIds(OPTIONAL, seed)
        Test.True(not ids:find("d", 1, true), ids)
        Test.True(ids:sub(1, 1) == "a" and ids:sub(-1) == "e", ids)
    end
end)
