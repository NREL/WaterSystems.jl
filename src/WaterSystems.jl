module WaterSystems

#################################################################################
# Exports

# water system
export WaterSystem

# network
export Network

# pumps
export ConstSpeedPump

# storages
export Storage
export Tank
export RoundTank
export StorageReservoir

# topological elements
export Junction
export PressureZone

# transport elements
export Link
export Pipe
export Valve
export RegularPipe
export StandardPositiveFlowPipe
export NegativeFlowPipe
export ReversibleFlowPipe
export CheckValvePipe
export ControlPipe
export PressureReducingValve
export GateValve
# demands
export WaterDemand

#simulation
export Simulation

#parameterize
export Parameters
# parser
# export wn_to_struct
export dict_to_struct
export make_dict
export wntr_dict

#################################################################################
# Imports

using TimeSeries
using DataFrames
# This packages will be removed with Julia v0.7
using Compat
using PyCall
using NamedTuples
using CurveFit

abstract type WaterSystemDevice end
#Models
include("Models/topological_elements.jl")
include("Models/storage.jl")
include("Models/sources.jl")
include("Models/simulations.jl")
include("Models/water_demand.jl")
include("Models/links.jl")
include("Models/links/pipes.jl")
include("Models/links/pumps.jl")
include("Models/links/valves.jl")

#Utils
include("Utils/CheckValveCoefs.jl")
include("Utils/ManipulatePumps.jl")
include("Utils/ManipulateTanks.jl")
include("Utils/UpdateExtrema.jl")
include("Utils/MaxMinLevels.jl")
include("Utils/FlowDirections.jl")
include("Utils/PipeCoefs.jl")
include("Utils/PumpCoefs.jl")
include("Utils/Parameterization.jl")

include("base.jl")

#Parser
include("Parsers/LeastSquaresAvg.jl")
# include("Parsers/epa_net_parser.jl")
# include("Parsers/FastParser.jl")
include("Parsers/wntr_dict.jl")
include("Parsers/wntr_dict_parser.jl")
include("Parsers/dict_to_struct.jl")

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
