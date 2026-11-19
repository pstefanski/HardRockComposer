-- Verses and solo follow the 12-bar blues form.

local SongStructure = {{
    id = "intro",
    name = "Intro",
    chords = {"E7", "A7", "E7", "B7"},
    bars = 4,
    color = "intro",
    energy = 0.4,
    patterns = {
        drums = {
            groove = "intro"
        }
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    chords = {"E7", "E7", "E7", "E7", "A7", "A7", "E7", "E7", "B7", "A7", "E7", "B7"},
    bars = 12,
    color = "verse",
    energy = 0.6,
    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_1",
    name = "Chorus 1",
    chords = {"A7", "A7", "E7", "E7", "B7", "A7", "E7", "B7"},
    bars = 8,
    color = "chorus",
    energy = 0.9,
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "verse_2",
    name = "Verse 2",
    chords = {"E7", "E7", "E7", "E7", "A7", "A7", "E7", "E7", "B7", "A7", "E7", "B7"},
    bars = 12,
    color = "verse",
    energy = 0.65,
    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    chords = {"A7", "A7", "E7", "E7", "B7", "A7", "E7", "B7"},
    bars = 8,
    color = "chorus",
    energy = 0.9,
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "solo",
    name = "Solo",
    chords = {"E7", "E7", "E7", "E7", "A7", "A7", "E7", "E7", "B7", "A7", "E7", "B7"},
    bars = 12,
    color = "solo",
    energy = 0.85,
    patterns = {
        drums = {
            groove = "solo"
        }
    }
}, {
    id = "breakdown",
    name = "Stop Time",
    chords = {"E7"},
    bars = 4,
    color = "breakdown",
    energy = 0.7,
    chance = 0.5,
    patterns = {
        drums = "bl_stop_time"
    }
}, {
    id = "chorus_3",
    name = "Chorus 3",
    chords = {"A7", "A7", "E7", "E7", "B7", "A7", "E7", "B7"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    chords = {"E7"},
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
