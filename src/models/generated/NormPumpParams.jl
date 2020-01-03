#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct NormPumpParams <: TechnicalParams
        flow_bep::Float64
        effncy_bep::Float64
        head_bep::Float64
        power_slope::Float64
        power_intcpt::Float64
        internal::InfrastructureSystemsInternal
    end

Coefficients that characterize pumps with a normalized representation of head, efficiency, and power. Currently only single-speed

# Arguments
- `flow_bep::Float64`: flow rate at the best efficiency point
- `effncy_bep::Float64`: efficiency at the best efficiency point
- `head_bep::Float64`: head at the best efficiency point
- `power_slope::Float64`: slope of the linear power curve
- `power_intcpt::Float64`: inetercept of the linear power curve
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct NormPumpParams <: TechnicalParams
    "flow rate at the best efficiency point"
    flow_bep::Float64
    "efficiency at the best efficiency point"
    effncy_bep::Float64
    "head at the best efficiency point"
    head_bep::Float64
    "slope of the linear power curve"
    power_slope::Float64
    "inetercept of the linear power curve"
    power_intcpt::Float64
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function NormPumpParams(flow_bep, effncy_bep, head_bep, power_slope, power_intcpt, )
    NormPumpParams(flow_bep, effncy_bep, head_bep, power_slope, power_intcpt, InfrastructureSystemsInternal(), )
end

function NormPumpParams(; flow_bep, effncy_bep, head_bep, power_slope, power_intcpt, )
    NormPumpParams(flow_bep, effncy_bep, head_bep, power_slope, power_intcpt, )
end

# Constructor for demo purposes; non-functional.
function NormPumpParams(::Nothing)
    NormPumpParams(;
        flow_bep=0.0,
        effncy_bep=0.0,
        head_bep=0.0,
        power_slope=0.0,
        power_intcpt=0.0,
    )
end

"""Get NormPumpParams flow_bep."""
get_flow_bep(value::NormPumpParams) = value.flow_bep
"""Get NormPumpParams effncy_bep."""
get_effncy_bep(value::NormPumpParams) = value.effncy_bep
"""Get NormPumpParams head_bep."""
get_head_bep(value::NormPumpParams) = value.head_bep
"""Get NormPumpParams power_slope."""
get_power_slope(value::NormPumpParams) = value.power_slope
"""Get NormPumpParams power_intcpt."""
get_power_intcpt(value::NormPumpParams) = value.power_intcpt
"""Get NormPumpParams internal."""
get_internal(value::NormPumpParams) = value.internal
