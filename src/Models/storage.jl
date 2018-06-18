
abstract type
    Storage
end

struct RoundTank <: Storage
    name::String
    node::Junction
    volumelimits::Union{@NT(min::Float64, max::Float64),Nothing}
    diameter::Float64
    volume::Union{Nothing,Float64}
    area::Union{Nothing,Float64}
    level::Union{Nothing,Float64}
    levellimits::Union{@NT(min::Float64, max::Float64),Nothing}
    #vol_curve::Union{Nothing,NamedTuple}
end

# RoundTank with diameter and levels
function RoundTank(name, node, volumelimits, diameter, volume, area, level, levellimits)
    RoundTank(name, node, volumelimits, diameter, volume, area, level, levellimits)
end

function RoundTank(; name="init", node=Junction(), diameter = 0.0, levellimits=@NT(min = 0.0, max = 0.0), level=0.0)

    area = π * diameter ;
    volume = area * level;
    volumelimits = map(x->area*x,levellimits)
    return RoundTank(name, node, volumelimits, volume, area, level, levellimits)
end

struct Reservoir <: Storage
    name::String
    node::Junction
    elevation::Real
    #head_timeseries::TimeSeries.TimeArray
end
