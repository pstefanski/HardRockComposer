local Midi = {}

function Midi.ValidateNote(note)

    if type(note.pitch) ~= "number" then
        return false
    end

    if type(note.position) ~= "number" then
        return false
    end

    if type(note.length) ~= "number" then
        return false
    end

    if type(note.velocity) ~= "number" then
        return false
    end

    return true

end

function Midi.ValidatePattern(pattern)

    if type(pattern.notes) ~= "table" then
        return false
    end

    for _, note in ipairs(pattern.notes) do

        if not Midi.ValidateNote(note) then
            return false
        end

    end

    return true

end

function Midi.PatternLengthQuarters(pattern)

    return pattern.bars * 4

end

return Midi
