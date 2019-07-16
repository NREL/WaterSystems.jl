
struct Junction <: WaterSystemDevice
    name::String
    elevation::Float64 #m
    head::Union{Nothing,Float64} #Meters Total Head/Hydraulic Head = Pressure Head + Elevation
    minimum_pressure::Float64 #m
    coordinates::Union{NamedTuple{(:lat, :lon), Tuple{Float64, Float64}},Nothing}
end

Junction(; 
            name="init",
            elevation=0,
            head = nothing,
            minimum_pressure = 0.0,
            coordinates = nothing
            ) = Junction(name, elevation, head, minimum_pressure, coordinates)

struct PressureZone
    name::String
    junctions::Array{Junction}
end
