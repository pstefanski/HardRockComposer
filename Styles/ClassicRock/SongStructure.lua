local SongStructure = {{
    id = "intro",
    name = "Intro",
    bars = 4,
    color = "intro",
    energy = 0.4,
    fill = "cr_fill_snare",
    patterns = {
        drums = "cr_intro"
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    bars = 16,
    color = "verse",
    energy = 0.6,
    fill = "cr_fill_snare",
    patterns = {
        drums = {
            primary = "cr_verse",
            variation = "cr_verse_alt"
        }
    }
}, {
    id = "chorus_1",
    name = "Chorus 1",
    bars = 8,
    color = "chorus",
    energy = 0.9,
    fill = "cr_fill_toms",
    patterns = {
        drums = {
            opening = "cr_chorus_crash",
            primary = "cr_chorus"
        }
    }
}, {
    id = "verse_2",
    name = "Verse 2",
    bars = 16,
    color = "verse",
    energy = 0.6,
    fill = "cr_fill_snare",
    patterns = {
        drums = {
            primary = "cr_verse",
            variation = "cr_verse_alt"
        }
    }
}, {
    id = "chorus_2",
    name = "Chorus 2",
    bars = 8,
    color = "chorus",
    energy = 0.9,
    fill = "cr_fill_toms",
    patterns = {
        drums = {
            opening = "cr_chorus_crash",
            primary = "cr_chorus"
        }
    }
}, {
    id = "bridge",
    name = "Bridge",
    bars = 8,
    color = "bridge",
    energy = 0.5,
    chance = 0.5,
    fill = "cr_fill_toms",
    patterns = {
        drums = "cr_bridge"
    }
}, {
    id = "solo",
    name = "Solo",
    bars = 16,
    color = "solo",
    energy = 0.85,
    fill = "cr_fill_toms",
    patterns = {
        drums = {
            opening = "cr_chorus_crash",
            primary = "cr_solo"
        }
    }
}, {
    id = "chorus_3",
    name = "Chorus 3",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    fill = "cr_fill_snare",
    patterns = {
        drums = {
            opening = "cr_chorus_crash",
            primary = "cr_chorus"
        }
    }
}, {
    id = "chorus_4",
    name = "Chorus 4",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    chance = 0.5,
    fill = "cr_fill_toms",
    patterns = {
        drums = {
            opening = "cr_chorus_crash",
            primary = "cr_chorus"
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
            opening = "cr_ending",
            primary = "cr_rest"
        }
    }
}}

return SongStructure
