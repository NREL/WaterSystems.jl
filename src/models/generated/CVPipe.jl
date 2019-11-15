#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct CVPipe <: Pipe
        name::String
        flow::Union{Nothing,Float64}
        headloss::Float64
        available::Bool
        arc::Arc
        diameter::Float64
        length::Float64
        roughness::Float64
        flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        internal::InfrastructureSystemsInternal
    end

A unidirectional-flow pipe that contains a check valve (CV).

# Arguments
- `name::String`
- `flow::Union{Nothing,Float64}`
- `headloss::Float64`: Not sure about decoupled headloss when flow is zero.
- `available::Bool`
- `arc::Arc`
- `diameter::Float64`
- `length::Float64`
- `roughness::Float64`
- `flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `internal::InfrastructureSystemsInternal`
"""
mutable struct CVPipe <: Pipe
    name::String
    flow::Union{Nothing,Float64}
    "Not sure about decoupled headloss when flow is zero."
    headloss::Float64
    available::Bool
    arc::Arc
    diameter::Float64
    length::Float64
    roughness::Float64
    flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    internal::InfrastructureSystemsInternal
end

function CVPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
    CVPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, InfrastructureSystemsInternal())
end

function CVPipe(; name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
    CVPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
end

# Constructor for demo purposes; non-functional.

function CVPipe(::Nothing)
    CVPipe(;
        name="init",
        flow=nothing,
        headloss=0.0,
        available=true,
        arc=Arc(Junction(nothing), Junction(nothing)),
        diameter=0.0,
        length=0.0,
        roughness=0.0,
        flowlimits=(min=0.0, max=10.0),
    )
end

"""Get CVPipe name."""
get_name(value::CVPipe) = value.name
"""Get CVPipe flow."""
get_flow(value::CVPipe) = value.flow
"""Get CVPipe headloss."""
get_headloss(value::CVPipe) = value.headloss
"""Get CVPipe available."""
get_available(value::CVPipe) = value.available
"""Get CVPipe arc."""
get_arc(value::CVPipe) = value.arc
"""Get CVPipe diameter."""
get_diameter(value::CVPipe) = value.diameter
"""Get CVPipe length."""
get_length(value::CVPipe) = value.length
"""Get CVPipe roughness."""
get_roughness(value::CVPipe) = value.roughness
"""Get CVPipe flowlimits."""
get_flowlimits(value::CVPipe) = value.flowlimits
"""Get CVPipe internal."""
get_internal(value::CVPipe) = value.internal
