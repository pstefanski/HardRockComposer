local SongStructure = {

    {
        id = "intro",
        name = "Intro",
        bars = 8
    },

    {
        id = "verse_1",
        name = "Verse 1",
        bars = 16,

        patterns = {
            drums = "verse_basic"
        },

        fill = "fill_basic"
    },

    {
        id = "chorus_1",
        name = "Chorus 1",
        bars = 8,

        patterns = {
            drums = "chorus_open"
        },

        fill = "fill_basic"
    },

    {
        id = "verse_2",
        name = "Verse 2",
        bars = 16,

        patterns = {
            drums = "verse_basic"
        },

        fill = "fill_basic"
    },

    {
        id = "chorus_2",
        name = "Chorus 2",
        bars = 8,

        patterns = {
            drums = "chorus_open"
        },

        fill = "fill_basic"
    },

    {
        id = "solo",
        name = "Solo",
        bars = 16
    },

    {
        id = "outro",
        name = "Outro",
        bars = 8
    }

}

return SongStructure