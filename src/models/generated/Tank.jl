#=
This file is auto-generated. Do not edit.
=#

"""A water tank. Currently cylindrical only."""
mutable struct Tank <: Injection
    name::String
    available::Bool
    junction::Junction
    diameter::Float64  # constant diameter in m
    level::Union{Nothing,Float64}  # water level in m
    level_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    internal::InfrastructureSystemsInternal
end

function Tank(name, available, junction, diameter, level, level_limits, )
    Tank(name, available, junction, diameter, level, level_limits, InfrastructureSystemsInternal())
end

function Tank(; name, available, junction, diameter, level, level_limits, )
    Tank(name, available, junction, diameter, level, level_limits, )
end

# Constructor for demo purposes; non-functional.

function Tank(::Nothing)
    Tank(;
        name="init",
        available=false,
        junction=Junction(nothing),
        diameter=0,
        level=nothing,
        level_limits=(min=0.0, max=1000.0),
    )
end

"""Get Tank name."""
get_name(value::Tank) = value.name
"""Get Tank available."""
get_available(value::Tank) = value.available
"""Get Tank junction."""
get_junction(value::Tank) = value.junction
"""Get Tank diameter."""
get_diameter(value::Tank) = value.diameter
"""Get Tank level."""
get_level(value::Tank) = value.level
"""Get Tank level_limits."""
get_level_limits(value::Tank) = value.level_limits
"""Get Tank internal."""
get_internal(value::Tank) = value.internal
