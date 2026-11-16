local Random = require("Random")

--------------------------------------------------
-- Lays the song sections out bar by bar.
--
-- A section with `chance` (0..1) is optional: it is kept or dropped by a
-- generator seeded with `settings.structure_seed`, so the same seed always
-- gives the same song. Change the seed to get another variant.
--
-- With `settings.count_in = { bars = n }`, the song starts after n bars of
-- count-in (see Arrangement).
--------------------------------------------------

local Song = {}

function Song.Apply(structure, context, settings)

    local generator = Random.New(Random.Mix((settings and settings.structure_seed) or 1))

    local currentBar = 1

    local countIn = settings and settings.count_in

    if countIn then

        context.countIn = {
            bars = countIn.bars
        }

        currentBar = currentBar + countIn.bars

    end

    for _, section in ipairs(structure) do

        local included = true

        if section.chance ~= nil then

            included = generator:Float() < section.chance

        end

        if included then

            local songEntry = {

                id = section.id,

                name = section.name,

                startBar = currentBar,

                endBar = currentBar + section.bars - 1,

                bars = section.bars,

                patterns = section.patterns,

                fill = section.fill,

                color = section.color,

                energy = section.energy,

                chords = section.chords,

                chord_bars = section.chord_bars,

                transition = section.transition

            }

            table.insert(context.song, songEntry)

            context.registry.song[section.id] = songEntry

            currentBar = currentBar + section.bars

        end

    end

end

return Song
