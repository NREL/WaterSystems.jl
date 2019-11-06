#=
This file is auto-generated. Do not edit.
=#

"""An infinite reservoir-type water source."""
mutable struct Reservoir <: Injection
    name::String
    available::Bool
    junction::Junction
    internal::InfrastructureSystemsInternal
end

function Reservoir(name, available, junction, )
    Reservoir(name, available, junction, InfrastructureSystemsInternal())
end

function Reservoir(; name, available, junction, )
    Reservoir(name, available, junction, )
end

# Constructor for demo purposes; non-functional.

function Reservoir(::Nothing)
    Reservoir(;
        name="init",
        available=false,
        junction=Junction(nothing),
    )
end

"""Get Reservoir name."""
get_name(value::Reservoir) = value.name
"""Get Reservoir available."""
get_available(value::Reservoir) = value.available
"""Get Reservoir junction."""
get_junction(value::Reservoir) = value.junction
"""Get Reservoir internal."""
get_internal(value::Reservoir) = value.internal
