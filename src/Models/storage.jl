export Storage
export RoundTank
export Reservoir

abstract type
    Storage
end

struct RoundTank <: Storage
    name::String
    node::Junction
    volumelimits::Union{@NT(min::Float64,max::Float64),Nothing}
    volume::Union{Nothing,Float64}
    area::Union{Nothing,Float64}
    level::Union{Nothing,Float64}
    levellimits::Union{@NT(min::Float64, max::Float64),Nothing}
    #vol_curve::Union{Nothing,NamedTuple}
end

# RoundTank with diameter and levels
function RoundTank(; name="init", node=Junction(), diameter = 0.0, levellimits=(0.0, 0.0), level=0.0)
    area = π * diameter ;
    volume = area * level;
    volumelimits = map(x->area*x,levellimits)
    return RoundTank(name, node, volumelimits, volume, area, level, levellimits)
end

struct Reservoir <: Storage
    name::String
    elevation::Real
    #head_timeseries::TimeSeries.TimeArray
end
