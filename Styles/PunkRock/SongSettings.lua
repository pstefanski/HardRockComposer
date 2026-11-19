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

    -- Draws the generated drum grooves (Drums.grooves): change it to
    -- hear other grooves.
    drum_seed = 1,

    humanization = {

        enabled = true,

        seed = 123,

        velocity = 10,

        timing = 6,

        -- Average placement of each part of the kit, in ticks
        -- (960 per quarter note): pushing ahead of the beat.
        feel = { kick = -2, snare = -2, hats = -6, toms = 0, cymbals = -2 }

    }

}

return SongSettings
