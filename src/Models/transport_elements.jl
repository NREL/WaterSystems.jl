export Pipeline
export Valve

struct Pipeline
    name::String
    status::Bool
    connectionpoints::Tuple{Junction,Junction}
    length::Real
    diameter::Real
    roughness::Real
    minorloss::Real
    pressurelimits::Union{Nothing,Real}
end

struct Valve 
    name::String
    statis::Bool
    connectionpoints::Tuple{Junction,Junction}
    diameter::Real
    minorloss::Real
end