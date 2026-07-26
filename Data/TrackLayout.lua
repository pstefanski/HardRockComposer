local Layout = {

    {
        folder = "DRUMS",

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
                role = "overhead",
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

    {
        folder = "BASS",

        tracks = {

            {
                name = "DI",
                type = "audio",
                role = "clean",
                color = "bass"
            },

            {
                name = "Amp",
                type = "audio",
                role = "amped",
                color = "bass"
            },

            {
                name = "Bass Bus",
                type = "bus",
                role = "master",
                color = "bass"
            }

        }

    }

}

return Layout