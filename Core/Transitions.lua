--------------------------------------------------
-- How a section hands over to the next one.
--
-- A section can force a fill written by hand:
--
--     fill = "fill_tom_2beat"
--
-- or declare a transition:
--
--     transition = "none"     -- the groove plays to the end
--                | "pickup"   -- a light pickup on the last beat
--                | "fill"     -- a fill of 2 beats (3 when the energy rises)
--                | "big"      -- a fill over the whole last bar
--                | "build"    -- a snare build over the last 1 or 2 bars
--
-- When the style declares Drums.fills, the transitions are generated (see
-- DrumFill) and a section without a transition gets one from the energy of
-- the next section: none at the end of the song, big when the energy jumps,
-- fill otherwise.
--
-- Without Drums.fills, a "big" transition plays the style's "fill_big"
-- pattern, as before generated fills existed.
--------------------------------------------------

local Transitions = {}

Transitions.KINDS = {
    none = true,
    pickup = true,
    fill = true,
    big = true,
    build = true
}

-- Energy jump from which a section ends with a big fill by default.
Transitions.BIG_RISE = 0.3

-- Transition used when the section does not declare one.
function Transitions.Default(section, nextSection)

    if not nextSection then
        return "none"
    end

    local rise = (nextSection.energy or 1) - (section.energy or 1)

    -- The margin keeps 0.6 - 0.3 from falling just short of 0.3.
    if rise >= Transitions.BIG_RISE - 1e-9 then
        return "big"
    end

    return "fill"

end

-- Returns how `section` ends:
--
--     nil                       no transition
--     { pattern = "id" }        a fill written by hand
--     { kind = "fill", ... }    a generated transition
function Transitions.Resolve(section, nextSection, generated)

    if section.fill then
        return {
            pattern = section.fill
        }
    end

    local kind = section.transition

    if not generated then

        if kind == "big" then
            return {
                pattern = "fill_big"
            }
        end

        if kind == nil or kind == "none" then
            return nil
        end

    end

    kind = kind or Transitions.Default(section, nextSection)

    if kind == "none" then
        return nil
    end

    return {
        kind = kind
    }

end

return Transitions
