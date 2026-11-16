-- Verses and solo follow the 12-bar blues form.

local SongStructure = {{
    id = "intro",
    name = "Intro",
    bars = 4,
    color = "intro",
    energy = 0.4,
    fill = "bl_fill_triplet",
    patterns = {
        drums = "bl_intro"
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    bars = 12,
    color = "verse",
    energy = 0.6,
    fill = "bl_fill_triplet",
    patterns = {
        drums = {
            primary = "bl_verse",
            variation = "bl_verse_alt"
        }
    }
}, {
    id = "chorus_1",
    name = "Chorus 1",
    bars = 8,
    color = "chorus",
    energy = 0.9,
    fill = "bl_fill_toms",
    patterns = {
        drums = {
            opening = "bl_chorus_crash",
            primary = "bl_chorus"
        }
    }
}, {
    id = "verse_2",
    name = "Verse 2",
    bars = 12,
    color = "verse",
    energy = 0.65,
    fill = "bl_fill_triplet",
    patterns = {
        drums = {
            primary = "bl_verse",
            variation = "bl_verse_alt"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    bars = 8,
    color = "chorus",
    energy = 0.9,
    fill = "bl_fill_toms",
    patterns = {
        drums = {
            opening = "bl_chorus_crash",
            primary = "bl_chorus"
        }
    }
}, {
    id = "solo",
    name = "Solo",
    bars = 12,
    color = "solo",
    energy = 0.85,
    fill = "bl_fill_toms",
    patterns = {
        drums = {
            opening = "bl_chorus_crash",
            primary = "bl_solo"
        }
    }
}, {
    id = "breakdown",
    name = "Stop Time",
    bars = 4,
    color = "breakdown",
    energy = 0.7,
    chance = 0.5,
    fill = "bl_fill_toms",
    patterns = {
        drums = "bl_stop_time"
    }
}, {
    id = "chorus_3",
    name = "Chorus 3",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    fill = "bl_fill_triplet",
    patterns = {
        drums = {
            opening = "bl_chorus_crash",
            primary = "bl_chorus"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    bars = 2,
    color = "outro",
    energy = 1.0,
    patterns = {
        drums = {
            opening = "bl_ending",
            primary = "bl_rest"
        }
    }
}}

return SongStructure
