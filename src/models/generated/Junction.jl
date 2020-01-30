#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct Junction <: Topology
        name::String
        elevation::Float64
        head::Union{Nothing, Float64}
        coordinates::Union{Nothing, NamedTuple{(:lat, :lon),Tuple{Float64,Float64}}}
        pattern_name::Union{Nothing, String}
        _forecasts::InfrastructureSystems.Forecasts
        internal::InfrastructureSystemsInternal
    end

A water-system Junction.

# Arguments
- `name::String`: the name of the junction
- `elevation::Float64`: elevation of junction
- `head::Union{Nothing, Float64}`: pressure head at junction
- `coordinates::Union{Nothing, NamedTuple{(:lat, :lon),Tuple{Float64,Float64}}}`: latitude and longitude coordinates of junction
- `pattern_name::Union{Nothing, String}`: name of head pattern array, for reservoirs only
- `_forecasts::InfrastructureSystems.Forecasts`
- `internal::InfrastructureSystemsInternal`: internal reference, do not modify
"""
mutable struct Junction <: Topology
    "the name of the junction"
    name::String
    "elevation of junction"
    elevation::Float64
    "pressure head at junction"
    head::Union{Nothing, Float64}
    "latitude and longitude coordinates of junction"
    coordinates::Union{Nothing, NamedTuple{(:lat, :lon),Tuple{Float64,Float64}}}
    "name of head pattern array, for reservoirs only"
    pattern_name::Union{Nothing, String}
    _forecasts::InfrastructureSystems.Forecasts
    "internal reference, do not modify"
    internal::InfrastructureSystemsInternal
end

function Junction(name, elevation, head, coordinates, pattern_name, _forecasts=InfrastructureSystems.Forecasts(), )
    Junction(name, elevation, head, coordinates, pattern_name, _forecasts, InfrastructureSystemsInternal(), )
end

function Junction(; name, elevation, head, coordinates, pattern_name, _forecasts=InfrastructureSystems.Forecasts(), )
    Junction(name, elevation, head, coordinates, pattern_name, _forecasts, )
end

# Constructor for demo purposes; non-functional.
function Junction(::Nothing)
    Junction(;
        name="init",
        elevation=0.0,
        head=nothing,
        coordinates=nothing,
        pattern_name=nothing,
        _forecasts=InfrastructureSystems.Forecasts(),
    )
end

"""Get Junction name."""
get_name(value::Junction) = value.name
"""Get Junction elevation."""
get_elevation(value::Junction) = value.elevation
"""Get Junction head."""
get_head(value::Junction) = value.head
"""Get Junction coordinates."""
get_coordinates(value::Junction) = value.coordinates
"""Get Junction pattern_name."""
get_pattern_name(value::Junction) = value.pattern_name
"""Get Junction _forecasts."""
get__forecasts(value::Junction) = value._forecasts
"""Get Junction internal."""
get_internal(value::Junction) = value.internal
