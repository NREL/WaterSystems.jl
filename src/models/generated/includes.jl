include("Junction.jl")
include("Arc.jl")
include("Pattern.jl")
include("Curve.jl")
include("EPANETPumpParams.jl")
include("NormPumpParams.jl")
include("PumpParams.jl")
include("Pump.jl")
include("OpenPipe.jl")
include("GatePipe.jl")
include("CVPipe.jl")
include("StaticDemand.jl")
include("CylindricalTank.jl")
include("Reservoir.jl")

export get__forecasts
export get_arc
export get_available
export get_base_demand
export get_base_price
export get_coordinates
export get_diameter
export get_effncy_bep
export get_elevation
export get_epnt_data
export get_epnt_efficiency
export get_epnt_head
export get_epnt_power
export get_epnt_type
export get_flow
export get_flow_bep
export get_flowlimits
export get_from
export get_head
export get_head_bep
export get_headgain
export get_headloss
export get_internal
export get_junction
export get_length
export get_level
export get_level_limits
export get_minimum_pressure
export get_multipliers
export get_name
export get_norm_coefs
export get_open_status
export get_operating
export get_pattern_name
export get_points
export get_power_intcpt
export get_power_slope
export get_pumpparams
export get_roughness
export get_to
export get_type
