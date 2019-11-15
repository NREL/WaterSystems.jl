#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct PumpParams <: TechnicalParams
        epnt_type::Union{Nothing, String}
        epnt_power::Union{Nothing, Float64}
        epnt_head::Union{Nothing, Array{Tuple{Float64,Float64},1}}
        epnt_efficiency::Union{Nothing, Float64, Array{Tuple{Float64,Float64},1}}
        flowBEP::Float64
        effncyBEP::Float64
        headBEP::Float64
        head0::Float64
        powerslope::Float64
        powerintcpt::Float64
        internal::InfrastructureSystemsInternal
    end

Pump characteristics, containing both inp-file data and normalized representation for head, efficiency, and power curves. Currently, only single-speed

# Arguments
- `epnt_type::Union{Nothing, String}`: epanet categorizes pump specs as HEAD or POWER
- `epnt_power::Union{Nothing, Float64}`: specified constant power if type POWER
- `epnt_head::Union{Nothing, Array{Tuple{Float64,Float64},1}}`: provided head curve if type HEAD
- `epnt_efficiency::Union{Nothing, Float64, Array{Tuple{Float64,Float64},1}}`: provided efficiency curve (or single value) if type HEAD
- `flowBEP::Float64`: flow rate at the best efficiency point
- `effncyBEP::Float64`: efficiency at the best efficiency point
- `headBEP::Float64`: head at the best efficiency point
- `head0::Float64`: head ratio G0/GBEP
- `powerslope::Float64`: slope of the linear power curve
- `powerintcpt::Float64`: inetercept of the linear power curve
- `internal::InfrastructureSystemsInternal`
"""
mutable struct PumpParams <: TechnicalParams
    "epanet categorizes pump specs as HEAD or POWER"
    epnt_type::Union{Nothing, String}
    "specified constant power if type POWER"
    epnt_power::Union{Nothing, Float64}
    "provided head curve if type HEAD"
    epnt_head::Union{Nothing, Array{Tuple{Float64,Float64},1}}
    "provided efficiency curve (or single value) if type HEAD"
    epnt_efficiency::Union{Nothing, Float64, Array{Tuple{Float64,Float64},1}}
    "flow rate at the best efficiency point"
    flowBEP::Float64
    "efficiency at the best efficiency point"
    effncyBEP::Float64
    "head at the best efficiency point"
    headBEP::Float64
    "head ratio G0/GBEP"
    head0::Float64
    "slope of the linear power curve"
    powerslope::Float64
    "inetercept of the linear power curve"
    powerintcpt::Float64
    internal::InfrastructureSystemsInternal
end

function PumpParams(epnt_type, epnt_power, epnt_head, epnt_efficiency, flowBEP, effncyBEP, headBEP, head0, powerslope, powerintcpt, )
    PumpParams(epnt_type, epnt_power, epnt_head, epnt_efficiency, flowBEP, effncyBEP, headBEP, head0, powerslope, powerintcpt, InfrastructureSystemsInternal())
end

function PumpParams(; epnt_type, epnt_power, epnt_head, epnt_efficiency, flowBEP, effncyBEP, headBEP, head0, powerslope, powerintcpt, )
    PumpParams(epnt_type, epnt_power, epnt_head, epnt_efficiency, flowBEP, effncyBEP, headBEP, head0, powerslope, powerintcpt, )
end

# Constructor for demo purposes; non-functional.

function PumpParams(::Nothing)
    PumpParams(;
        epnt_type=nothing,
        epnt_power=nothing,
        epnt_head=nothing,
        epnt_efficiency=nothing,
        flowBEP=0.0,
        effncyBEP=0.0,
        headBEP=0.0,
        head0=1.25,
        powerslope=0.0,
        powerintcpt=0.0,
    )
end

"""Get PumpParams epnt_type."""
get_epnt_type(value::PumpParams) = value.epnt_type
"""Get PumpParams epnt_power."""
get_epnt_power(value::PumpParams) = value.epnt_power
"""Get PumpParams epnt_head."""
get_epnt_head(value::PumpParams) = value.epnt_head
"""Get PumpParams epnt_efficiency."""
get_epnt_efficiency(value::PumpParams) = value.epnt_efficiency
"""Get PumpParams flowBEP."""
get_flowBEP(value::PumpParams) = value.flowBEP
"""Get PumpParams effncyBEP."""
get_effncyBEP(value::PumpParams) = value.effncyBEP
"""Get PumpParams headBEP."""
get_headBEP(value::PumpParams) = value.headBEP
"""Get PumpParams head0."""
get_head0(value::PumpParams) = value.head0
"""Get PumpParams powerslope."""
get_powerslope(value::PumpParams) = value.powerslope
"""Get PumpParams powerintcpt."""
get_powerintcpt(value::PumpParams) = value.powerintcpt
"""Get PumpParams internal."""
get_internal(value::PumpParams) = value.internal
