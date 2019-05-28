
struct Junction <: WaterSystemDevice
    number::Int
    name::String
    elevation::Float64 #m
    head::Union{Nothing,Float64} #Meters Total Head/Hydraulic Head = Pressure Head + Elevation
    minimum_pressure::Float64 #m
    coordinates::Union{NamedTuple{(:lat, :lon), Tuple{Float64, Float64}},Nothing}
    internal:: WaterSystemInternal
end
function Junction(number, name, elevation, head, minimum_pressure, coordinates)
     Junction(number, name, elevation, head, minimum_pressure, coordinates, WaterSystemInternal())
end 
Junction(;  number = 0,
            name="init",
            elevation=0,
            head = nothing,
            minimum_pressure = 0.0,
            coordinates = nothing
            ) = Junction(number, name, elevation, head, minimum_pressure, coordinates)

struct PressureZone
    name::String
    junctions::Array{Junction}
    internal:: WaterSystemInternal
end
function PressureZone(name, junctions)
    PressureZone(name, junctions, WaterSystemInternal())
end 
PressureZone(;name::String, junctions::Array{Junction}) = PressureZone(name, junctions)

