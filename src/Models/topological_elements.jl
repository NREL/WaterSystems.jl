export Junction
export PressureZone

abstract type 
    Node
end

struct Junction <: Node
    name::String
    elevation::Real
    head::Any
    minimum_pressure::Real
    nominal_pressure::Real
    initial_quality::Real
    leak_status::Bool
    leak_demand::Any
    leak_area::Real
    leak_discharge_coeff::Real
    tag::String
    demand::Any 
    demand_timeseries_list::TimeSeries.TimeArray
    coordinates::Tuple{Real,Real}
end

struct PressureZone
    name::String
    junctions::Array{Junction}
end

include("storage.jl")
