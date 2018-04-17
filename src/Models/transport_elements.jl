export Link
export Pipe
export Valve

abstract type
    Link 
end

struct Pipe <: Link
    name::String
    nodes::Tuple{Junction,Junction}
    status::Bool
    diameter::Real
    length::Real
    roughness::Real
    headloss::Real
    flow::Real
end

struct Valve <: Link
    name::String
    nodes::Tuple{Junction,Junction}
    status::Bool
    initial_status::Bool
    diameter::Real
    flow::Real
    setting::Any
    initial_setting::Real
    valve_type::String
end

include("pumps.jl")