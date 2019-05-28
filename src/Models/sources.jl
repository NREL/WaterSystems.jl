abstract type
    Source <:WaterSystemDevice
end
struct SourceReservoir <: Source
    name::String
    node::Junction
    elevation::Float64
    internal:: WaterSystemInternal
end

function SourceReservoir(name, node, elevation)
    SourceReservoir(name, node, elevation, WaterSystemInternal())
end 
SourceReservoir(; name::String, node::Junction, elevation::Float64) = SourceReservoir(name, node, elevation)

