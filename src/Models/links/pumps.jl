struct ConstSpeedPump<:Pump
    number::Int64
    name::String
    connectionpoints::@NT(from::Junction, to::Junction)
    status::Bool
    pumpcurve::Union{Function,Array{Tuple{Float64,Float64}}} #Q: m^3/sec, Total Head: m
    efficiency::Union{Nothing,Float64, Array{Tuple{Float64,Float64}}} #% or curve Q: m^3/sec eff: %*100
    energyprice::TimeSeries.TimeArray #$/kW hrs
    flow::Dict{String, Array{Float64,1}}
    head::Dict{String, Array{Float64,1}}
    power::Dict{String, Array{Float64,1}}
    aPumpPower_flow::Dict{String, Array{Float64,1}}
    bPumpPower_flow::Dict{String, Array{Float64,1}}
    aPumpPower_head::Dict{String, Array{Float64,1}}
    bPumpPower_head::Dict{String, Array{Float64,1}}
end

# function pump curves
ConstSpeedPump(
    number::Int64,
    name::String,
    connectionpoints::@NT(from::Junction, to::Junction),
    status::Bool,
    pumpcurve::Function,
    efficiency::Union{Nothing,Float64},
    energyprice::TimeSeries.TimeArray,
    flow::Dict{String, Array{Float64,1}},
    head::Dict{String, Array{Float64,1}},
    power::Dict{String, Array{Float64,1}},
    aPumpPower_flow::Dict{String, Array{Float64,1}},
    bPumpPower_flow::Dict{String, Array{Float64,1}},
    aPumpPower_head::Dict{String, Array{Float64,1}},
    bPumpPower_head::Dict{String, Array{Float64,1}}
    ) = ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice,
                        flow, head, power, aPumpPower_flow, bPumpPower_flow, aPumpPower_head, bPumpPower_head)

#aPWL pump curves
# ConstSpeedPump(
#     number::Int64,
#     name::String,
#     connectionpoints::@NT(from::Junction, to::Junction),
#     status::Bool,
#     pumpcurve::Array{Tuple{Float64,Float64}},
#     efficiency::Union{Nothing,Float64},
#     energyprice::TimeSeries.TimeArray,
#     intercept::Float64,
#     slope::Float64
#     )= ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice, intercept, slope)

 ConstSpeedPump(;
                number = 1,
                name = "init",
                connectionpoints = @NT(from::Junction(), to::Junction()),
                status = false,
                pumpcurve = [(0.0,0.0)],
                efficiency = 1.0,
                energyprice = TimeSeries.TimeArray(today(), [0.0]),
                flow = Dict{String, Array{Float64,1}}(),
                head = Dict{String, Array{Float64,1}}(),
                power = Dict{String, Array{Float64,1}}(),
                aPumpPower_flow = Dict{String, Array{Float64,1}}(),
                bPumpPower_flow = Dict{String, Array{Float64,1}}(),
                aPumpPower_head = Dict{String, Array{Float64,1}}(),
                bPumpPower_head = Dict{String, Array{Float64,1}}()
                ) = ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice,
                                    flow, head, power, aPumpPower_flow, bPumpPower_flow, aPumpPower_head, bPumpPower_head)
function ConstSpeedPump(number::Int64,name::String,connectionpoints::@NT(from::Junction, to::Junction),
                        status::Bool,pumpcurve::Function,efficiency::Union{Nothing,Float64},energyprice::TimeSeries.TimeArray)

    flow = Dict{String, Array{Float64,1}}()
    head = Dict{String, Array{Float64,1}}()
    power = Dict{String, Array{Float64,1}}()
    aPumpPower_flow = Dict{String, Array{Float64,1}}()
    bPumpPower_flow = Dict{String, Array{Float64,1}}()
    aPumpPower_head = Dict{String, Array{Float64,1}}()
    bPumpPower_head = Dict{String, Array{Float64,1}}()

    return ConstSpeedPump(number, name, connectionpoints, status, pumpcurve, efficiency, energyprice,
                        flow, head, power, aPumpPower_flow, bPumpPower_flow, aPumpPower_head, bPumpPower_head)
end
