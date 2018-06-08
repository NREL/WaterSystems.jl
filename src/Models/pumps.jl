export ConstSpeedPump

struct ConstSpeedPump <: Link
    name::String
    connectionpoints::@NT(from::Junction, to::Junction)
    status::Bool
    flowcurve::Union{Function,Array{Tuple{Float64,Float64}}}
    energycurve::Union{Function,Array{Tuple{Float64,Float64}}}
    driveefficiency::Union{Nothing,Float64}
    energyprice::TimeSeries.TimeArray
end

# function pump curves
ConstSpeedPump(
    name::String,
    connectionpoints::@NT(from::Junction, to::Junction),
    status::Bool,
    flowcurve::Function,
    energycurve::Function,
    driveefficiency::Union{Nothing,Float64},
    energyprice::TimeSeries.TimeArray
    ) = ConstSpeedPump(name, connectionpoints, status, flowcurve, energycurve, driveefficiency, energyprice)

# PWL pump curves
ConstSpeedPump(
    name::String,
    connectionpoints::@NT(from::Junction, to::Junction),
    status::Bool,
    flowcurve::Tuple{Float64,Float64},
    energycurve::Tuple{Float64,Float64},
    driveefficiency::Union{Nothing,Float64},
    energyprice::TimeSeries.TimeArray
    )= ConstSpeedPump(name, connectionpoints, status, flowcurve, energycurve, driveefficiency, energyprice)

ConstSpeedPump(;
                name="init",
                connectionpoints=(from::Junction(), to::Junction()),
                status=false,
                flowcurve=[(0.0,0.0)],
                energycurve=[(0.0,0.0)],
                driveefficiency=1.0,
                energyprice=TimeSeries.TimeArray(today(), [0.0])
                ) = ConstSpeedPump(name, connectionpoints, status, flowcurve, energycurve, driveefficiency, energyprice)
