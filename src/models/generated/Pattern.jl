#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct Pattern <: TechnicalParams
        name::String
        values::Union{Nothing, Vector{Float64}}
        internal::InfrastructureSystemsInternal
    end

Forecast pattern.

# Arguments
- `name::String`
- `values::Union{Nothing, Vector{Float64}}`: Multiplier values of the pattern.
- `internal::InfrastructureSystemsInternal`
"""
mutable struct Pattern <: TechnicalParams
    name::String
    "Multiplier values of the pattern."
    values::Union{Nothing, Vector{Float64}}
    internal::InfrastructureSystemsInternal
end

function Pattern(name, values, )
    Pattern(name, values, InfrastructureSystemsInternal())
end

function Pattern(; name, values, )
    Pattern(name, values, )
end

# Constructor for demo purposes; non-functional.

function Pattern(::Nothing)
    Pattern(;
        name="init",
        values=nothing,
    )
end

"""Get Pattern name."""
get_name(value::Pattern) = value.name
"""Get Pattern values."""
get_values(value::Pattern) = value.values
"""Get Pattern internal."""
get_internal(value::Pattern) = value.internal
