module WaterSystems

#################################################################################
# Exports

# water system
export WaterSystem
export MakeWaterSystem

# network
export Network

# pumps
export ConstSpeedPump

# storages
export Storage
export RoundTank
export Reservoir

# topological elements
export Junction
export PressureZone

# transport elements
export Link
export RegularPipe
export PressureReducingValve

# demands
export WaterDemand

# parser
export wn_to_struct

#################################################################################
# Imports

using TimeSeries
using DataFrames
# This packages will be removed with Julia v0.7
using Compat
using PyCall
using NamedTuples

include("Models/topological_elements.jl")
include("Models/storage.jl")
include("Models/network.jl")
include("Models/pumps.jl")
include("Models/simulations.jl")
include("Models/water_demand.jl")

include("base.jl")

#Parser
include("Parsers/epa_net_parser.jl")

#__precompile__() # this module is NOT safe to precompile

try
    @pyimport wntr
catch

    const PACKAGES = ["wntr"]

    # Import pip
    try
        @pyimport pip
    catch
        # If it is not found, install it
        get_pip = joinpath(dirname(@__FILE__), "get-pip.py")
        download("https://bootstrap.pypa.io/get-pip.py", get_pip)
        run(`$(PyCall.python) $get_pip --user`)
    end

    @pyimport pip

    args = []
    if haskey(ENV, "http_proxy")
        push!(args, "--proxy")
        push!(args, ENV["http_proxy"])
    end
    push!(args, "install")
    push!(args, "--user")
    append!(args, PACKAGES)

    pip.main(args)


end
const wntr = PyNULL()
function __init__()
    copy!(wntr, pyimport("wntr"))
end

end # module
