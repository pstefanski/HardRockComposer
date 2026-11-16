local SongSettings = {

    tempo = 145,

    beats_per_bar = 4,

    beat_unit = 4,

    -- Picks the optional section (half-time breakdown).
    structure_seed = 1,

    humanization = {

        enabled = true,

        seed = 123,

        -- Tighter than the other styles: double kick needs precision.
        velocity = 6,

        timing = 5

    }

}

return SongSettings
