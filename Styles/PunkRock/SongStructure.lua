local SongStructure = {{
    id = "intro",
    name = "Intro",
    chords = {"G5", "G5", "C5", "D5"},
    bars = 4,
    color = "intro",
    energy = 0.8,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            groove = "intro"
        }
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    chords = {"G5", "C5", "D5", "C5"},
    bars = 8,
    color = "verse",
    energy = 0.75,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_1",
    name = "Chorus 1",
    chords = {"C5", "G5", "D5", "G5"},
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
    chords = {"G5", "C5", "D5", "C5"},
    bars = 8,
    color = "verse",
    energy = 0.8,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            groove = "verse"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    chords = {"C5", "G5", "D5", "G5"},
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
    id = "bridge",
    name = "Bridge",
    chords = {"E5", "C5", "D5", "D5"},
    bars = 8,
    color = "bridge",
    energy = 0.7,
    chance = 0.5,
    transition = "big",
    patterns = {
        drums = {
            groove = "bridge"
        }
    }
}, {
    id = "chorus_3",
    name = "Chorus 3",
    chords = {"C5", "G5", "D5", "G5"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "chorus_4",
    name = "Chorus 4",
    chords = {"C5", "G5", "D5", "G5"},
    bars = 8,
    color = "chorus",
    energy = 1.0,
    chance = 0.5,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            groove = "chorus"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    chords = {"G5"},
    bars = 1,
    color = "outro",
    energy = 1.0,
    patterns = {
        drums = "pk_ending"
    }
}}

return SongStructure
