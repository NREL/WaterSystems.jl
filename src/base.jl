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
#Keeping old format in case 
struct WaterSystem{T <: Union{Nothing, Array{ <: Tank,1}},
                   V <: Union{Nothing, Array{ <: Valve,1}},
                   P <: Union{Nothing, Array{ <: Pipe,1}},
                   M <: Union{Nothing, Array{ <: Pump,1}}}
    junctions::Array{Junction}
    tanks::T
    reservoirs::Array{StorageReservoir}
    pipes::P
    valves::V
    pumps::M
    demands::Array{WaterDemand}
end

function WaterSystem(
                    junctions::Array{Junction},
                    tanks::T,
                    reservoirs::Array{StorageReservoir},
                    pipes::P,
                    valves::V,
                    pumps::M,
                    demands::Array{WaterDemand}
                    ) where {T<:Array{<:Tank}, P<:Array{<:Pipe}, V<:Array{<:Valve}, M<:Array{<:Pump}}

    WaterSystem(junctions, tanks, reservoirs, pipes, valves, pumps, demands)
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
    nodes =  vcat(junctions, [tank.node for tank in tanks])
    nodes = vcat(nodes, [res.node for res in reservoirs])
    net = Network(nodes,links)
    return WaterSystem(junctions, tanks, reservoirs, pipes, valves, pumps, demands), simulations, net
end

function WaterSystem(inp_file::String, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64, tight_coef::Float64)
    data = make_dict(inp_file)
    junctions, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data, n, Q_lb, logspace_ratio, dH_critical, dense_coef, tight_coef)
    links = vcat(pipes, valves, pumps)
    nodes =  vcat(junctions, [tank.node for tank in tanks])
    nodes = vcat(nodes, [res.node for res in reservoirs])
    net = Network(nodes,links)
    return WaterSystem(junctions, tanks, reservoirs, pipes, valves, pumps, demands), simulations, net
end
