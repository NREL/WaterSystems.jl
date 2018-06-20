abstract type
    Link
end

struct RegularPipe <: Link
    name::String
    connectionpoints:: @NT(from::Junction, to::Junction)
    diameter::Float64
    length::Float64
    roughness::Float64
    headloss::Float64
    flow::Union{Nothing,Float64}
    initial_status:: Int64
    link_type::String
end

RegularPipe(;
            name="init",
            connectionpoints=(from::Junction(), to::Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            link_type = "Pipe"
            ) = RegularPipe(name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, link_type)


struct PressureReducingValve <: Link
    name::String
    connectionpoints::@NT(from::Junction, to::Junction)
    status::String
    diameter::Union{Nothing,Float64}
    setting::Union{Nothing,Float64}
    link_type::String
end

PressureReducingValve(;
                    name="init",
                    connectionpoints= @NT(from::Junction(), to::Junction()),
                    status="Closed",
                    diameter=1.0,
                    setting=nothing,
                    link_type = "Valve"
                    ) = PressureReducingValve(name, connectionpoints, status, diameter, setting, link_type)
