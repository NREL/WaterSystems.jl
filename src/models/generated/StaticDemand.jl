#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct StaticDemand <: WaterDemand
        name::String
        available::Bool
        junction::Junction
        base_demand::Float64
        pattern_name::String
        _forecasts::InfrastructureSystems.Forecasts
        internal::InfrastructureSystemsInternal
    end

Temporal demand at a junction that is fixed.

# Arguments
- `name::String`
- `available::Bool`
- `junction::Junction`
- `base_demand::Float64`: 'base' demand in m^3/second
- `pattern_name::String`: name of forecast pattern array
- `_forecasts::InfrastructureSystems.Forecasts`
- `internal::InfrastructureSystemsInternal`
"""
mutable struct StaticDemand <: WaterDemand
    name::String
    available::Bool
    junction::Junction
    "'base' demand in m^3/second"
    base_demand::Float64
    "name of forecast pattern array"
    pattern_name::String
    _forecasts::InfrastructureSystems.Forecasts
    internal::InfrastructureSystemsInternal
end

function StaticDemand(name, available, junction, base_demand, pattern_name, _forecasts=InfrastructureSystems.Forecasts(), )
    StaticDemand(name, available, junction, base_demand, pattern_name, _forecasts, InfrastructureSystemsInternal())
end

function StaticDemand(; name, available, junction, base_demand, pattern_name, _forecasts=InfrastructureSystems.Forecasts(), )
    StaticDemand(name, available, junction, base_demand, pattern_name, _forecasts, )
end

# Constructor for demo purposes; non-functional.

function StaticDemand(::Nothing)
    StaticDemand(;
        name="init",
        available=true,
        junction=Junction(nothing),
        base_demand=0.0,
        pattern_name="init",
        _forecasts=InfrastructureSystems.Forecasts(),
    )
end

"""Get StaticDemand name."""
get_name(value::StaticDemand) = value.name
"""Get StaticDemand available."""
get_available(value::StaticDemand) = value.available
"""Get StaticDemand junction."""
get_junction(value::StaticDemand) = value.junction
"""Get StaticDemand base_demand."""
get_base_demand(value::StaticDemand) = value.base_demand
"""Get StaticDemand pattern_name."""
get_pattern_name(value::StaticDemand) = value.pattern_name
"""Get StaticDemand _forecasts."""
get__forecasts(value::StaticDemand) = value._forecasts
"""Get StaticDemand internal."""
get_internal(value::StaticDemand) = value.internal
