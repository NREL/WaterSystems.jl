
struct WaterDemand <: WaterSystemDevice
    name::String
    number::Int64
    junction::Junction
    status::Bool
    maxdemand::Float64
    demand::TimeSeries.TimeArray
    demandforecast::TimeSeries.TimeArray
end

WaterDemand(;
                name="init",
                number = 0,
                junction=Junction(),
                status=false,
                maxdemand=0.0,
                demand=TimeSeries.TimeArray(today(), [0.0]),
                demandforecast = TimeSeries.TimeArray(today(), [0.0])
                ) = WaterDemand(name,number,junction,status,maxdemand,demand, demandforecast)
