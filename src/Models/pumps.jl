
struct ConstSpeedPump <: Link
    number::Int64
    name::String
    connectionpoints::@NT(from::Junction, to::Junction)
    status::Bool
    pumpcurve::Union{Function,Array{Tuple{Float64,Float64}}}
    efficiency::Union{Nothing,Float64}
    energyprice::TimeSeries.TimeArray
    energy::TimeSeries.TimeArray
end

# function pump curves
ConstSpeedPump(
    number::Int64,
    name::String,
    connectionpoints::@NT(from::Junction, to::Junction),
    status::Bool,
    pumpcurve::Function,
    efficiency::Union{Nothing,Float64},
    energyprice::TimeSeries.TimeArray,
    energy::TimeSeries.TimeArray
    ) = ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice, energy)

# PWL pump curves
ConstSpeedPump(
    number::Int64,
    name::String,
    connectionpoints::@NT(from::Junction, to::Junction),
    status::Bool,
    pumpcurve::Array{Tuple{Float64,Float64}},
    efficiency::Union{Nothing,Float64},
    energyprice::TimeSeries.TimeArray,
    energy::TimeSeries.TimeArray
    )= ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice, energy)

ConstSpeedPump(;
                number = 1,
                name = "init",
                connectionpoints = (from::Junction(), to::Junction()),
                status = false,
                pumpcurve = [(0.0,0.0)],
                efficiency = 1.0,
                energyprice = TimeSeries.TimeArray(today(), [0.0]),
                energy = TimeSeries.TimeArray(today(), [0.0])
                ) = ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice, energy)
