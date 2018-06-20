## Time Series Length ##
include("Parsers/epa_net_parser.jl")
@time print("include epa_net_parser")
function TimeSeriesCheckDemand(loads::Array{T}) where {T<:WaterDemand}
    t = length(loads[1].demand) - 1 #WNTR assumes recurring so length(l.demand) = 25 but should be 24
    for l in loads
        if t == length(l.demand) - 1
            continue
        else
            error("Inconsistent load scaling factor time series length")
        end
    end
    return t
end

struct WaterSystem
    junctions::Array{Junction}
    links::Array{T} where {T<:Link}
    storages::Array{T} where {T<:Storage}
    demands::Array{WaterDemand}
    network::Union{Nothing,Network}
    duration::Int

    function WaterSystem(junctions, links, storages, demands, network)

        time_length = TimeSeriesCheckDemand(demands)

        new(junctions,
            links,
            storages,
            demands,
            network,
            time_length)

    end
end

function WaterSystem(junctions::Array{Junction},
                    links::Array{T} where {T<:Link},
                    storages::Array{T} where {T<:Storage},
                    demands::Array{WaterDemand})

    WaterSystem(junctions, links, storages, demands, Network(links, junctions))
end
function MakeWaterSystem(inp_file)
    junctions, links, storages, demands, networks = wn_to_struct(inp_file)
    return WaterSystem(junctions, links, storages, demands, networks)
end
@time ("make waterSystem from inp")
