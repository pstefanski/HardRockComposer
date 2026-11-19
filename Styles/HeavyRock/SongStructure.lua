local SongStructure = {{
    id = "intro",
    name = "Intro",
    chords = {"D5"},
    bars = 8,
    color = "intro",
    energy = 0.7,
    transition = "big",
    patterns = {
        drums = {
            groove = "intro"
        }
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    chords = {"D5", "D5", "F5", "C5"},
    bars = 16,
    color = "verse",
    energy = 0.7,
    fill = "hv_fill_toms",
    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_1",
    name = "Chorus 1",
    chords = {"Bb5", "C5", "D5", "D5"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    transition = "big",
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "verse_2",
    name = "Verse 2",
    chords = {"D5", "D5", "F5", "C5"},
    bars = 16,
    color = "verse",
    energy = 0.75,
    fill = "hv_fill_toms",
    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    chords = {"Bb5", "C5", "D5", "D5"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    transition = "big",
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "breakdown",
    name = "Breakdown",
    chords = {"D5", "D5", "Eb5", "D5"},
    bars = 8,
    color = "breakdown",
    energy = 0.9,
    chance = 0.5,
    transition = "big",
    patterns = {
        drums = "hv_breakdown"
    }
}, {
    id = "solo",
    name = "Solo",
    chords = {"D5", "C5", "Bb5", "C5"},
    bars = 16,
    color = "solo",
    energy = 0.9,
    fill = "hv_fill_toms",
    patterns = {
        drums = {
            groove = "solo"
        }
    }
}, {
    id = "chorus_3",
    name = "Chorus 3",
    chords = {"Bb5", "C5", "D5", "D5"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    transition = "big",
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    chords = {"D5"},
    bars = 4,
    color = "outro",
    energy = 1.0,
    patterns = {
        drums = {
            groove = "outro"
        }
    }
}}

return SongStructure
