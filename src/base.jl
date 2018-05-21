export WaterSystem

## Time Series Length ##

function TimeSeriesCheckDemand(loads::Array{T}) where {T<:WaterDemand}
    t = length(loads[1].scalingfactor)
    for l in loads
        if t == length(l.scalingfactor)
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
    timesteps::Int
    
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