export Pump
export FixPump
export VariablePump 

abstract type 
    Pump
end

struct FixPump <: Pump 
    name::String
    status::Bool
    connectionpoints::Tuple{Junction,Junction}
    flowlimits::Union{Nothing,NamedTuple}
    curve::Any 
    energy::Any
end

struct VariablePump <: Pump 
    name::String
    status::Bool
    connectionpoints::Tuple{Junction,Junction}
    flowlimits::Union{Nothing,NamedTuple}
    curve::Any 
    energy::Any
end