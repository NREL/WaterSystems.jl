#=
This file is auto-generated. Do not edit.
=#

"""A water-system Junction."""
mutable struct Junction <: Topology
    name::String  # the name of the junction
    elevation::Float64  # elevation of bus
    head::Union{Nothing, Float64}  # pressure head at junction
    minimum_pressure::Float64  # minimum pressure head at the junction
    coordinates::Union{Nothing, Float64}  # latitude and longitude coordinates of junction
    internal::InfrastructureSystemsInternal
end

function Junction(name, elevation, head, minimum_pressure, coordinates, )
    Junction(name, elevation, head, minimum_pressure, coordinates, PowerSystemInternal())
end

function Junction(; name, elevation, head, minimum_pressure, coordinates, )
    Junction(name, elevation, head, minimum_pressure, coordinates, )
end

# Constructor for demo purposes; non-functional.

function Junction(::Nothing)
    Junction(;
        name="init",
        elevation=0.0,
        head=nothing,
        minimum_pressure=0.0,
        coordinates=nothing,
    )
end

"""Get Junction name."""
get_name(value::Junction) = value.name
"""Get Junction elevation."""
get_elevation(value::Junction) = value.elevation
"""Get Junction head."""
get_head(value::Junction) = value.head
"""Get Junction minimum_pressure."""
get_minimum_pressure(value::Junction) = value.minimum_pressure
"""Get Junction coordinates."""
get_coordinates(value::Junction) = value.coordinates
"""Get Junction internal."""
get_internal(value::Junction) = value.internal
