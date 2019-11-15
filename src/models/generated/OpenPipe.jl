#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct OpenPipe <: Pipe
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

An always open, bidirectional-flow pipe.

# Arguments
- `name::String`
- `flow::Union{Nothing,Float64}`
- `headloss::Float64`
- `available::Bool`
- `arc::Arc`
- `diameter::Float64`
- `length::Float64`
- `roughness::Float64`
- `flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `internal::InfrastructureSystemsInternal`
"""
mutable struct OpenPipe <: Pipe
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

function OpenPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
    OpenPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, InfrastructureSystemsInternal())
end

function OpenPipe(; name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
    OpenPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
end

# Constructor for demo purposes; non-functional.

function OpenPipe(::Nothing)
    OpenPipe(;
        name="init",
        flow=nothing,
        headloss=0.0,
        available=true,
        arc=Arc(Junction(nothing), Junction(nothing)),
        diameter=0.0,
        length=0.0,
        roughness=0.0,
        flowlimits=(min=-10.0, max=10.0),
    )
end

"""Get OpenPipe name."""
get_name(value::OpenPipe) = value.name
"""Get OpenPipe flow."""
get_flow(value::OpenPipe) = value.flow
"""Get OpenPipe headloss."""
get_headloss(value::OpenPipe) = value.headloss
"""Get OpenPipe available."""
get_available(value::OpenPipe) = value.available
"""Get OpenPipe arc."""
get_arc(value::OpenPipe) = value.arc
"""Get OpenPipe diameter."""
get_diameter(value::OpenPipe) = value.diameter
"""Get OpenPipe length."""
get_length(value::OpenPipe) = value.length
"""Get OpenPipe roughness."""
get_roughness(value::OpenPipe) = value.roughness
"""Get OpenPipe flowlimits."""
get_flowlimits(value::OpenPipe) = value.flowlimits
"""Get OpenPipe internal."""
get_internal(value::OpenPipe) = value.internal
