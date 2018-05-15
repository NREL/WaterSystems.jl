export Link
export Pipe
export Valve

abstract type
    Link 
end

abstract type 
    Pipe <: Link
end

struct RegularPipe <: Link
    name::String
    connectionpoints::NamedTuple{(:from, :to),Tuple{Junction,Junction}}
    diameter::Float64
    length::Float64
    roughness::Float64
    headloss::Array{Tuple{Float64,Float64}}
    flow::Union{Nothing,Float64}
end

RegularPipe(;
            name,
            connectionpoints=(from::Junction(), to::Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing
            ) = RegularPipe(name, connectionpoints, diameter, length, roughness, headloss, flow)


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