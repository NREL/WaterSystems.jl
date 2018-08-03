include("ManipulateTanks.jl")
include("ManipulatePumps.jl")
include("UpdateExtrema.jl")
include("MaxMinLevels.jl")
include("PipeCoefs.jl")
include("PumpCoefs.jl")
include("CheckValveCoefs.jl")
include("FlowDirections.jl")
#Pipe Coefs
function Parameterize(wn_dict::Dict{Any,Any}, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64, tight_coef::Float64)
#Thought: should we make one q_base with pipe and valve names?
    #Pipes
    Parameters = Dict{String,Any}()
    Parameters["Qmin"], Parameters["Qmax"], Parameters["Hmin"], Parameters["Hmax"]  = Q_extrema(wn_dict, Q_lb, tight_coef)

    Parameters["Q_basePipe"] = Q_base_pipe(wn_dict, Parameters["Qmin"], Parameters["Qmax"], n, Q_lb, logspace_ratio, dH_critical, dense_coef)
    Parameters["aPipe_over"], Parameters["bPipe_over"] = PipeCoefsOver(wn_dict, Parameters["Q_basePipe"])
    Parameters["aPipe_under"], Parameters["bPipe_under"] = PipeCoefsUnder(wn_dict, Parameters["Q_basePipe"])
    # Pumps
    Parameters["flow"], Parameters["head"], Parameters["power"] = FlowHeadPower(wn_dict)
    Parameters["aPumpPower_flow"], Parameters["bPumpPower_flow"] = PumpPowerCoefs_Flow(wn_dict, Parameters["flow"], Parameters["power"])
    Parameters["aPumpPower_head"], Parameters["bPumpPower_head"] = PumpPowerCoefs_Head(wn_dict, Parameters["head"], Parameters["power"])
    #Check Valves
    Parameters["Q_baseCV"] = Q_base_checkvalve(wn_dict, Parameters["Qmax"], n, Q_lb, logspace_ratio, dH_critical, dense_coef)
    Parameters["aCheckValve_over"], Parameters["bCheckValve_over"] = CheckValveCoefsOver(Parameters["Q_baseCV"])
    Parameters["aCheckValve_under"], Parameters["bCheckValve_under"] = CheckValveCoefsUnder(Parameters["Q_baseCV"])

    #Flow Directions
    Parameters["PositiveFlowLinks"], Parameters["NegativeFlowLinks"], Parameters["ReversibleFlowLinks"] = FlowDirection(wn_dict, Parameters["Qmin"], Parameters["Qmax"])
    return Parameters
end
