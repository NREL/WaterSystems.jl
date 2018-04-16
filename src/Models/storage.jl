export Storage
export Tank 
export Reservoir

abstract type 
    Storage <: Node
end

struct Tank <: Storage
    name::String
    elevation::Real
    diameter::Real
    head::Any
    init_level::Real
    level::Any
    min_level::Real
    max_level::Real
    min_vol::Real
    vol_curve::Union{Nothing,NamedTuple}
    vol_curve_name::String
    bulk_rxn_coeff::Real
    leak_status::Bool
    leak_area::Real
    leak_discharge_coeff::Real
    leak_demand::Any
    initial_quality::Real
    demand::Any
    tag::Any
    coordinates::Tuple{Real,Real}
end

struct Reservoir <: Storage
    name::String
    head::Any
    head_pattern_name::String
    head_timeseries::TimeSeries.TimeArray
    base_head::Real
    leak_status::Bool
    leak_demand::Any
    leak_area::Real
    leak_discharge_coeff::Real
    tag::Any
    demand::Real
    coordinates::Tuple{Real,Real}
    initial_quality::Real
end