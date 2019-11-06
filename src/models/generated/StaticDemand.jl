#=
This file is auto-generated. Do not edit.
=#

"""A constant demand."""
mutable struct StaticDemand <: WaterDemand
    name::String
    available::Bool
    junction::Junction
    maxdemand::Float64  # peak demand in m^3/second
    _forecasts::InfrastructureSystems.Forecasts
    internal::InfrastructureSystemsInternal
end

function StaticDemand(name, available, junction, maxdemand, _forecasts=InfrastructureSystems.Forecasts(), )
    StaticDemand(name, available, junction, maxdemand, _forecasts, InfrastructureSystemsInternal())
end

function StaticDemand(; name, available, junction, maxdemand, _forecasts=InfrastructureSystems.Forecasts(), )
    StaticDemand(name, available, junction, maxdemand, _forecasts, )
end

# Constructor for demo purposes; non-functional.

function StaticDemand(::Nothing)
    StaticDemand(;
        name="init",
        available=false,
        junction=Junction(nothing),
        maxdemand=0.0,
        _forecasts=InfrastructureSystems.Forecasts(),
    )
end

"""Get StaticDemand name."""
get_name(value::StaticDemand) = value.name
"""Get StaticDemand available."""
get_available(value::StaticDemand) = value.available
"""Get StaticDemand junction."""
get_junction(value::StaticDemand) = value.junction
"""Get StaticDemand maxdemand."""
get_maxdemand(value::StaticDemand) = value.maxdemand
"""Get StaticDemand _forecasts."""
get__forecasts(value::StaticDemand) = value._forecasts
"""Get StaticDemand internal."""
get_internal(value::StaticDemand) = value.internal
