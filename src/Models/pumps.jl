export Pump

struct Pump <: Link 
    name::String
    nodes::Tuple{Junction,Junction}
    status::Bool
    initial_status::Bool
    tag::Any
    flow::Any
    setting::Any
    initial_setting::Real
    pump_type::String
    pump_curve_name::String
    efficiency::Real
    energy_price::Real
    energy_pattern::Any
    base_speed::Real
    speed_pattern_name::String
    speed_timeseries::TimeSeries.TimeArray
end