local SongStructure = {{
    id = "intro",
    name = "Intro",
    chords = {"E5", "E5", "G5", "A5"},
    bars = 8,
    color = "intro",
    energy = 0.3,
    fill = "fill_snare_pickup",
    patterns = {
        drums = {
            groove = "intro"
        }
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    chords = {"E5", "E5", "D5", "A5"},
    bars = 16,
    color = "verse",
    energy = 0.6,
    transition = "big",

    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_1",
    name = "Chorus 1",
    chords = {"A5", "B5", "E5", "E5"},
    bars = 8,
    color = "chorus",
    energy = 1.0,

    patterns = {
        drums = {
            groove = "chorus"
        }
    }

}, {
    id = "verse_2",
    name = "Verse 2",
    chords = {"E5", "E5", "D5", "A5"},
    bars = 16,
    color = "verse",
    energy = 0.6,
    transition = "big",

    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    chords = {"A5", "B5", "E5", "E5"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    fill = "fill_tom_2beat",
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "solo",
    name = "Solo",
    chords = {"E5", "G5", "A5", "E5"},
    bars = 16,
    color = "solo",
    energy = 0.9,
    fill = "fill_tom_2beat",
    patterns = {
        drums = {
            groove = "solo"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    chords = {"E5", "D5", "A5", "E5"},
    bars = 8,
    color = "outro",
    energy = 1.0,
    patterns = {
        drums = {
            groove = "outro"
        }
    }
}}

return SongStructure
