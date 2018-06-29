## Time Series Length ##

include("Parsers/epa_net_parser.jl")
@time print("include epa_net_parser")
function TimeSeriesCheckDemand(loads::Array{T}) where {T<:WaterDemand}
    t = length(loads[1].demand)
    for l in loads
        if t == length(l.demand)
            continue
        else
            error("Inconsistent load scaling factor time series length")
        end
    end
    return t
end

struct WaterSystem
    nodes::Array{Junction}
    junctions::Array{Junction}
    tanks::Array{RoundTank}
    reservoirs::Array{Reservoir}
    links::Array{T} where {T<:Link}
    pipes::Array{RegularPipe}
    valves::Array{PressureReducingValve}
    pumps::Array{ConstSpeedPump}
    demands::Array{WaterDemand}
    network::Union{Nothing,Network}
    duration::Int64
    wntr_timestep::Float64
end

function WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, network, duration, wntr_timestep)

        new(nodes,
            junctions,
            tanks,
            reservoirs,
            links,
            pipes,
            valves,
            pumps,
            demands,
            network,
            duration,
            wntr_timestep)
end

function WaterSystem(nodes::Array{Junction},
                    junctions::Array{Junction},
                    tanks::Array{RoundTank},
                    reservoirs::Array{Reservoir},
                    links::Array{T} where {T<:Link},
                    pipes::Array{RegularPipe},
                    valves::Array{PressureReducingValve},
                    pumps::Array{ConstSpeedPump},
                    demands::Array{WaterDemand},
                    duration::Int64,
                    wntr_timestep::Float64)

    WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, Network(links, nodes), duration, wntr_timestep)
end
function MakeWaterSystem(inp_file)
    nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, duration, wntr_timestep = wn_to_struct(inp_file)
    return WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, duration, wntr_timestep)
end
@time ("make waterSystem from inp")
