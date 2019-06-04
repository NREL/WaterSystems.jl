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
#TODO: Do we need all the simulation information? ASM 
# struct WaterSystem 
#     nodes::Vector{Junction}
#     links::Vector{<:Link}
#     storage::Union{Nothing, Vector{<:Storage}}
#     demand:: Vector{WaterDemand}
#     simulation:: Simulation 
# end

# function WaterSystem(nodes, links, storage, demand, simulation)
#     sys = new(nodes, links, storage, demand, simulation)
#     return sys
# end

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
    junctions, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data)
    links = vcat(pipes,valves,pumps)
    link_classes = LinkClasses(links, pipes, pumps, valves)
    nodes =  vcat(junctions, [tank.node for tank in tanks])
    nodes = vcat(nodes, [res.node for res in reservoirs])
    node_classes = NodeClasses(nodes, junctions, tanks, reservoirs)
    net = Network(nodes,links)
    return WaterSystem(node_classes, link_classes, demands), simulations, net
end

function WaterSystem(inp_file::String, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64, tight_coef::Float64)
    data = make_dict(inp_file)
    junctions, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data, n, Q_lb, logspace_ratio, dH_critical, dense_coef, tight_coef)
    links = vcat(pipes, valves, pumps)
    link_classes = LinkClasses(links, pipes, pumps, valves)
    nodes =  vcat(junctions, [tank.node for tank in tanks])
    nodes = vcat(nodes, [res.node for res in reservoirs])
    node_classes = NodeClasses(nodes, junctions, tanks, reservoirs)
    net = Network(nodes,links)
    return WaterSystem(node_classes, link_classes, demands), simulations, net
end

