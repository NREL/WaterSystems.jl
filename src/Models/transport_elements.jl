export Link
export RegularPipe
export PressureReducingValve

abstract type
    Link 
end

struct RegularPipe <: Link
    name::String
    connectionpoints::NamedTuple{(:from, :to),Tuple{Junction,Junction}}
    diameter::Float64
    length::Float64
    roughness::Float64
    headloss::Array{Tuple{Float64,Float64},1}
    flow::Union{Nothing,Float64}
end

RegularPipe(;
            name="init",
            connectionpoints=(from::Junction(), to::Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing
            ) = RegularPipe(name, connectionpoints, diameter, length, roughness, headloss, flow)


struct PressureReducingValve <: Link
    name::String
    connectionpoints::NamedTuple{(:from, :to),Tuple{Junction,Junction}}
    status::Bool
    diameter::Union{Nothing,Float64}
    setting::Union{Nothing,Float64}
end

PressureReducingValve(;
                    name="init",
                    connectionpoints=(from::Junction(), to::Junction()),
                    status=false,
                    diameter=1,
                    setting=nothing
                    ) = PressureReducingValve(name,connectionpoints,status,diameter,setting)
