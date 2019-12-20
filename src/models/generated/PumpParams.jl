#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct PumpParams <: TechnicalParams
        epnt_data::Union{Nothing, EPANETPumpParams}
        norm_coefs::Union{Nothing, NormPumpParams}
        internal::InfrastructureSystemsInternal
    end

Pump characteristics, containing both inp-file data and coefficients for a normalized representation. Currently, only single-speed

# Arguments
- `epnt_data::Union{Nothing, EPANETPumpParams}`: Pump specifications from inp-file
- `norm_coefs::Union{Nothing, NormPumpParams}`: Coefficients that characterize pumps with a normalized representation of head, efficiency, and power. Currently only single-speed
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct PumpParams <: TechnicalParams
    "Pump specifications from inp-file"
    epnt_data::Union{Nothing, EPANETPumpParams}
    "Coefficients that characterize pumps with a normalized representation of head, efficiency, and power. Currently only single-speed"
    norm_coefs::Union{Nothing, NormPumpParams}
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function PumpParams(epnt_data, norm_coefs, )
    PumpParams(epnt_data, norm_coefs, InfrastructureSystemsInternal(), )
end

function PumpParams(; epnt_data, norm_coefs, )
    PumpParams(epnt_data, norm_coefs, )
end

# Constructor for demo purposes; non-functional.
function PumpParams(::Nothing)
    PumpParams(;
        epnt_data=nothing,
        norm_coefs=nothing,
    )
end

"""Get PumpParams epnt_data."""
get_epnt_data(value::PumpParams) = value.epnt_data
"""Get PumpParams norm_coefs."""
get_norm_coefs(value::PumpParams) = value.norm_coefs
"""Get PumpParams internal."""
get_internal(value::PumpParams) = value.internal
