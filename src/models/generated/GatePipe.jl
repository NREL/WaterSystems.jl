#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct GatePipe <: Pipe
        name::String
        flow::Union{Nothing,Float64}
        headloss::Float64
        available::Bool
        arc::Arc
        diameter::Float64
        length::Float64
        roughness::Float64
        flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        open_status::Bool
        internal::InfrastructureSystemsInternal
    end

A bidirectional-flow pipe with a gate (shutoff) valve.

# Arguments
- `name::String`
- `flow::Union{Nothing,Float64}`
- `headloss::Float64`: Not sure about decoupled headloss when pipe is closed.
- `available::Bool`
- `arc::Arc`
- `diameter::Float64`
- `length::Float64`
- `roughness::Float64`
- `flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `open_status::Bool`
- `internal::InfrastructureSystemsInternal`
"""
mutable struct GatePipe <: Pipe
    name::String
    flow::Union{Nothing,Float64}
    "Not sure about decoupled headloss when pipe is closed."
    headloss::Float64
    available::Bool
    arc::Arc
    diameter::Float64
    length::Float64
    roughness::Float64
    flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    open_status::Bool
    internal::InfrastructureSystemsInternal
end

function GatePipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, open_status, )
    GatePipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, open_status, InfrastructureSystemsInternal())
end

function GatePipe(; name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, open_status, )
    GatePipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, open_status, )
end

# Constructor for demo purposes; non-functional.

function GatePipe(::Nothing)
    GatePipe(;
        name="init",
        flow=nothing,
        headloss=0.0,
        available=true,
        arc=Arc(Junction(nothing), Junction(nothing)),
        diameter=0.0,
        length=0.0,
        roughness=0.0,
        flowlimits=(min=-10.0, max=10.0),
        open_status=true,
    )
end

"""Get GatePipe name."""
get_name(value::GatePipe) = value.name
"""Get GatePipe flow."""
get_flow(value::GatePipe) = value.flow
"""Get GatePipe headloss."""
get_headloss(value::GatePipe) = value.headloss
"""Get GatePipe available."""
get_available(value::GatePipe) = value.available
"""Get GatePipe arc."""
get_arc(value::GatePipe) = value.arc
"""Get GatePipe diameter."""
get_diameter(value::GatePipe) = value.diameter
"""Get GatePipe length."""
get_length(value::GatePipe) = value.length
"""Get GatePipe roughness."""
get_roughness(value::GatePipe) = value.roughness
"""Get GatePipe flowlimits."""
get_flowlimits(value::GatePipe) = value.flowlimits
"""Get GatePipe open_status."""
get_open_status(value::GatePipe) = value.open_status
"""Get GatePipe internal."""
get_internal(value::GatePipe) = value.internal
