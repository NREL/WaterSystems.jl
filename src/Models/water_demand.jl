
struct WaterDemand <: WaterSystemDevice
    name::String
    junction::Junction
    status::Bool
    maxdemand::Float64 #m^3/sec
    demand::TimeSeries.TimeArray #m^3/sec
    demandforecast::TimeSeries.TimeArray #m^3/sec
end

WaterDemand(;
                name="init",
                junction=Junction(),
                status=false,
                maxdemand=0.0,
                demand=TimeSeries.TimeArray(today(), [0.0]),
                demandforecast = TimeSeries.TimeArray(today(), [0.0])
                ) = WaterDemand(name,junction,status,maxdemand,demand, demandforecast)
