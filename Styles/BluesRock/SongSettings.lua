local SongSettings = {

    -- Key the chords are written in (the window can transpose them).
    key = "E",

    -- REAPER tempo is counted in quarter notes: 105 BPM = 70 dotted quarters
    -- per minute, the pulse of the 12/8 shuffle.
    tempo = 105,

    -- 12/8: four dotted-quarter beats, each split in three eighth notes.
    -- The triplet feel is written in the patterns, no swing needed.
    beats_per_bar = 12,

    beat_unit = 8,

    -- Picks the optional section (stop-time breakdown).
    structure_seed = 1,

    -- Generated bass line: shuffle root, fifth, sixth, fifth.
    bass = {

        mode = "boogie",

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

        timing = 10,

        -- Average placement of each part of the kit, in ticks
        -- (960 per quarter note): laid back.
        feel = { kick = 2, snare = 14, hats = 0, toms = 8, cymbals = 2 }

    }

}

return SongSettings
