local Layout = {

    ------------------------------------------------------------------
    -- DRUMS
    ------------------------------------------------------------------

    {
        id= "drums",
        name = "DRUMS",
        color = "drums",

        tracks = {

            {
                id = "ezd_midi",
                name = "EZD MIDI",
                type = "midi",
                role = "instrument",
                color = "drums"
            },

            {
                id = "kick",
                name = "Kick",
                type = "audio",
                role = "closemic",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },

                properties = {

                    volume = -6,

                    pan = -0.15,

                    mute = false,

                    solo = false

                }
            },

            {
                id = "snare",
                name = "Snare",
                type = "audio",
                role = "closemic",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },
            },

            {
                id = "hihat",
                name = "HiHat",
                type = "audio",
                role = "closemic",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },
            },

            {
                id = "tom_1",
                name = "Tom 1",
                type = "audio",
                role = "tom",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },
            },

            {
                id = "tom_2",
                name = "Tom 2",
                type = "audio",
                role = "tom",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },
            },

            {
                id = "floor_tom",
                name = "Floor Tom",
                type = "audio",
                role = "tom",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },
            },

            {
                id = "overheads",
                name = "Overheads",
                type = "audio",
                role = "overheads",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },
            },

            {
                id = "room",
                name = "Room",
                type = "audio",
                role = "room",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },
            },

            {
                id = "parallel",
                name = "Parallel",
                type = "bus",
                role = "parallel",
                color = "drums",
                routing = {
                    output = "drum_bus"
                },
            },

            {
                id = "drum_bus",
                name = "Drum Bus",
                type = "bus",
                role = "master",
                color = "drums",

                plugins = {

                    {
                        plugin = "VST: ReaEQ (Cockos)"
                    },

                    {
                        plugin = "VST: ReaComp (Cockos)"
                    }

                }
            }

        }

    },

    ------------------------------------------------------------------
    -- BASS
    ------------------------------------------------------------------

    {
        id = "bass",
        name = "BASS",
        color = "bass",

        tracks = {

            {
                id = "bass_di",
                name = "DI",
                type = "audio",
                role = "di",
                color = "bass",
                routing = {
                    output = "bass_bus"
                },
            },

            {
                id = "bass_amp",
                name = "Amp",
                type = "audio",
                role = "amp",
                color = "bass",
                routing = {
                    output = "bass_bus"
                },
            },

            {
                id = "bass_bus",
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
        id = "guitars", 
        name = "GUITARS",
        color = "guitars",

        tracks = {

            {
                id = "guitar_rythm_l",
                name = "Rhythm L",
                type = "audio",
                role = "rhythm",
                color = "guitars"
            },

            {
                id = "guitar_rythm_r",
                name = "Rhythm R",
                type = "audio",
                role = "rhythm",
                color = "guitars"
            },

            {
                id = "guitar_lead",
                name = "Lead",
                type = "audio",
                role = "lead",
                color = "guitars"
            },

            {
                id = "guitar_solo",
                name = "Solo",
                type = "audio",
                role = "solo",
                color = "guitars"
            },

            {
                id = "guitar_bus",
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
        id = "vocals",
        name = "VOCALS",
        color = "vocals",

        tracks = {

            {
                id = "vocal_lead",
                name = "Lead",
                type = "audio",
                role = "lead",
                color = "vocals"
            },

            {
                id = "vocal_backing",
                name = "Backing",
                type = "audio",
                role = "backing",
                color = "vocals"
            },

            {
                id = "vocal_bus",
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
        id = "fx",
        name = "FX",
        color = "fx",

        tracks = {

            {
                id = "fx_plate",
                name = "Plate",
                type = "fx",
                role = "reverb",
                color = "fx"
            },

            {
                id = "fx_room",
                name = "Room",
                type = "fx",
                role = "reverb",
                color = "fx"
            },

            {
                id = "fx_hall",
                name = "Hall",
                type = "fx",
                role = "reverb",
                color = "fx"
            },

            {
                id = "fx_delay",
                name = "Delay",
                type = "fx",
                role = "delay",
                color = "fx"
            }

        }

    }

}

return Layout