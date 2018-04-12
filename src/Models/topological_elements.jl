export Junction
export PressureZone

abstract type 
    node
end

struct Junction <: node
    number::Int
    name::String
    elevation::Real
end

struct PressureZone
    name::String
    junctions::Array{Junction}
end

include("storage.jl")
