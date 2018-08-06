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
                    ) where {T<:Array{<:Tank}, P<:Array{<:Pipe}, V<:Array{<:Valve}, M<:Array{<:Pump}}

    WaterSystem(junctions, tanks, reservoirs, pipes, valves, pumps, demands)
end

struct Network
    incidence::AbstractArray{Int64}
    null::Array{Float64}
end

function Network(links::Vector{T}, nodes::Vector{WaterSystemDevice}) where T <:Link#didn't work as Vector{T<:Array{<:Link}}
    nodecount = length(nodes)
    A = build_incidence(nodecount, links)
    null_A = build_incidence_null(A)
    return Network(A, null_A)

end

function build_incidence(nodecount::Int64, links::Array{T}) where T<:Link

    linkcount = length(links)

    A = spzeros(Int64,nodecount,linkcount);

   #build incidence matrix
   #incidence_matrix = A
    for (ix,b) in enumerate(links)

        A[b.connectionpoints.from.number, ix] =  1;

        A[b.connectionpoints.to.number, ix] = -1;

    end
    return  A
end
function build_incidence_null(A)
    null_A = nullspace(full(A))
    return null_A
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

function WaterSystem(inp_file::String)
    data = make_dict(inp_file)
    junctions, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data)
    links = vcat(pipes,valves,pumps)
    nodes = vcat(junctions, tanks, reservoirs)
    net = Network(links, nodes)
    return WaterSystem(junctions, tanks, reservoirs, pipes, valves, pumps, demands), simulations, net
end

function WaterSystem(inp_file::String, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64, tight_coef::Float64)
    data = make_dict(inp_file)
    junctions, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data, n, Q_lb, logspace_ratio, dH_critical, dense_coef, tight_coef)
    links = vcat(pipes, valves, pumps)
    nodes = vcat(junctions, tanks, reservoirs)
    net = Network(links, nodes)
    return WaterSystem(junctions, tanks, reservoirs, pipes, valves, pumps, demands), simulations, net
end
