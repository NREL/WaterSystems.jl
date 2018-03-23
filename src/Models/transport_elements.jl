export Pipeline
export Valve

struct Pipeline
    name::String
    status::Bool
    connectionpoints::Tuple{Junction,Junction}
    length::Real
    friction::Real
    diameter::Real
    pressurelimits::Union{Nothing,Real}
end

struct Valve 
    name::String
    statis::Bool
    connectionpoints::Tuple{Junction,Junction}
    friction::Real
end