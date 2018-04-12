export Storage
export Tank 
export Reservoir

abstract type 
    Storage <: node
end

struct Tank <: Storage
    name::String
    status::Bool
    node::Junction
    levellimits::Union{Nothing,NamedTuple}
end

struct Reservoir <: Storage
    name::String
    status::Bool
    node::Junction
    level::Union{Nothing,NamedTuple}
    inflow::TimeSeries.TimeArray
end