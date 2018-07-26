## Time Series Length ##

include("Parsers/dict_to_struct.jl")
include("Parsers/wntr_dict.jl")
include("Parsers/wntr_dict_parser.jl")
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
    links::Array{T} where T<:Link
    pipes::Array{RegularPipe}
    valves::Array{PressureReducingValve}
    pumps::Array{ConstSpeedPump}
    demands::Array{WaterDemand}
    network::Union{Nothing,Network}
    simulation::Simulation
end

# function WaterSystem(links::Array{<:Link})
# function WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, network, simulation)
#
#         new(nodes,
#             junctions,
#             tanks,
#             reservoirs,
#             links,
#             pipes,
#             valves,
#             pumps,
#             demands,
#             network,
#             simulation)
# end

function WaterSystem(nodes::Array{Junction},
                    junctions::Array{Junction},
                    tanks::Array{RoundTank},
                    reservoirs::Array{Reservoir},
                    links::Array{T} where T<:Link,
                    pipes::Array{RegularPipe},
                    valves::Array{PressureReducingValve},
                    pumps::Array{ConstSpeedPump},
                    demands::Array{WaterDemand},
                    simulation::Simulation)

    WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, Network(links, nodes), simulation)
end
function WaterSystem(inp_file::String)
    data = make_dict(inp_file)
    nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, simulation = dict_to_struct(data)
    return WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, simulation)
end
