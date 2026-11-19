local SongStructure = {{
    id = "intro",
    name = "Intro",
    chords = {"A", "A", "D", "E"},
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
    chords = {"A", "D", "A", "E"},
    bars = 16,
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
    chords = {"D", "A", "E", "A"},
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
    chords = {"A", "D", "A", "E"},
    bars = 16,
    color = "verse",
    energy = 0.6,
    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    chords = {"D", "A", "E", "A"},
    bars = 8,
    color = "chorus",
    energy = 0.9,
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "bridge",
    name = "Bridge",
    chords = {"F#m", "D", "E", "E"},
    bars = 8,
    color = "bridge",
    energy = 0.5,
    chance = 0.5,
    patterns = {
        drums = {
            groove = "bridge"
        }
    }
}, {
    id = "solo",
    name = "Solo",
    chords = {"A", "G", "D", "A"},
    bars = 16,
    color = "solo",
    energy = 0.85,
    patterns = {
        drums = {
            groove = "solo"
        }
    }
}, {
    id = "chorus_3",
    name = "Chorus 3",
    chords = {"D", "A", "E", "A"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    transition = "pickup",
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "chorus_4",
    name = "Chorus 4",
    chords = {"D", "A", "E", "A"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    chance = 0.5,
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    chords = {"A"},
    bars = 2,
    color = "outro",
    energy = 1.0,
    patterns = {
        drums = {
            opening = "cr_ending",
            primary = "cr_rest"
        }
    }
}}

return SongStructure
