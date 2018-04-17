export Storage
export Tank 
export Reservoir

abstract type 
    Storage <: Node
end

struct Tank <: Storage
    name::String
    elevation::Real
    head::Any
    level::Real
    min_level::Real
    max_level::Real
    min_vol::Real
    vol_curve::Union{Nothing,NamedTuple}
    diameter::Real
    coordinates::Tuple{Real,Real}
end

struct Reservoir <: Storage
    name::String
    elevation::Real
    head_timeseries::TimeSeries.TimeArray
    coordinates::Tuple{Real,Real}
end