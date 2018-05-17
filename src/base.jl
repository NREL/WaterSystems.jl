export WaterSystem

struct WaterSystem
    junctions::Array{Junction}
    links::Array{T} where {T<:Link}
    storages::Array{T} where {T<:Storage}
    demands::WaterDemand
    network::Union{Nothing,Network}
    timesteps::Int
    
    function WaterSystem(junctions, links, storages, demands, network, timesteps)

        #time_length = TimeSeriesCheckLoad(loads)
        #TimeSeriesCheckRE(generators, time_length)

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

    WaterSystem(junctions, links, storages, demands, Network(links, junctions), timesteps)
end