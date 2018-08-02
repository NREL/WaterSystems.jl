
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
    flow_direction::String
    aPipe_over:: Dict{String, Array{Float64,1}}
    bPipe_over::Dict{String, Array{Float64,1}}
    aPipe_under::Dict{String, Array{Float64,1}}
    bPipe_under::Dict{String, Array{Float64,1}}
    Q_Base:: Array{Float64}
end

struct CheckValvePipe <: Pipe
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
    flow_direction::String
    aPipe_over:: Dict{String, Array{Float64,1}}
    bPipe_over::Dict{String, Array{Float64,1}}
    aPipe_under::Dict{String, Array{Float64,1}}
    bPipe_under::Dict{String, Array{Float64,1}}
    Q_Base:: Array{Float64}
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
            control_pipe = false,
            flow_direction = "Reversible",
            aPipe_over = Dict{String, Array{Float64,1}}(),
            bPipe_over = Dict{String, Array{Float64,1}}(),
            aPipe_under = Dict{String, Array{Float64,1}}(),
            bPipe_under = Dict{String, Array{Float64,1}}(),
            Q_Base = [0.0]
            ) = RegularPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, aPipe_over, bPipe_over, aPipe_under, bPipe_under, Q_Base)

CheckValvePipe(;
            number = 1,
            name="init",
            connectionpoints=(from::Junction(), to::Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            control_pipe = false,
            flow_direction = "Reversible",
            aPipe_over = Dict{String, Array{Float64,1}}(),
            bPipe_over = Dict{String, Array{Float64,1}}(),
            aPipe_under = Dict{String, Array{Float64,1}}(),
            bPipe_under = Dict{String, Array{Float64,1}}(),
            Q_Base = [0.0]
            ) = RegularPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, aPipe_over, bPipe_over, aPipe_under, bPipe_under, Q_Base)

function RegularPipe(number::Int64, name::String, connectionpoints:: @NT(from::Junction, to::Junction), diameter::Float64, length::Float64,
                    roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64, control_pipe::Bool)
    flow_direction = "Reversible"
    aPipe_over = Dict{String, Array{Float64,1}}()
    bPipe_over = Dict{String, Array{Float64,1}}()
    aPipe_under = Dict{String, Array{Float64,1}}()
    bPipe_under = Dict{String, Array{Float64,1}}()
    Q_Base = [0.0]
    return RegularPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, aPipe_over, bPipe_over, aPipe_under, bPipe_under, Q_Base)
end
function CheckValvePipe(number::Int64, name::String, connectionpoints:: @NT(from::Junction, to::Junction), diameter::Float64, length::Float64,
                    roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64, control_pipe::Bool)
    flow_direction = "Reversible"
    aPipe_over = Dict{String, Array{Float64,1}}()
    bPipe_over = Dict{String, Array{Float64,1}}()
    aPipe_under = Dict{String, Array{Float64,1}}()
    bPipe_under = Dict{String, Array{Float64,1}}()
    Q_Base = [0.0]
    return CheckValvePipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, aPipe_over, bPipe_over, aPipe_under, bPipe_under, Q_Base)
end
