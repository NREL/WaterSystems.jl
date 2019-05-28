
struct WaterDemand <: WaterSystemDevice
    name::String
    number::Int64
    junction::Junction
    status::Bool
    maxdemand::Float64 #m^3/sec
    demand::TimeSeries.TimeArray #m^3/sec
    internal:: WaterSystemInternal 
end
function WaterDemand( name, number, junction, status, maxdemand, demand)
    WaterDemand(name,number,junction,status,maxdemand,demand, WaterSystemInternal())
end 
WaterDemand(;name="init",
            number = 0,
            junction=Junction(),
            status=false,
            maxdemand=0.0,
            demand=TimeSeries.TimeArray(today(), [0.0])) = WaterDemand(name,number,junction,status,maxdemand,demand)
