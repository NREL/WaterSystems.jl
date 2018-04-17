export Junction
export PressureZone

abstract type 
    Node
end

struct Junction <: Node
    name::String
    elevation::Real
    head::Real
    demand::Any 
    minimum_pressure::Real
    coordinates::Tuple{Real,Real}
end

struct PressureZone
    name::String
    junctions::Array{Junction}
end

include("storage.jl")
