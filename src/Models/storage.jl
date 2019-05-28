
abstract type
    Storage <: WaterSystemDevice
end
abstract type Tank <: Storage end

struct RoundTank <: Tank
    name::String
    node::Junction
    volumelimits::Union{NamedTuple{(:min, :max), Tuple{Float64, Float64}},Nothing} #m^3
    diameter::Float64 #m
    volume::Union{Nothing,Float64} #m^3
    area::Union{Nothing,Float64} #m^2
    level::Union{Nothing,Float64} #m initial level
    levellimits::Union{NamedTuple{(:min, :max), Tuple{Float64, Float64}},Nothing} #m
    internal:: WaterSystemInternal
    #vol_curve::Union{Nothing,NamedTuple}
end

# RoundTank with diameter and levels
function RoundTank(name, node, volumelimits, diameter, volume, area, level, levellimits)
    RoundTank(name, node, volumelimits, diameter, volume, area, level, levellimits, WaterSystemInternal())
end

function RoundTank(; name="init", node=Junction(), diameter = 0.0, levellimits=(min = 0.0, max = 0.0), level=0.0)

    area = π * (diameter/2)^2 ;
    volume = area * level;
    volumelimits = map(x->area*x,levellimits)
    return RoundTank(name, node, volumelimits, volume, area, level, levellimits)
end

struct StorageReservoir <: Storage
    name::String
    node::Junction
    elevation::Float64
    internal:: WaterSystemInternal
    #head_timeseries::TimeSeries.TimeArray
end

function StorageReservoir(name, node, elevation)
    StorageReservoir(name, node, elevation, WaterSystemInternal())
end 

StorageReservoir(;name::String, node::Junction, elevation::Float64) = StorageReservoir(name, node, elevation)

