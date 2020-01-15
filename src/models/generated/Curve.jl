#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct Curve <: TechnicalParams
        name::String
        type::Union{Nothing, String}
        points::Union{Nothing, Array{Tuple{Float64,Float64},1}}
        internal::InfrastructureSystemsInternal
    end

Pump head or efficiency curve

# Arguments
- `name::String`
- `type::Union{Nothing, String}`: type of curve (head or efficiency)
- `points::Union{Nothing, Array{Tuple{Float64,Float64},1}}`: tuples of the curve points
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct Curve <: TechnicalParams
    name::String
    "type of curve (head or efficiency)"
    type::Union{Nothing, String}
    "tuples of the curve points"
    points::Union{Nothing, Array{Tuple{Float64,Float64},1}}
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function Curve(name, type, points, )
    Curve(name, type, points, InfrastructureSystemsInternal(), )
end

function Curve(; name, type, points, )
    Curve(name, type, points, )
end

# Constructor for demo purposes; non-functional.
function Curve(::Nothing)
    Curve(;
        name="init",
        type=nothing,
        points=nothing,
    )
end

"""Get Curve name."""
get_name(value::Curve) = value.name
"""Get Curve type."""
get_type(value::Curve) = value.type
"""Get Curve points."""
get_points(value::Curve) = value.points
"""Get Curve internal."""
get_internal(value::Curve) = value.internal
