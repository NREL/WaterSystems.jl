#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct Pump <: Link
        name::String
        operating::Bool
        flow::Union{Nothing,Float64}
        headgain::Float64
        available::Bool
        arc::Arc
        pumpparams::PumpParams
        flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        internal::InfrastructureSystemsInternal
    end

Pump, nominally centrifugal and single-speed.

# Arguments
- `name::String`
- `operating::Bool`
- `flow::Union{Nothing,Float64}`
- `headgain::Float64`: Not sure about decoupled headgain when pump is off.
- `available::Bool`
- `arc::Arc`
- `pumpparams::PumpParams`: Pump parameters object, including pump curves
- `flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `internal::InfrastructureSystemsInternal`
"""
mutable struct Pump <: Link
    name::String
    operating::Bool
    flow::Union{Nothing,Float64}
    "Not sure about decoupled headgain when pump is off."
    headgain::Float64
    available::Bool
    arc::Arc
    "Pump parameters object, including pump curves"
    pumpparams::PumpParams
    flowlimits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    internal::InfrastructureSystemsInternal
end

function Pump(name, operating, flow, headgain, available, arc, pumpparams, flowlimits, )
    Pump(name, operating, flow, headgain, available, arc, pumpparams, flowlimits, InfrastructureSystemsInternal())
end

function Pump(; name, operating, flow, headgain, available, arc, pumpparams, flowlimits, )
    Pump(name, operating, flow, headgain, available, arc, pumpparams, flowlimits, )
end

# Constructor for demo purposes; non-functional.

function Pump(::Nothing)
    Pump(;
        name="init",
        operating=true,
        flow=nothing,
        headgain=0.0,
        available=true,
        arc=Arc(Junction(nothing), Junction(nothing)),
        pumpparams=PumpParams(nothing),
        flowlimits=(min=0.0, max=10.0),
    )
end

"""Get Pump name."""
get_name(value::Pump) = value.name
"""Get Pump operating."""
get_operating(value::Pump) = value.operating
"""Get Pump flow."""
get_flow(value::Pump) = value.flow
"""Get Pump headgain."""
get_headgain(value::Pump) = value.headgain
"""Get Pump available."""
get_available(value::Pump) = value.available
"""Get Pump arc."""
get_arc(value::Pump) = value.arc
"""Get Pump pumpparams."""
get_pumpparams(value::Pump) = value.pumpparams
"""Get Pump flowlimits."""
get_flowlimits(value::Pump) = value.flowlimits
"""Get Pump internal."""
get_internal(value::Pump) = value.internal
