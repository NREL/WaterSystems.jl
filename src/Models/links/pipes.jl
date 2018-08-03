include("valves.jl")
abstract type RegularPipe <: Pipe end
abstract type PositiveFlowPipe <: RegularPipe end

struct StandardPositiveFlowPipe <: PositiveFlowPipe
    number::Int64
    name::String
    connectionpoints:: @NT(from::Junction, to::Junction)
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    headloss_parameters:: Array{@NT(flow::Float64, slope::Float64, intercept::Float64)} #Q, a, b
end

struct NegativeFlowPipe <: RegularPipe
    number::Int64
    name::String
    connectionpoints:: @NT(from::Junction, to::Junction)
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    headloss_parameters:: Array{@NT(flow::Float64, slope::Float64, intercept::Float64)}
end

struct ReversibleFlowPipe <: RegularPipe
    number::Int64
    name::String
    connectionpoints:: @NT(from::Junction, to::Junction)
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    headloss_parameters:: Array{@NT(flow::Float64, slope::Float64, intercept::Float64)}
end
struct CheckValvePipe <: PositiveFlowPipe
    number::Int64
    name::String
    connectionpoints:: @NT(from::Junction, to::Junction)
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    headloss_parameters:: Array{@NT(flow::Float64, slope::Float64, intercept::Float64)}
end

struct ControlPipe{T} <:Pipe where T<:Array{<:RegularPipe}
    pipe::T
    valve:: GateValve
end

PositiveFlowPipe(;
            number = 1,
            name="init",
            connectionpoints=(from::Junction(), to::Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            headloss_parameters = [@NT(flow = 0.0, slope = 0.0, intercept = 0.0)]
            ) = PositiveFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, headloss_parameters)

NegativeFlowPipe(;
            number = 1,
            name="init",
            connectionpoints=(from::Junction(), to::Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            headloss_parameters = [@NT(flow = 0.0, slope = 0.0, intercept = 0.0)]
            ) = NegativeFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, headloss_parameters)

ReversibleFlowPipe(;
            number = 1,
            name="init",
            connectionpoints=(from::Junction(), to::Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            headloss_parameters = [@NT(flow = 0.0, slope = 0.0, intercept = 0.0)]
            ) = ReversibleFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, headloss_parameters)


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
            headloss_parameters = [@NT(flow = 0.0, slope = 0.0, intercept = 0.0)]
            ) = RegularPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, headloss_parameters)

ControlPipe(;
            pipe = ReversibleFlowPipe(),
            valve = CheckValve()
            ) = ControlPipe(pipe, valve)

function PositiveFlowPipe(number::Int64, name::String, connectionpoints:: @NT(from::Junction, to::Junction), diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    headloss_parameters = [@NT(flow = 0.0, slope = 0.0, intercept = 0.0)]
    return PositiveFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, headloss_parameters)
end

function NegativeFlowPipe(number::Int64, name::String, connectionpoints:: @NT(from::Junction, to::Junction), diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    headloss_parameters = [@NT(flow = 0.0, slope = 0.0, intercept = 0.0)]
    return NegativeFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, headloss_parameters)
end

function ReversibleFlowPipe(number::Int64, name::String, connectionpoints:: @NT(from::Junction, to::Junction), diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    headloss_parameters = [@NT(flow = 0.0, slope = 0.0, intercept = 0.0)]
    return ReversibleFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, headloss_parameters)
end

function CheckValvePipe(number::Int64, name::String, connectionpoints:: @NT(from::Junction, to::Junction), diameter::Float64, length::Float64,
                    roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    headloss_parameters = [@NT(flow = 0.0, slope = 0.0, intercept = 0.0)]
    return CheckValvePipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, headloss_parameters)
end
