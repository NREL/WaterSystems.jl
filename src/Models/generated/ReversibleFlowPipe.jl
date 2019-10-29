#=
This file is auto-generated. Do not edit.
=#


mutable struct ReversibleFlowPipe <: RegularPipe
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

function ReversibleFlowPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
    ReversibleFlowPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, PowerSystemInternal())
end

function ReversibleFlowPipe(; name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
    ReversibleFlowPipe(name, flow, headloss, available, arc, diameter, length, roughness, flowlimits, )
end

# Constructor for demo purposes; non-functional.

function ReversibleFlowPipe(::Nothing)
    ReversibleFlowPipe(;
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

"""Get ReversibleFlowPipe name."""
get_name(value::ReversibleFlowPipe) = value.name
"""Get ReversibleFlowPipe flow."""
get_flow(value::ReversibleFlowPipe) = value.flow
"""Get ReversibleFlowPipe headloss."""
get_headloss(value::ReversibleFlowPipe) = value.headloss
"""Get ReversibleFlowPipe available."""
get_available(value::ReversibleFlowPipe) = value.available
"""Get ReversibleFlowPipe arc."""
get_arc(value::ReversibleFlowPipe) = value.arc
"""Get ReversibleFlowPipe diameter."""
get_diameter(value::ReversibleFlowPipe) = value.diameter
"""Get ReversibleFlowPipe length."""
get_length(value::ReversibleFlowPipe) = value.length
"""Get ReversibleFlowPipe roughness."""
get_roughness(value::ReversibleFlowPipe) = value.roughness
"""Get ReversibleFlowPipe flowlimits."""
get_flowlimits(value::ReversibleFlowPipe) = value.flowlimits
"""Get ReversibleFlowPipe internal."""
get_internal(value::ReversibleFlowPipe) = value.internal
