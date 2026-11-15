local SongStructure = {{
    id = "intro",
    name = "Intro",
    bars = 4,
    color = "intro",
    energy = 0.8,
    fill = "pk_fill_snare",
    patterns = {
        drums = "pk_intro"
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    bars = 8,
    color = "verse",
    energy = 0.75,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            primary = "pk_verse",
            variation = "pk_verse_alt"
        }
    }
}, {
    id = "chorus_1",
    name = "Chorus 1",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    transition = "big",
    patterns = {
        drums = {
            opening = "pk_chorus_crash",
            primary = "pk_chorus"
        }
    }
}, {
    id = "verse_2",
    name = "Verse 2",
    bars = 8,
    color = "verse",
    energy = 0.8,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            primary = "pk_verse",
            variation = "pk_verse_alt"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    transition = "big",
    patterns = {
        drums = {
            opening = "pk_chorus_crash",
            primary = "pk_chorus"
        }
    }
}, {
    id = "bridge",
    name = "Bridge",
    bars = 8,
    color = "bridge",
    energy = 0.7,
    chance = 0.5,
    transition = "big",
    patterns = {
        drums = "pk_bridge"
    }
}, {
    id = "chorus_3",
    name = "Chorus 3",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            opening = "pk_chorus_crash",
            primary = "pk_chorus"
        }
    }
}, {
    id = "chorus_4",
    name = "Chorus 4",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    chance = 0.5,
    fill = "pk_fill_snare",
    patterns = {
        drums = {
            opening = "pk_chorus_crash",
            primary = "pk_chorus"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    bars = 1,
    color = "outro",
    energy = 1.0,
    patterns = {
        drums = "pk_ending"
    }
}}

return SongStructure
