local Layout = { ------------------------------------------------------------------
-- DRUMS
------------------------------------------------------------------
{
    id = "drums",
    name = "DRUMS",
    color = "drums",

    tracks = {{
        id = "ezd_midi",
        name = "EZD MIDI",
        type = "midi",
        role = "instrument",
        color = "drums",

        plugins = {{
            id = "ezdrummer",
            plugin = "EZdrummer 3",
            outputChannels = 32,
            preset = "HRC Bright Room Drums",

            -- EZdrummer mixer routing, matching the selected 32-output setup.
            outputs = {{
                pair = 1,
                destination = "kick"
            }, {
                pair = 2,
                destination = "snare_top"
            }, {
                pair = 3,
                destination = "snare_bottom"
            }, {
                pair = 4,
                destination = "hihat"
            }, {
                pair = 5,
                destination = "toms"
            }, {
                pair = 6,
                destination = "cymbals"
            }, {
                pair = 7,
                destination = "room"
            }, {
                pair = 9,
                destination = "overheads"
            }, {
                pair = 10,
                destination = "parallel"
            }, {
                pair = 11,
                destination = "one_shot"
            }, {
                pair = 12,
                destination = "shaker"
            }, {
                pair = 13,
                destination = "tambourine"
            }, {
                pair = 14,
                destination = "percussion_oh"
            }}
        }}
    }, {
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

            mute = false,

            solo = false

        }
    }, {
        id = "snare_top",
        name = "Snare Top",
        type = "audio",
        role = "closemic",
        color = "drums",
        routing = {
            output = "drum_bus",
            sends = {{
                destination = "fx_plate",
                volume = -18
            }}
        }
    }, {
        id = "snare_bottom",
        name = "Snare Bottom",
        type = "audio",
        role = "closemic",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "hihat",
        name = "HiHat",
        type = "audio",
        role = "closemic",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "toms",
        name = "Toms",
        type = "audio",
        role = "tom",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "cymbals",
        name = "Ride / Overheads",
        type = "audio",
        role = "overheads",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "room",
        name = "Ambience",
        type = "audio",
        role = "room",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "overheads",
        name = "Overheads Mono",
        type = "audio",
        role = "overheads",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "parallel",
        name = "Crunch / Parallel",
        type = "bus",
        role = "parallel",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "one_shot",
        name = "One Shot",
        type = "audio",
        role = "percussion",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "shaker",
        name = "Shaker",
        type = "audio",
        role = "percussion",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "tambourine",
        name = "Tambourine",
        type = "audio",
        role = "percussion",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "percussion_oh",
        name = "Percussion OH",
        type = "audio",
        role = "percussion",
        color = "drums",
        routing = {
            output = "drum_bus"
        }
    }, {
        id = "drum_bus",
        name = "Drum Bus",
        type = "bus",
        role = "master",
        color = "drums",

        plugins = {{

            id = "eq",

            plugin = "VST: ReaEQ (Cockos)",

            preset = "HRC Drum Bus EQ"

        }, {
            id = "drum_bus_studer",
            plugin = "VST3: UADx Studer A800 Tape Recorder",
            preset = "HRC Drum Bus Studer"
        }, {
            id = "drum_bus_api_2500",
            plugin = "VST3: UADx API 2500 Bus Compressor",
            preset = "HRC Drum Bus API 2500"

        }},

        routing = {
            output = "master_bus"
        }
    }}

}, ------------------------------------------------------------------
-- BASS
------------------------------------------------------------------
{
    id = "bass",
    name = "BASS",
    color = "bass",

    tracks = {{
        id = "bass_di",
        name = "DI",
        type = "audio",
        role = "di",
        color = "bass",

        routing = {
            outputs = {{
                destination = "bass_amp",
                mode = "pre_fx"
            }, {
                destination = "bass_distortion",
                mode = "pre_fx"
            }, {
                destination = "bass_bus"
            }}
        },
        properties = {

            volume = -7.46,

            mute = false,

            solo = false

        }
    }, {
        id = "bass_amp",
        name = "Amp",
        type = "audio",
        role = "amp",
        color = "bass",

        plugins = {{
            id = "tonex_bass",
            plugin = "TONEX",
            preset = "HRC Bass Ampeg"
        }},

        routing = {
            output = "bass_bus"
        },
        properties = {

            volume = -11.1,

            mute = false,

            solo = false

        }
    }, {
        id = "bass_distortion",
        name = "Distortion",
        type = "audio",
        role = "distortion",
        color = "bass",

        plugins = {{
            id = "tonex_bass_distortion",
            plugin = "TONEX",
            preset = "HRC Bass Distortion"
        }, {
            id = "bass_distortion_eq",
            plugin = "ReaEQ",
            preset = "HRC Bass Distortion EQ"
        }},

        routing = {
            output = "bass_bus"
        },

        properties = {

            volume = -22.2,

            mute = false,

            solo = false

        }
    }, {
        id = "bass_bus",
        name = "Bass Bus",
        type = "bus",
        role = "master",
        color = "bass",

        plugins = {{
            id = "bass_bus_eq",
            plugin = "VST: ReaEQ (Cockos)",
            preset = "HRC Bass Bus EQ"
        }, {
            id = "bass_bus_1176",
            plugin = "VST3: UADx 1176 Rev A Compressor",
            preset = "HRC Bass Bus 1176"
        }},

        routing = {
            output = "master_bus"
        }
    }}

}, ------------------------------------------------------------------
-- GUITARS
------------------------------------------------------------------
{
    id = "guitars",
    name = "GUITARS",
    color = "guitars",

    tracks = {{
        id = "guitar_rythm_l",
        name = "Rhythm L",
        type = "audio",
        role = "rhythm",
        color = "guitars",

        plugins = {{
            id = "tonex_guitar_rythm_l",
            plugin = "TONEX",
            preset = "HRC Rhythm L JCM800"
        }},

        routing = {
            output = "guitar_bus",
            sends = {{
                destination = "fx_room",
                volume = -24
            }}
        },

        properties = {
            pan = -0.65
        }
    }, {
        id = "guitar_rythm_r",
        name = "Rhythm R",
        type = "audio",
        role = "rhythm",
        color = "guitars",

        plugins = {{
            id = "tonex_guitar_rythm_r",
            plugin = "TONEX",
            preset = "HRC Rhythm R JCM800"
        }},

        routing = {
            output = "guitar_bus",
            sends = {{
                destination = "fx_room",
                volume = -24
            }}
        },

        properties = {
            pan = 0.65
        }
    }, {
        id = "guitar_lead",
        name = "Lead",
        type = "audio",
        role = "lead",
        color = "guitars",

        plugins = {{
            id = "tonex_guitar_lead",
            plugin = "TONEX",
            preset = "HRC Lead JCM900"
        }},

        routing = {
            output = "guitar_bus",
            sends = {{
                destination = "fx_plate",
                volume = -20
            }, {
                destination = "fx_delay",
                volume = -16
            }}
        }
    }, {
        id = "guitar_solo",
        name = "Solo",
        type = "audio",
        role = "solo",
        color = "guitars",

        plugins = {{
            id = "tonex_guitar_solo",
            plugin = "TONEX",
            preset = "HRC Solo Plexi"
        }},

        routing = {
            output = "guitar_bus",
            sends = {{
                destination = "fx_hall",
                volume = -18
            }, {
                destination = "fx_delay",
                volume = -14
            }}
        }
    }, {
        id = "guitar_bus",
        name = "Guitar Bus",
        type = "bus",
        role = "master",
        color = "guitars",

        plugins = {{
            id = "guitar_bus_eq",
            plugin = "VST: ReaEQ (Cockos)",
            preset = "HRC Guitar Bus EQ"
        }, {
            id = "guitar_bus_studer",
            plugin = "VST3: UADx Studer A800 Tape Recorder",
            preset = "HRC Guitar Bus Studer"
        }},

        routing = {
            output = "master_bus"
        }
    }}

}, ------------------------------------------------------------------
-- VOCALS
------------------------------------------------------------------
{
    id = "vocals",
    name = "VOCALS",
    color = "vocals",

    tracks = {{
        id = "vocal_lead",
        name = "Lead",
        type = "audio",
        role = "lead",
        color = "vocals",
        plugins = {{
            id = "vocal_lead_eq",
            plugin = "VST: ReaEQ (Cockos)",
            preset = "HRC Vocal Lead EQ"
        }, {
            id = "vocal_lead_1176",
            plugin = "VST3: UADx 1176 Rev A Compressor",
            preset = "HRC Vocal Lead 1176"
        }},
        routing = {
            output = "vocal_bus",
            sends = {{
                destination = "fx_plate",
                volume = -18
            }, {
                destination = "fx_hall",
                volume = -20
            }, {
                destination = "fx_delay",
                volume = -16
            }}
        }
    }, {
        id = "vocal_backing",
        name = "Backing",
        type = "audio",
        role = "backing",
        color = "vocals",
        routing = {
            output = "vocal_bus",
            sends = {{
                destination = "fx_plate",
                volume = -22
            }, {
                destination = "fx_hall",
                volume = -20
            }}
        }
    }, {
        id = "vocal_bus",
        name = "Vocal Bus",
        type = "bus",
        role = "master",
        color = "vocals",
        plugins = {{
            id = "vocal_bus_la2a",
            plugin = "VST3: UADx LA-2A Gray Compressor",
            preset = "HRC Vocal Bus LA-2A"
        }, {
            id = "vocal_bus_pultec",
            plugin = "VST3: UADx Pultec EQP-1A EQ",
            preset = "HRC Vocal Bus Pultec"
        }},
        routing = {
            output = "master_bus"
        }
    }}

}, ------------------------------------------------------------------
-- FX
------------------------------------------------------------------
{
    id = "fx",
    name = "FX",
    color = "fx",
    properties = {
        showInTCP = false
    },

    tracks = {{
        id = "fx_plate",
        name = "Plate",
        type = "fx",
        role = "reverb",
        color = "fx",
        plugins = {{
            id = "fx_plate_reverb",
            plugin = "VST3: UADx Pure Plate Reverb",
            preset = "HRC FX Plate"
        }},
        properties = {
            showInTCP = false
        },
        routing = {
            output = "master_bus"
        }
    }, {
        id = "fx_room",
        name = "Room",
        type = "fx",
        role = "reverb",
        color = "fx",
        plugins = {{
            id = "fx_room_sound_city",
            plugin = "VST3: UADx Sound City Studios",
            preset = "HRC FX Room"
        }},
        properties = {
            showInTCP = false
        },
        routing = {
            output = "master_bus"
        }
    }, {
        id = "fx_hall",
        name = "Hall",
        type = "fx",
        role = "reverb",
        color = "fx",
        plugins = {{
            id = "fx_hall_capitol",
            plugin = "VST3: UADx Capitol Chambers",
            preset = "HRC FX Hall"
        }},
        properties = {
            showInTCP = false
        },
        routing = {
            output = "master_bus"
        }
    }, {
        id = "fx_delay",
        name = "Delay",
        type = "fx",
        role = "delay",
        color = "fx",
        plugins = {{
            id = "fx_delay_valhalla",
            plugin = "VST3: ValhallaDelay (Valhalla DSP, LLC)",
            preset = "HRC FX Delay"
        }},
        properties = {
            showInTCP = false
        },
        routing = {
            output = "master_bus"
        }
    }}

}, {
    id = "master",
    name = "MASTER",
    color = "master",
    folder = false,

    tracks = {{
        id = "master_bus",
        name = "Master Bus",
        type = "bus",
        role = "master",
        color = "master",

        plugins = {{
            id = "master_bus_ssl_g",
            plugin = "VST3: UADx SSL G Bus Compressor",
            preset = "HRC Master Bus SSL G"
        }, {
            id = "master_bus_ampex",
            plugin = "VST3: UADx Ampex ATR-102 Master Tape",
            preset = "HRC Master Bus Ampex"
        }},
        properties = {
            showInTCP = false
        }
    }}

}}

return Layout
