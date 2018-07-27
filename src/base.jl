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

struct WaterSystem{T <: Union{Nothing, Array{ <: Tank,1}},
                   L <: Union{Nothing, Array{ <: Link,1}},
                   V <: Union{Nothing, Array{ <: Valve,1}},
                   P <: Union{Nothing, Array{ <: Pipe,1}},
                   M <: Union{Nothing, Array{ <: Pump,1}}}
    nodes::Array{Junction}
    junctions::Array{Junction}
    tanks::T
    reservoirs::Array{Reservoir}
    links::L
    pipes::P
    valves::V
    pumps::M
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
                    tanks::T,
                    reservoirs::Array{Reservoir},
                    links::L,
                    pipes::P,
                    valves::V,
                    pumps::M,
                    demands::Array{WaterDemand},
                    simulation::Simulation) where {T<:Array{<:Tank}, L<:Array{<:Link}, P<:Array{<:Pipe}, V<:Array{<:Valve}, M<:Array{<:Pump}}

    WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, Network(links, nodes), simulation)
end
function WaterSystem(inp_file::String)
    data = make_dict(inp_file)
    nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, simulation = dict_to_struct(data)
    return WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, simulation)
end
