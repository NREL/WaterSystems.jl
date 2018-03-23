export WaterDemand 

struct WaterDemand 
    name::String
    status::Bool
    node::Junction
    maxsemand::Real
    scalingfactor::TimeSeries.TimeArray
end 