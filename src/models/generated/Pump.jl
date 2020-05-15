#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct Pump <: Link
        name::String
        arc::Arc
        available::Bool
        pumpparams::PumpParams
        flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        operating::Union{Nothing,Bool}
        flow::Union{Nothing,Float64}
        headgain::Union{Nothing,Float64}
        internal::InfrastructureSystemsInternal
    end

Pump, nominally centrifugal and single-speed.

# Arguments
- `name::String`
- `arc::Arc`
- `available::Bool`
- `pumpparams::PumpParams`: Pump parameters object, including pump curves
- `flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `operating::Union{Nothing,Bool}`
- `flow::Union{Nothing,Float64}`
- `headgain::Union{Nothing,Float64}`: Not sure about decoupled headgain when pump is off.
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct Pump <: Link
    name::String
    arc::Arc
    available::Bool
    "Pump parameters object, including pump curves"
    pumpparams::PumpParams
    flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    operating::Union{Nothing,Bool}
    flow::Union{Nothing,Float64}
    "Not sure about decoupled headgain when pump is off."
    headgain::Union{Nothing,Float64}
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function Pump(name, arc, available, pumpparams, flowlimits, operating, flow, headgain, )
    Pump(name, arc, available, pumpparams, flowlimits, operating, flow, headgain, InfrastructureSystemsInternal(), )
end

function Pump(; name, arc, available, pumpparams, flowlimits, operating, flow, headgain, )
    Pump(name, arc, available, pumpparams, flowlimits, operating, flow, headgain, )
end

# Constructor for demo purposes; non-functional.
function Pump(::Nothing)
    Pump(;
        name="init",
        arc=Arc(nothing),
        available=true,
        pumpparams=PumpParams(nothing),
        flowlimits=(min=0.0, max=10.0),
        operating=nothing,
        flow=nothing,
        headgain=nothing,
    )
end

"""Get Pump name."""
get_name(value::Pump) = value.name
"""Get Pump arc."""
get_arc(value::Pump) = value.arc
"""Get Pump available."""
get_available(value::Pump) = value.available
"""Get Pump pumpparams."""
get_pumpparams(value::Pump) = value.pumpparams
"""Get Pump flowlimits."""
get_flowlimits(value::Pump) = value.flowlimits
"""Get Pump operating."""
get_operating(value::Pump) = value.operating
"""Get Pump flow."""
get_flow(value::Pump) = value.flow
"""Get Pump headgain."""
get_headgain(value::Pump) = value.headgain
"""Get Pump internal."""
get_internal(value::Pump) = value.internal
