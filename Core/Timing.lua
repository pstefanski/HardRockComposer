local Timing = {}

function Timing.BeatsPerBar(settings)

    return settings.beats_per_bar

end

function Timing.BarToQN(bar, settings)

    return (bar - 1) * settings.beats_per_bar

end

function Timing.BarsToQN(bars, settings)

    return bars * settings.beats_per_bar

end

function Timing.PositionToQN(bar, position, settings)

    local barQN = Timing.BarToQN(bar, settings)

    local subdivisionQN = position / 4

    return barQN + subdivisionQN

end

return Timing
