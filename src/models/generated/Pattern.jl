#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct Pattern <: TechnicalParams
        name::String
        multipliers::Union{Nothing, Vector{Float64}}
        internal::InfrastructureSystemsInternal
    end

Forecast pattern.

# Arguments
- `name::String`
- `multipliers::Union{Nothing, Vector{Float64}}`: Multiplier values of the pattern.
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct Pattern <: TechnicalParams
    name::String
    "Multiplier values of the pattern."
    multipliers::Union{Nothing, Vector{Float64}}
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function Pattern(name, multipliers, )
    Pattern(name, multipliers, InfrastructureSystemsInternal(), )
end

function Pattern(; name, multipliers, )
    Pattern(name, multipliers, )
end

# Constructor for demo purposes; non-functional.
function Pattern(::Nothing)
    Pattern(;
        name="init",
        multipliers=nothing,
    )
end

"""Get Pattern name."""
get_name(value::Pattern) = value.name
"""Get Pattern multipliers."""
get_multipliers(value::Pattern) = value.multipliers
"""Get Pattern internal."""
get_internal(value::Pattern) = value.internal
