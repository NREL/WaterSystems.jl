export WaterDemand 

struct WaterDemand 
    name::String
    status::Bool
    node::Junction
    maxdemand::Real
    scalingfactor::TimeSeries.TimeArray
end 