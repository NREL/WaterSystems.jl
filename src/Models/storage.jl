export Storage
export Tank 
export Roundtank
export Reservoir

abstract type 
    Storage 
end

abstract type 
    Tank <: Storage
end

struct Roundtank <: Tank
    name::String
    node::Junction
    volumelimits::Union{NamedTuple{(:min, :max),Tuple{Float64,Float64}},Nothing}
    volume::Union{Nothing,Float64}
    area::Union{Nothing,Float64}
    level::Union{Nothing,Float64}
    levellimits::Union{NamedTuple{(:min, :max),Tuple{Float64,Float64}},Nothing}
    #vol_curve::Union{Nothing,NamedTuple}
end

# Roundtank with diameter and levels
function Roundtank(; name::String, node::Junction, diameter::Float64, levellimits::Union{NamedTuple{(:min, :max),Tuple{Float64,Float64}},Nothing}, level::Float64)
    area = π * diameter ;
    volume = area * level;
    volumelimits = [x * area for x in levellimits];
    return Roundtank(name, node, volumelimits, volume, area, level, levellimits)
end

struct Reservoir <: Storage
    name::String
    elevation::Real
    #head_timeseries::TimeSeries.TimeArray
end
