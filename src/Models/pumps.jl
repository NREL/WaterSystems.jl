export Pump

struct Pump <: Link 
    name::String
    nodes::Tuple{Junction,Junction}
    status::Bool
    initial_status::Bool
    flow::Any
    setting::Any
    initial_setting::Real
    pump_type::String
    efficiency::Real
    energy_price::Real
    speed_timeseries::TimeSeries.TimeArray
end