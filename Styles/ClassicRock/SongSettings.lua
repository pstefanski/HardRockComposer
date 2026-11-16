local SongSettings = {

    tempo = 120,

    beats_per_bar = 4,

    beat_unit = 4,

    -- Light eighth-note shuffle.
    swing = {

        amount = 0.3,

        subdivision = 8

    },

    -- Picks the optional sections (bridge, extra final chorus).
    structure_seed = 1,

    humanization = {

        enabled = true,

        seed = 123,

        velocity = 8,

        timing = 8

    }

}

return SongSettings
