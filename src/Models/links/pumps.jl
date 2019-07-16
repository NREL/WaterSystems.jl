struct ConstSpeedPump<:Pump
    name::String
    connectionpoints::NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::Int64
    pumpcurve::Union{Function, Array{Tuple{Float64,Float64},1}} #Q: m^3/sec, Total Head: m
    efficiency::Union{Nothing,Float64, Array{Tuple{Float64,Float64},1}}  #% or curve Q: m^3/sec eff: %*100
    energyprice::TimeSeries.TimeArray{Float64,1,Dates.Date,Array{Float64,1}} #$/kW hrs
end

 ConstSpeedPump(;
                name = "init",
                connectionpoints = (from = Junction(), to = Junction()),
                status = 0,
                pumpcurve = [(0.0,0.0)],
                efficiency = 1.0,
                energyprice = TimeSeries.TimeArray(today(), [0.0])
                ) = ConstSpeedPump(name, connectionpoints, status, pumpcurve, efficiency, energyprice)