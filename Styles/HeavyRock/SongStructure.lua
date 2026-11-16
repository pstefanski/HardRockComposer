local SongStructure = {{
    id = "intro",
    name = "Intro",
    bars = 8,
    color = "intro",
    energy = 0.7,
    transition = "big",
    patterns = {
        drums = {
            opening = "hv_intro_crash",
            primary = "hv_intro_toms"
        }
    }
}, {
    id = "verse_1",
    name = "Verse 1",
    bars = 16,
    color = "verse",
    energy = 0.7,
    fill = "hv_fill_toms",
    patterns = {
        drums = {
            primary = "hv_verse",
            variation = "hv_verse_alt"
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
            opening = "hv_chorus_crash",
            primary = "hv_chorus"
        }
    }
}, {
    id = "verse_2",
    name = "Verse 2",
    bars = 16,
    color = "verse",
    energy = 0.75,
    fill = "hv_fill_toms",
    patterns = {
        drums = {
            primary = "hv_verse",
            variation = "hv_verse_alt"
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
            opening = "hv_chorus_crash",
            primary = "hv_chorus"
        }
    }
}, {
    id = "breakdown",
    name = "Breakdown",
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
    bars = 16,
    color = "solo",
    energy = 0.9,
    fill = "hv_fill_toms",
    patterns = {
        drums = {
            opening = "hv_chorus_crash",
            primary = "hv_solo"
        }
    }
}, {
    id = "chorus_3",
    name = "Chorus 3",
    bars = 8,
    color = "chorus",
    energy = 1.0,
    transition = "big",
    patterns = {
        drums = {
            opening = "hv_chorus_crash",
            primary = "hv_chorus"
        }
    }
}, {
    id = "outro",
    name = "Outro",
    bars = 4,
    color = "outro",
    energy = 1.0,
    patterns = {
        drums = {
            opening = "hv_chorus_crash",
            primary = "hv_outro"
        }
    }
}}

return SongStructure
