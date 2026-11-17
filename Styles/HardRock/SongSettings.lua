local SongSettings = {

    -- Key the chords are written in (the window can transpose them).
    key = "E",

    tempo = 140,

    beats_per_bar = 4,

    beat_unit = 4,

    -- Generated bass line: driving root eighth notes.
    bass = {

        mode = "eighths",

        velocity = 100,

        legato = 0.9

    },

    -- Uncomment to start with a count-in on the drum track.
    -- count_in = { bars = 1 },

    humanization = {

        enabled = true,

        seed = 123,

        velocity = 8,

        timing = 8

    }

}

return SongSettings
