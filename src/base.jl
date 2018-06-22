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
    duration::Int

    function WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, network)

        time_length = TimeSeriesCheckDemand(demands)

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
            time_length)

    end
end

function WaterSystem(nodes::Array{Junction},
                    junctions::Array{Junction},
                    tanks::Array{RoundTank},
                    reservoirs::Array{Reservoir},
                    links::Array{T} where {T<:Link},
                    pipes::Array{RegularPipe},
                    valves::Array{PressureReducingValve},
                    pumps::Array{ConstSpeedPump},
                    demands::Array{WaterDemand})

    WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, Network(links, nodes))
end
function MakeWaterSystem(inp_file)
    nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, networks = wn_to_struct(inp_file)
    return WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, networks)
end
@time ("make waterSystem from inp")
