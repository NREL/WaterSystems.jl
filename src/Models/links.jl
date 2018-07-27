abstract type
    Link<:WaterSystemDevice
end
abstract type
    Pipe<:Link
end

abstract type
    Pump<:Link
end

abstract type
    Valve<:Link
end
include("links/pipes.jl")
include("links/pumps.jl")
include("links/valves.jl")
