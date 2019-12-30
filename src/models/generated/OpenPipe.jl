#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct OpenPipe <: Pipe
        name::String
        arc::Arc
        available::Bool
        diameter::Float64
        length::Float64
        roughness::Float64
        flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        flow::Union{Nothing,Float64}
        headloss::Union{Nothing,Float64}
        internal::InfrastructureSystemsInternal
    end

An always open, bidirectional-flow pipe.

# Arguments
- `name::String`
- `arc::Arc`
- `available::Bool`
- `diameter::Float64`
- `length::Float64`
- `roughness::Float64`
- `flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `flow::Union{Nothing,Float64}`
- `headloss::Union{Nothing,Float64}`
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct OpenPipe <: Pipe
    name::String
    arc::Arc
    available::Bool
    diameter::Float64
    length::Float64
    roughness::Float64
    flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    flow::Union{Nothing,Float64}
    headloss::Union{Nothing,Float64}
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function OpenPipe(name, arc, available, diameter, length, roughness, flowlimits, flow, headloss, )
    OpenPipe(name, arc, available, diameter, length, roughness, flowlimits, flow, headloss, InfrastructureSystemsInternal(), )
end

function OpenPipe(; name, arc, available, diameter, length, roughness, flowlimits, flow, headloss, )
    OpenPipe(name, arc, available, diameter, length, roughness, flowlimits, flow, headloss, )
end

# Constructor for demo purposes; non-functional.
function OpenPipe(::Nothing)
    OpenPipe(;
        name="init",
        arc=Arc(nothing),
        available=true,
        diameter=0.0,
        length=0.0,
        roughness=0.0,
        flowlimits=(min=-10.0, max=10.0),
        flow=nothing,
        headloss=nothing,
    )
end

"""Get OpenPipe name."""
get_name(value::OpenPipe) = value.name
"""Get OpenPipe arc."""
get_arc(value::OpenPipe) = value.arc
"""Get OpenPipe available."""
get_available(value::OpenPipe) = value.available
"""Get OpenPipe diameter."""
get_diameter(value::OpenPipe) = value.diameter
"""Get OpenPipe length."""
get_length(value::OpenPipe) = value.length
"""Get OpenPipe roughness."""
get_roughness(value::OpenPipe) = value.roughness
"""Get OpenPipe flowlimits."""
get_flowlimits(value::OpenPipe) = value.flowlimits
"""Get OpenPipe flow."""
get_flow(value::OpenPipe) = value.flow
"""Get OpenPipe headloss."""
get_headloss(value::OpenPipe) = value.headloss
"""Get OpenPipe internal."""
get_internal(value::OpenPipe) = value.internal
