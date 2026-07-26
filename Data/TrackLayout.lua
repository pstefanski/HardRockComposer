local Layout = {

    ------------------------------------------------------------------
    -- DRUMS
    ------------------------------------------------------------------

    {
        name = "DRUMS",
        color = "drums",

        tracks = {

            {
                name = "EZD MIDI",
                type = "midi",
                role = "instrument",
                color = "drums"
            },

            {
                name = "Kick",
                type = "audio",
                role = "closemic",
                color = "drums"
            },

            {
                name = "Snare",
                type = "audio",
                role = "closemic",
                color = "drums"
            },

            {
                name = "HiHat",
                type = "audio",
                role = "closemic",
                color = "drums"
            },

            {
                name = "Tom 1",
                type = "audio",
                role = "tom",
                color = "drums"
            },

            {
                name = "Tom 2",
                type = "audio",
                role = "tom",
                color = "drums"
            },

            {
                name = "Floor Tom",
                type = "audio",
                role = "tom",
                color = "drums"
            },

            {
                name = "Overheads",
                type = "audio",
                role = "overheads",
                color = "drums"
            },

            {
                name = "Room",
                type = "audio",
                role = "room",
                color = "drums"
            },

            {
                name = "Parallel",
                type = "bus",
                role = "parallel",
                color = "drums"
            },

            {
                name = "Drum Bus",
                type = "bus",
                role = "master",
                color = "drums"
            }

        }

    },

    ------------------------------------------------------------------
    -- BASS
    ------------------------------------------------------------------

    {
        name = "BASS",
        color = "bass",

        tracks = {

            {
                name = "DI",
                type = "audio",
                role = "di",
                color = "bass"
            },

            {
                name = "Amp",
                type = "audio",
                role = "amp",
                color = "bass"
            },

            {
                name = "Bass Bus",
                type = "bus",
                role = "master",
                color = "bass"
            }

        }

    },

    ------------------------------------------------------------------
    -- GUITARS
    ------------------------------------------------------------------

    {
        name = "GUITARS",
        color = "guitars",

        tracks = {

            {
                name = "Rhythm L",
                type = "audio",
                role = "rhythm",
                color = "guitars"
            },

            {
                name = "Rhythm R",
                type = "audio",
                role = "rhythm",
                color = "guitars"
            },

            {
                name = "Lead",
                type = "audio",
                role = "lead",
                color = "guitars"
            },

            {
                name = "Solo",
                type = "audio",
                role = "solo",
                color = "guitars"
            },

            {
                name = "Guitar Bus",
                type = "bus",
                role = "master",
                color = "guitars"
            }

        }

    },

    ------------------------------------------------------------------
    -- VOCALS
    ------------------------------------------------------------------

    {
        name = "VOCALS",
        color = "vocals",

        tracks = {

            {
                name = "Lead",
                type = "audio",
                role = "lead",
                color = "vocals"
            },

            {
                name = "Backing",
                type = "audio",
                role = "backing",
                color = "vocals"
            },

            {
                name = "Vocal Bus",
                type = "bus",
                role = "master",
                color = "vocals"
            }

        }

    },

    ------------------------------------------------------------------
    -- FX
    ------------------------------------------------------------------

    {
        name = "FX",
        color = "fx",

        tracks = {

            {
                name = "Plate",
                type = "fx",
                role = "reverb",
                color = "fx"
            },

            {
                name = "Room",
                type = "fx",
                role = "reverb",
                color = "fx"
            },

            {
                name = "Hall",
                type = "fx",
                role = "reverb",
                color = "fx"
            },

            {
                name = "Delay",
                type = "fx",
                role = "delay",
                color = "fx"
            }

        }

    }

}

return Layout