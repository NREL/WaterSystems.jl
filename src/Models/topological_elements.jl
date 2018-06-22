
struct Junction
    number::Int
    name::String
    elevation::Real
    head::Union{Nothing,Float64}
    demand::TimeSeries.TimeArray
    minimum_pressure::Float64
    coordinates::Union{@NT(lat::Float64, lon::Float64),Nothing}
end

Junction(;  number = 0,
            name="init",
            elevation=0,
            head = nothing,
            demand = nothing,
            minimum_pressure = 0.0,
            coordinates = nothing
            ) = Junction(number,name,elevation,head,demand,minimum_pressure,coordinates)

struct PressureZone
    name::String
    junctions::Array{Junction}
end
