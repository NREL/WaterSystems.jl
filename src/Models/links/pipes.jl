
struct RegularPipe<:Pipe
    number::Int64
    name::String
    connectionpoints:: @NT(from::Junction, to::Junction)
    diameter::Float64
    length::Float64
    roughness::Float64
    headloss::Float64
    flow::Union{Nothing,Float64}
    initial_status:: Int64
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
            initial_status = 0
            ) = RegularPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status)
