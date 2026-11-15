local SongSettings = {

    -- REAPER tempo is counted in quarter notes: 105 BPM = 70 dotted quarters
    -- per minute, the pulse of the 12/8 shuffle.
    tempo = 105,

    -- 12/8: four dotted-quarter beats, each split in three eighth notes.
    -- The triplet feel is written in the patterns, no swing needed.
    beats_per_bar = 12,

    beat_unit = 8,

    -- Picks the optional section (stop-time breakdown).
    structure_seed = 1,

    humanization = {

        enabled = true,

        seed = 123,

        velocity = 8,

        timing = 10

    }

}

return SongSettings
