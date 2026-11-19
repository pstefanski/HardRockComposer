local SongSettings = {

    -- Key the chords are written in (the window can transpose them).
    key = "A",

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

    -- Generated bass line: root on every kick drum hit.
    bass = {

        mode = "kick",

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

        velocity = 8,

        timing = 8,

        -- Average placement of each part of the kit, in ticks
        -- (960 per quarter note): relaxed backbeat.
        feel = { kick = 0, snare = 10, hats = -2, toms = 6, cymbals = 0 }

    }

}

return SongSettings
