#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct CylindricalTank <: Tank
        name::String
        available::Bool
        junction::Junction
        diameter::Float64
        level::Union{Nothing,Float64}
        level_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        internal::InfrastructureSystemsInternal
    end

A cylindrical water tank. Currently the only supproted tank type.

# Arguments
- `name::String`
- `available::Bool`
- `junction::Junction`
- `diameter::Float64`: constant diameter in m
- `level::Union{Nothing,Float64}`: water level in m
- `level_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `internal::InfrastructureSystemsInternal`
"""
mutable struct CylindricalTank <: Tank
    name::String
    available::Bool
    junction::Junction
    "constant diameter in m"
    diameter::Float64
    "water level in m"
    level::Union{Nothing,Float64}
    level_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    internal::InfrastructureSystemsInternal
end

function CylindricalTank(name, available, junction, diameter, level, level_limits, )
    CylindricalTank(name, available, junction, diameter, level, level_limits, InfrastructureSystemsInternal())
end

function CylindricalTank(; name, available, junction, diameter, level, level_limits, )
    CylindricalTank(name, available, junction, diameter, level, level_limits, )
end

# Constructor for demo purposes; non-functional.

function CylindricalTank(::Nothing)
    CylindricalTank(;
        name="init",
        available=true,
        junction=Junction(nothing),
        diameter=0,
        level=nothing,
        level_limits=(min=0.0, max=1000.0),
    )
end

"""Get CylindricalTank name."""
get_name(value::CylindricalTank) = value.name
"""Get CylindricalTank available."""
get_available(value::CylindricalTank) = value.available
"""Get CylindricalTank junction."""
get_junction(value::CylindricalTank) = value.junction
"""Get CylindricalTank diameter."""
get_diameter(value::CylindricalTank) = value.diameter
"""Get CylindricalTank level."""
get_level(value::CylindricalTank) = value.level
"""Get CylindricalTank level_limits."""
get_level_limits(value::CylindricalTank) = value.level_limits
"""Get CylindricalTank internal."""
get_internal(value::CylindricalTank) = value.internal
