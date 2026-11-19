local SongSettings = {

    -- Key the chords are written in (the window can transpose them).
    key = "D",

    tempo = 145,

    beats_per_bar = 4,

    beat_unit = 4,

    -- Picks the optional section (half-time breakdown).
    structure_seed = 1,

    -- Generated bass line: driving root eighth notes.
    bass = {

        mode = "eighths",

        velocity = 100,

        legato = 0.9

    },

    -- Uncomment to start with a count-in on the drum track.
    -- count_in = { bars = 1 },

    -- Draws the generated drum grooves (Drums.grooves): change it to
    -- hear other grooves.
    drum_seed = 1,

    humanization = {

        enabled = true,

        seed = 123,

        -- Tighter than the other styles: double kick needs precision.
        velocity = 6,

        timing = 5,

        -- Average placement of each part of the kit, in ticks
        -- (960 per quarter note): tight.
        feel = { kick = 0, snare = 4, hats = -2, toms = 2, cymbals = 0 }

    }

}

return SongSettings
