local MidiNotes = require("Patterns.MidiNotes")

local Drums = {

    {
        id = "verse_basic",

        name = "Verse Basic",

        type = "drums",

        resolution = 16,

        bars = 1,

        notes = {

            {
                pitch = MidiNotes.drums.kick,
                position = 0,
                length = 0.25,
                velocity = 115
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 0,
                length = 0.25,
                velocity = 85
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 1,
                length = 0.25,
                velocity = 75
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 2,
                length = 0.25,
                velocity = 85
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 3,
                length = 0.25,
                velocity = 75
            },

            {
                pitch = MidiNotes.drums.snare,
                position = 4,
                length = 0.25,
                velocity = 110
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 4,
                length = 0.25,
                velocity = 85
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 5,
                length = 0.25,
                velocity = 75
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 6,
                length = 0.25,
                velocity = 85
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 7,
                length = 0.25,
                velocity = 75
            },

            {
                pitch = MidiNotes.drums.kick,
                position = 8,
                length = 0.25,
                velocity = 115
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 8,
                length = 0.25,
                velocity = 85
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 9,
                length = 0.25,
                velocity = 75
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 10,
                length = 0.25,
                velocity = 85
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 11,
                length = 0.25,
                velocity = 75
            },


            {
                pitch = MidiNotes.drums.snare,
                position = 12,
                length = 0.25,
                velocity = 110
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 12,
                length = 0.25,
                velocity = 85
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 13,
                length = 0.25,
                velocity = 75
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 14,
                length = 0.25,
                velocity = 85
            },

            {
                pitch = MidiNotes.drums.closed_hat,
                position = 15,
                length = 0.25,
                velocity = 75
            }

        }

    },

    {
        id = "chorus_open",

        name = "Chorus Open",

        type = "drums",

        resolution = 16,

        bars = 1,

        notes = {

            {
                pitch = MidiNotes.drums.kick,
                position = 0,
                length = 0.25,
                velocity = 120
            },

            {
                pitch = MidiNotes.drums.crash,
                position = 0,
                length = 1,
                velocity = 120
            },

            {
                pitch = MidiNotes.drums.snare,
                position = 4,
                length = 0.25,
                velocity = 120
            },

            {
                pitch = MidiNotes.drums.kick,
                position = 8,
                length = 0.25,
                velocity = 120
            },

            {
                pitch = MidiNotes.drums.snare,
                position = 12,
                length = 0.25,
                velocity = 120
            }

        }

    },

    {
        id = "fill_basic",

        name = "Basic Fill",

        type = "drums",

        resolution = 16,

        bars = 1,

        notes = {

            {
                pitch = MidiNotes.drums.high_tom,
                position = 12,
                length = 0.25,
                velocity = 100
            },

            {
                pitch = MidiNotes.drums.mid_tom,
                position = 13,
                length = 0.25,
                velocity = 105
            },

            {
                pitch = MidiNotes.drums.low_tom,
                position = 14,
                length = 0.25,
                velocity = 110
            },

            {
                pitch = MidiNotes.drums.crash,
                position = 15,
                length = 0.25,
                velocity = 120
            }

        }

    }

}

return Drums