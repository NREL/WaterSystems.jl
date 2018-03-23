export WaterDemand 

struct WaterDemand 
    name::String
    status::Bool
    node::Junction
    MaxDemand::Real
    ScalingFactor::TimeSeries.TimeArray
end 