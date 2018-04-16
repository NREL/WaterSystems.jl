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
    initial_status::Bool
    diameter::Real
    tag::Any
    flow::Any
    minor_loss::Any
    setting::Any
    initial_setting::Real
    vertices::Any
    length::Real    
    roughness::Real
    bulk_rxn_coeff::Real
    wall_rxn_coeff::Real
    cv::Real
end

struct Valve <: Link
    name::String
    nodes::Tuple{Junction,Junction}
    status::Bool
    initial_status::Bool
    diameter::Real
    tag::String
    flow::Real
    vertices::Array
    minor_loss::Real
    setting::Any
    initial_setting::Real
    valve_type::String
end

include("pumps.jl")