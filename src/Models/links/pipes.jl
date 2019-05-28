include("valves.jl")
abstract type RegularPipe <: Pipe end
abstract type PositiveFlowPipe <: RegularPipe end

struct StandardPositiveFlowPipe <: PositiveFlowPipe
    number::Int64
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    flow_limits:: NamedTuple{(:Qmin, :Qmax), Tuple{Float64, Float64}}
    headloss_parameters:: Array{NamedTuple{(:flow, :slope, :intercept), Tuple{Float64, Float64, Float64}}} #Q, a, b
    internal:: WaterSystemInternal
end

struct NegativeFlowPipe <: RegularPipe
    number::Int64
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    flow_limits:: NamedTuple{(:Qmin, :Qmax), Tuple{Float64, Float64}}
    headloss_parameters:: Array{NamedTuple{(:flow, :slope, :intercept), Tuple{Float64, Float64, Float64}}}
    internal:: WaterSystemInternal
end

struct ReversibleFlowPipe <: RegularPipe
    number::Int64
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    flow_limits:: NamedTuple{(:Qmin, :Qmax), Tuple{Float64, Float64}}
    headloss_parameters:: Array{NamedTuple{(:flow, :slope, :intercept), Tuple{Float64, Float64, Float64}}}
    internal:: WaterSystemInternal
end
struct CheckValvePipe <: PositiveFlowPipe
    number::Int64
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    flow_limits:: NamedTuple{(:Qmin, :Qmax), Tuple{Float64, Float64}}
    headloss_parameters:: Array{NamedTuple{(:flow, :slope, :intercept), Tuple{Float64, Float64, Float64}}}
    internal:: WaterSystemInternal
end

struct ControlPipe{T} <:Pipe where T<:Array{<:RegularPipe}
    pipe::T
    valve:: GateValve
    internal:: WaterSystemInternal
end

StandardPositiveFlowPipe(;
            number = 1,
            name="init",
            connectionpoints= (from = Junction(), to = Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            flow_limits = (Qmin = 0.0, Qmax =0.0),
            headloss_parameters = [(flow = 0.0, slope = 0.0, intercept = 0.0)]
            ) = PositiveFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, flow_limits, headloss_parameters)

NegativeFlowPipe(;
            number = 1,
            name="init",
            connectionpoints=(from = Junction(), to = Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            flow_limits = (Qmin = 0.0, Qmax =0.0),
            headloss_parameters = [(flow = 0.0, slope = 0.0, intercept = 0.0)]
            ) = NegativeFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, flow_limits, headloss_parameters)

ReversibleFlowPipe(;
            number = 1,
            name="init",
            connectionpoints=(from = Junction(), to = Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            flow_limits = (Qmin = 0.0, Qmax =0.0),
            headloss_parameters = [(flow = 0.0, slope = 0.0, intercept = 0.0)]
            ) = ReversibleFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, control_pipe, flow_direction, flow_limits, headloss_parameters)


CheckValvePipe(;
            number = 1,
            name="init",
            connectionpoints=(from = Junction(), to = Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            flow_limits = (Qmin = 0.0, Qmax =0.0),
            headloss_parameters = [(flow = 0.0, slope = 0.0, intercept = 0.0)]
            ) = RegularPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits, headloss_parameters)

ControlPipe(;
            pipe = ReversibleFlowPipe(),
            valve = CheckValve()
            ) = ControlPipe(pipe, valve, WaterSystemInternal())

function ControlPipe(pipe::ReversibleFlowPipe, valve::GateValve)
    ControlPipe(pipe,valve, WaterSystemInternal())
end 

function StandardPositiveFlowPipe(number::Int64, name::String, connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}, diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    flow_limits = (Qmin = 0.0, Qmax =0.0)
    headloss_parameters = [(flow = 0.0, slope = 0.0, intercept = 0.0)]
    return PositiveFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits, headloss_parameters, WaterSystemInternal())
end

function NegativeFlowPipe(number::Int64, name::String, connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}, diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    flow_limits = (Qmin = 0.0, Qmax =0.0)
    headloss_parameters = [(flow = 0.0, slope = 0.0, intercept = 0.0)]
    return NegativeFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits, headloss_parameters, WaterSystemInternal())
end

function ReversibleFlowPipe(number::Int64, name::String, connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}, diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    flow_limits = (Qmin = 0.0, Qmax =0.0)
    headloss_parameters = [(flow = 0.0, slope = 0.0, intercept = 0.0)]
    return ReversibleFlowPipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits, headloss_parameters, WaterSystemInternal())
end

function CheckValvePipe(number::Int64, name::String, connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}, diameter::Float64, length::Float64,
                    roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    flow_limits = (Qmin = 0.0, Qmax =0.0)
    headloss_parameters = [(flow = 0.0, slope = 0.0, intercept = 0.0)]
    return CheckValvePipe(number, name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits, headloss_parameters, WaterSystemInternal())
end
