include("valves.jl")
abstract type RegularPipe <: Pipe end
abstract type PositiveFlowPipe <: RegularPipe end

struct StandardPositiveFlowPipe <: PositiveFlowPipe
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    flow_limits:: NamedTuple{(:Qmin, :Qmax), Tuple{Float64, Float64}}
end

struct NegativeFlowPipe <: RegularPipe
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    flow_limits:: NamedTuple{(:Qmin, :Qmax), Tuple{Float64, Float64}}
end

struct ReversibleFlowPipe <: RegularPipe 
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    flow_limits:: NamedTuple{(:Qmin, :Qmax), Tuple{Float64, Float64}}
end
struct CheckValvePipe <: PositiveFlowPipe
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    diameter::Float64 #m
    length::Float64 #m
    roughness::Float64 #unitless unless using Darcy-Weisbach then mm
    headloss::Float64 #m
    flow::Union{Nothing,Float64} #m^3/s
    initial_status:: Int64
    flow_limits:: NamedTuple{(:Qmin, :Qmax), Tuple{Float64, Float64}}
end

struct ControlPipe{T} <:Pipe where T<:Array{<:RegularPipe}
    pipe::T
    valve:: GateValve
end

StandardPositiveFlowPipe(;
            name="init",
            connectionpoints= (from = Junction(), to = Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = 0.0,
            flow = 0.0,
            initial_status = 0,
            flow_limits = (Qmin = 0.0, Qmax =0.0),
            ) = StandardPositiveFlowPipe(name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status,flow_limits)

NegativeFlowPipe(;
            name="init",
            connectionpoints=(from = Junction(), to = Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            flow_limits = (Qmin = 0.0, Qmax =0.0)
            ) = NegativeFlowPipe(name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits)

ReversibleFlowPipe(;
            name="init",
            connectionpoints=(from = Junction(), to = Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            flow_limits = (Qmin = 0.0, Qmax =0.0),
            ) = ReversibleFlowPipe(name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits)


CheckValvePipe(; 
            name="init",
            connectionpoints=(from = Junction(), to = Junction()),
            diameter = 0,
            length = 0,
            roughness = 0,
            headloss = nothing,
            flow = nothing,
            initial_status = 0,
            flow_limits = (Qmin = 0.0, Qmax =0.0)
            ) = RegularPipe(name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits)

ControlPipe(;
            pipe = ReversibleFlowPipe(),
            valve = CheckValve()
            ) = ControlPipe(pipe, valve)

function StandardPositiveFlowPipe(name::String, connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}, diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    flow_limits = (Qmin = 0.0, Qmax =0.0)
    return StandardPositiveFlowPipe( name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits)
end

function NegativeFlowPipe(name::String, connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}, diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    flow_limits = (Qmin = 0.0, Qmax =0.0)
    return NegativeFlowPipe( name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits)
end

function ReversibleFlowPipe(name::String, connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}, diameter::Float64, length::Float64, roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    flow_limits = (Qmin = 0.0, Qmax =0.0)
    return ReversibleFlowPipe( name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits)
end

function CheckValvePipe(name::String, connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}, diameter::Float64, length::Float64,
                    roughness::Float64, headloss::Float64, flow::Union{Nothing,Float64}, initial_status:: Int64)
    flow_limits = (Qmin = 0.0, Qmax =0.0)
    return CheckValvePipe(name, connectionpoints, diameter, length, roughness, headloss, flow, initial_status, flow_limits)
end
