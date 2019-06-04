abstract type
    Source <:WaterSystemDevice
end
struct SourceReservoir <: Source
    name::String
    node::Junction
    elevation::Float64
end
