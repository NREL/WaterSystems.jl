struct ConstSpeedPump<:Pump
    number::Int64
    name::String
    connectionpoints::@NT(from::Junction, to::Junction)
    status::Bool
    pumpcurve::Union{Function,Array{Tuple{Float64,Float64}}} #Q: m^3/sec, Total Head: m
    efficiency::Union{Nothing,Float64, Array{Tuple{Float64,Float64}}} #% or curve Q: m^3/sec eff: %*100
    energyprice::TimeSeries.TimeArray #$/kW hrs
end

# function pump curves
ConstSpeedPump(
    number::Int64,
    name::String,
    connectionpoints::@NT(from::Junction, to::Junction),
    status::Bool,
    pumpcurve::Function,
    efficiency::Union{Nothing,Float64},
    energyprice::TimeSeries.TimeArray
    ) = ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice)

#aPWL pump curves
# ConstSpeedPump(
#     number::Int64,
#     name::String,
#     connectionpoints::@NT(from::Junction, to::Junction),
#     status::Bool,
#     pumpcurve::Array{Tuple{Float64,Float64}},
#     efficiency::Union{Nothing,Float64},
#     energyprice::TimeSeries.TimeArray,
#     intercept::Float64,
#     slope::Float64
#     )= ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice, intercept, slope)

 ConstSpeedPump(;
                number = 1,
                name = "init",
                connectionpoints = @NT(from::Junction(), to::Junction()),
                status = false,
                pumpcurve = [(0.0,0.0)],
                efficiency = 1.0,
                energyprice = TimeSeries.TimeArray(today(), [0.0]),
                intercept = 0.0,
                slope = 0.0
                ) = ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice, intercept, slope)
