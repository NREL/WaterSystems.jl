#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct GatePipe <: Pipe
        name::String
        arc::Arc
        available::Bool
        diameter::Float64
        length::Float64
        roughness::Float64
        flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        open_status::Union{Nothing,Bool}
        flow::Union{Nothing,Float64}
        headloss::Union{Nothing,Float64}
        internal::InfrastructureSystemsInternal
    end

A bidirectional-flow pipe with a gate (shutoff) valve.

# Arguments
- `name::String`
- `arc::Arc`
- `available::Bool`
- `diameter::Float64`
- `length::Float64`
- `roughness::Float64`
- `flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `open_status::Union{Nothing,Bool}`
- `flow::Union{Nothing,Float64}`
- `headloss::Union{Nothing,Float64}`
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct GatePipe <: Pipe
    name::String
    arc::Arc
    available::Bool
    diameter::Float64
    length::Float64
    roughness::Float64
    flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    open_status::Union{Nothing,Bool}
    flow::Union{Nothing,Float64}
    headloss::Union{Nothing,Float64}
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function GatePipe(name, arc, available, diameter, length, roughness, flowlimits, open_status, flow, headloss, )
    GatePipe(name, arc, available, diameter, length, roughness, flowlimits, open_status, flow, headloss, InfrastructureSystemsInternal(), )
end

function GatePipe(; name, arc, available, diameter, length, roughness, flowlimits, open_status, flow, headloss, )
    GatePipe(name, arc, available, diameter, length, roughness, flowlimits, open_status, flow, headloss, )
end

# Constructor for demo purposes; non-functional.
function GatePipe(::Nothing)
    GatePipe(;
        name="init",
        arc=Arc(nothing),
        available=true,
        diameter=0.0,
        length=0.0,
        roughness=0.0,
        flowlimits=(min=-10.0, max=10.0),
        open_status=nothing,
        flow=nothing,
        headloss=nothing,
    )
end

"""Get GatePipe name."""
get_name(value::GatePipe) = value.name
"""Get GatePipe arc."""
get_arc(value::GatePipe) = value.arc
"""Get GatePipe available."""
get_available(value::GatePipe) = value.available
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
"""Get GatePipe flow."""
get_flow(value::GatePipe) = value.flow
"""Get GatePipe headloss."""
get_headloss(value::GatePipe) = value.headloss
"""Get GatePipe internal."""
get_internal(value::GatePipe) = value.internal
