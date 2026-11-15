local SongStructure = {{
    id = "intro",
    name = "Intro",
    bars = 8,
    color = "intro",
    energy = 0.3,
    fill = "fill_snare_pickup",
    patterns = {
        drums = {
            primary = "intro_toms",
            variation = "intro_toms_alt"
        }
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    bars = 16,
    color = "verse",
    energy = 0.6,
    transition = "big",

    patterns = {
        drums = {
            primary = "verse_drive",
            variation = "verse_drive_alt"
        }
    }
}, {
    id = "chorus_1",
    name = "Chorus 1",
    bars = 8,
    color = "chorus",
    energy = 1.0,

    patterns = {
        drums = {
            opening = "chorus_crash",
            primary = "chorus_drive",
            variation = "chorus_crash_alt"
        }
    }

}, {
    id = "verse_2",
    name = "Verse 2",
    bars = 16,
    color = "verse",
    energy = 0.6,
    transition = "big",

    patterns = {
        drums = {
            primary = "verse_drive",
            variation = "verse_drive_alt"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    fill = "fill_tom_2beat",
    patterns = {
        drums = {
            opening = "chorus_crash",
            primary = "chorus_drive",
            variation = "chorus_crash_alt"
        }
    }
}, {
    id = "solo",
    name = "Solo",
    bars = 16,
    color = "solo",
    energy = 0.9,
    fill = "fill_tom_2beat",
    patterns = {
        drums = {
            opening = "solo_crash",
            primary = "solo_ride",
            variation = "solo_drive_alt"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    bars = 8,
    color = "outro",
    energy = 1.0,
    patterns = {
        drums = {
            opening = "outro_crash",
            primary = "outro_drive"
        }
    }
}}

return SongStructure
