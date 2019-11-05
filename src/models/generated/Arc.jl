#=
This file is auto-generated. Do not edit.
=#

"""A topological Arc."""
mutable struct Arc <: Topology
    from::Junction
    to::Junction
    internal::InfrastructureSystemsInternal
end

function Arc(from, to, )
    Arc(from, to, WaterSystemInternal())
end

function Arc(; from, to, )
    Arc(from, to, )
end


"""Get Arc from."""
get_from(value::Arc) = value.from
"""Get Arc to."""
get_to(value::Arc) = value.to
"""Get Arc internal."""
get_internal(value::Arc) = value.internal
