export Junction
export PressureZone

abstract type 
    Node
end

struct Junction <: Node
    name::String
    elevation::Real
    head::Union{Nothing,Float64}
    demand::Any 
    minimum_pressure::Float64
    coordinates::Union{NamedTuple{(:lat,:lon),Tuple(Float64,Float64)},nothing}
end

Junction(;  name,
            elevation=0,
            head = nothing,
            demand = nothing,
            minimum_pressure = 0,
            coordinates = nothing
            ) = Junction(name,elevation,head,demand,minimum_pressure,coordinates)

struct PressureZone
    name::String
    junctions::Array{Junction}
end

include("storage.jl")
