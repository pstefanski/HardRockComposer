local Song = {}

function Song.Apply(structure, context)

    local currentBar = 1

    for _, section in ipairs(structure) do

        local songEntry = {

            id = section.id,

            name = section.name,

            startBar = currentBar,

            endBar = currentBar + section.bars - 1,

            bars = section.bars,
            
            patterns = section.patterns,

            fill = section.fill

        }

        table.insert(context.song, songEntry)

        context.registry.song[section.id] = songEntry

        currentBar = currentBar + section.bars

    end

end

return Song