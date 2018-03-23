export Junction
export PressureZone

struct Junction
    number::Int
    name::String
    elevation::Real # Same as head? 
    head::Real 
    pressurelims::Union{Nothing, NamedTuple}    
end

struct PressureZone
    name::String
    junctions::Array{Junction}
end