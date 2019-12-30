#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct PumpParams <: TechnicalParams
        epnt_data::Union{Nothing, EPANETPumpParams}
        norm_coefs::Union{Nothing, NormPumpParams}
        base_price::Float64
        pattern_name::String
        _forecasts::InfrastructureSystems.Forecasts
        internal::InfrastructureSystemsInternal
    end

Pump characteristics, containing both inp-file data and coefficients for a normalized representation. Currently, only single-speed

# Arguments
- `epnt_data::Union{Nothing, EPANETPumpParams}`: Pump specifications from inp-file
- `norm_coefs::Union{Nothing, NormPumpParams}`: Coefficients that characterize pumps with a normalized representation of head, efficiency, and power. Currently only single-speed
- `base_price::Float64`: 'base' price in dollar/J
- `pattern_name::String`: name of forecast pattern array
- `_forecasts::InfrastructureSystems.Forecasts`
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct PumpParams <: TechnicalParams
    "Pump specifications from inp-file"
    epnt_data::Union{Nothing, EPANETPumpParams}
    "Coefficients that characterize pumps with a normalized representation of head, efficiency, and power. Currently only single-speed"
    norm_coefs::Union{Nothing, NormPumpParams}
    "'base' price in dollar/J"
    base_price::Float64
    "name of forecast pattern array"
    pattern_name::String
    _forecasts::InfrastructureSystems.Forecasts
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function PumpParams(epnt_data, norm_coefs, base_price, pattern_name, _forecasts=InfrastructureSystems.Forecasts(), )
    PumpParams(epnt_data, norm_coefs, base_price, pattern_name, _forecasts, InfrastructureSystemsInternal(), )
end

function PumpParams(; epnt_data, norm_coefs, base_price, pattern_name, _forecasts=InfrastructureSystems.Forecasts(), )
    PumpParams(epnt_data, norm_coefs, base_price, pattern_name, _forecasts, )
end

# Constructor for demo purposes; non-functional.
function PumpParams(::Nothing)
    PumpParams(;
        epnt_data=nothing,
        norm_coefs=nothing,
        base_price=0.0,
        pattern_name="init",
        _forecasts=InfrastructureSystems.Forecasts(),
    )
end

"""Get PumpParams epnt_data."""
get_epnt_data(value::PumpParams) = value.epnt_data
"""Get PumpParams norm_coefs."""
get_norm_coefs(value::PumpParams) = value.norm_coefs
"""Get PumpParams base_price."""
get_base_price(value::PumpParams) = value.base_price
"""Get PumpParams pattern_name."""
get_pattern_name(value::PumpParams) = value.pattern_name
"""Get PumpParams _forecasts."""
get__forecasts(value::PumpParams) = value._forecasts
"""Get PumpParams internal."""
get_internal(value::PumpParams) = value.internal
