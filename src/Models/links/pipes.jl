
struct RegularPipe<:Pipe
    number::Int64
    name::String
    connectionpoints:: @NT(from::Junction, to::Junction)
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    control_pipe::Bool
end

RegularPipe(;
            number = 1,
            name="init",
            connectionpoints=(from::Junction(), to::Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            control_pipe = false
            ) = RegularPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe)
