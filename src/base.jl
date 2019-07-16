## Time Series Length ##

include("Parsers/dict_to_struct.jl")
include("Parsers/wntr_dict.jl")
include("Parsers/wntr_dict_parser.jl")
include("Utils/build_incidence.jl")
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
struct LinkClasses 
    all:: Array{T,1} where T<:Link #all links 
    pipes:: Array{T,1} where T<:Pipe #all pipes
    pumps:: Array{T,1} where T<: Pump #all pumps
    valves:: Array{T,1} where T<: Valve #all valves 
end 
struct NodeClasses
    all:: Array{T,1} where T<: WaterSystemDevice #all nodes (junctions, tanks, reservoirs)
    junctions:: Array{T,1} where T<: Junction#demand nodes
    tanks:: Array{T,1} where T<: Tank #tanks 
    reservoirs:: Array{T,1} where T<:Union{StorageReservoir,SourceReservoir}
end 

struct WaterSystem
    nodes::NodeClasses
    links::LinkClasses
    demands::Array{WaterDemand,1}
end

struct Network
    incidence::Incidence
    null::Array{Float64}
end

function Network(nodes::Vector{N}, links::Vector{T}) where {T<:Link, N<:Junction} #didn't work as Vector{T<:Array{<:Link}}
    A = Incidence(nodes, links)
    null_A = build_incidence_null(A.data)
    return Network(A, null_A)

end

function WaterSystem(inp_file::String)
    data = make_dict(inp_file)
    nodes, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data)
    links = vcat(pipes,valves,pumps)
    link_classes = LinkClasses(links, pipes, pumps, valves)
    junctions_index = length(nodes) - length(tanks) - length(reservoirs) # junctions that aren't tanks/reservoirs
    junctions = nodes[1:junctions_index]
    node_classes = NodeClasses(nodes, junctions, tanks, reservoirs)
    net = Network(nodes,links)
    return WaterSystem(node_classes, link_classes, demands), simulations, net
end

