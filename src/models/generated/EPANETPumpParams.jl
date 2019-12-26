#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct EPANETPumpParams <: TechnicalParams
        epnt_type::Union{Nothing, String}
        epnt_power::Union{Nothing, Float64}
        epnt_head::Union{Nothing, Curve}
        epnt_efficiency::Union{Nothing, Float64, Curve}
        internal::InfrastructureSystemsInternal
    end

Pump specifications from inp-file

# Arguments
- `epnt_type::Union{Nothing, String}`: epanet categorizes pump specs as HEAD or POWER
- `epnt_power::Union{Nothing, Float64}`: specified constant power if type POWER
- `epnt_head::Union{Nothing, Curve}`: provided head curve if type HEAD
- `epnt_efficiency::Union{Nothing, Float64, Curve}`: provided efficiency curve (or single value) if type HEAD
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct EPANETPumpParams <: TechnicalParams
    "epanet categorizes pump specs as HEAD or POWER"
    epnt_type::Union{Nothing, String}
    "specified constant power if type POWER"
    epnt_power::Union{Nothing, Float64}
    "provided head curve if type HEAD"
    epnt_head::Union{Nothing, Curve}
    "provided efficiency curve (or single value) if type HEAD"
    epnt_efficiency::Union{Nothing, Float64, Curve}
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function EPANETPumpParams(epnt_type, epnt_power, epnt_head, epnt_efficiency, )
    EPANETPumpParams(epnt_type, epnt_power, epnt_head, epnt_efficiency, InfrastructureSystemsInternal(), )
end

function EPANETPumpParams(; epnt_type, epnt_power, epnt_head, epnt_efficiency, )
    EPANETPumpParams(epnt_type, epnt_power, epnt_head, epnt_efficiency, )
end

# Constructor for demo purposes; non-functional.
function EPANETPumpParams(::Nothing)
    EPANETPumpParams(;
        epnt_type=nothing,
        epnt_power=nothing,
        epnt_head=nothing,
        epnt_efficiency=nothing,
    )
end

"""Get EPANETPumpParams epnt_type."""
get_epnt_type(value::EPANETPumpParams) = value.epnt_type
"""Get EPANETPumpParams epnt_power."""
get_epnt_power(value::EPANETPumpParams) = value.epnt_power
"""Get EPANETPumpParams epnt_head."""
get_epnt_head(value::EPANETPumpParams) = value.epnt_head
"""Get EPANETPumpParams epnt_efficiency."""
get_epnt_efficiency(value::EPANETPumpParams) = value.epnt_efficiency
"""Get EPANETPumpParams internal."""
get_internal(value::EPANETPumpParams) = value.internal
