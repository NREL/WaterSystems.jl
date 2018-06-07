export WaterDemand 

struct WaterDemand 
    name::String
    junction::Junction
    status::Bool
    maxdemand::Float64
    scalingfactor::TimeSeries.TimeArray
end 

WaterDemand(;   
                name="init",
                junction=Junction(),
                status=false,
                maxdemand=0.0,
                scalingfactor=TimeSeries.TimeArray(today(), [0.0])
                ) = WaterDemand(name,junction,status,maxdemand,scalingfactor)