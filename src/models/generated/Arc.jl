#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct Arc <: Topology
        name::String
        from::Junction
        to::Junction
        internal::InfrastructureSystemsInternal
    end

A topological Arc.

# Arguments
- `name::String`: the name of the arc
- `from::Junction`
- `to::Junction`
- `internal::InfrastructureSystemsInternal`
"""
mutable struct Arc <: Topology
    "the name of the arc"
    name::String
    from::Junction
    to::Junction
    internal::InfrastructureSystemsInternal
end

function Arc(name, from, to, )
    Arc(name, from, to, InfrastructureSystemsInternal())
end

function Arc(; name, from, to, )
    Arc(name, from, to, )
end


"""Get Arc name."""
get_name(value::Arc) = value.name
"""Get Arc from."""
get_from(value::Arc) = value.from
"""Get Arc to."""
get_to(value::Arc) = value.to
"""Get Arc internal."""
get_internal(value::Arc) = value.internal
