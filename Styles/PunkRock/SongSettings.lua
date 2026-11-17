local SongSettings = {

    -- Key the chords are written in (the window can transpose them).
    key = "G",

    tempo = 190,

    beats_per_bar = 4,

    beat_unit = 4,

    -- Picks the optional sections (bridge, extra final chorus).
    structure_seed = 1,

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

        velocity = 10,

        timing = 6

    }

}

return SongSettings
