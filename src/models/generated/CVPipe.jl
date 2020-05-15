#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct CVPipe <: Pipe
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

A unidirectional-flow pipe that contains a check valve (CV).

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
mutable struct CVPipe <: Pipe
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

function CVPipe(name, arc, available, diameter, length, roughness, flowlimits, flow, headloss, )
    CVPipe(name, arc, available, diameter, length, roughness, flowlimits, flow, headloss, InfrastructureSystemsInternal(), )
end

function CVPipe(; name, arc, available, diameter, length, roughness, flowlimits, flow, headloss, )
    CVPipe(name, arc, available, diameter, length, roughness, flowlimits, flow, headloss, )
end

# Constructor for demo purposes; non-functional.
function CVPipe(::Nothing)
    CVPipe(;
        name="init",
        arc=Arc(nothing),
        available=true,
        diameter=0.0,
        length=0.0,
        roughness=0.0,
        flowlimits=(min=0.0, max=10.0),
        flow=nothing,
        headloss=nothing,
    )
end

"""Get CVPipe name."""
get_name(value::CVPipe) = value.name
"""Get CVPipe arc."""
get_arc(value::CVPipe) = value.arc
"""Get CVPipe available."""
get_available(value::CVPipe) = value.available
"""Get CVPipe diameter."""
get_diameter(value::CVPipe) = value.diameter
"""Get CVPipe length."""
get_length(value::CVPipe) = value.length
"""Get CVPipe roughness."""
get_roughness(value::CVPipe) = value.roughness
"""Get CVPipe flowlimits."""
get_flowlimits(value::CVPipe) = value.flowlimits
"""Get CVPipe flow."""
get_flow(value::CVPipe) = value.flow
"""Get CVPipe headloss."""
get_headloss(value::CVPipe) = value.headloss
"""Get CVPipe internal."""
get_internal(value::CVPipe) = value.internal
