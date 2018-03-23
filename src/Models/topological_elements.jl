export Junction

struct Junction
    number::Int
    name::String
    elevation::Real # Same as head? 
    pressure::Real 
    pressurelims::Union{Nothing, NamedTuples}    
end

struct PressureZone
    name::String
    junctions::Array{Junction}
end