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
    Qmin, Qmax, Hmin, Hmax  = Q_extrema(wn_dict, Q_lb, tight_coef)

    Q_baseP = Q_base_pipe(wn_dict, Qmin, Qmax, n, Q_lb, logspace_ratio, dH_critical, dense_coef)
    aPipe_over, bPipe_over = PipeCoefsOver(wn_dict, Q_baseP)
    aPipe_under, bPipe_under = PipeCoefsUnder(wn_dict, Q_baseP)
    # Pumps
    flow, head, power = FlowHeadPower(wn_dict)
    aPumpPower_flow, bPumpPower_flow = PumpPowerCoefs_Flow(wn_dict, flow, power)
    aPumpPower_head, bPumpPower_head = PumpPowerCoefs_Head(wn_dict, head, power)
    #Check Valves
    Q_base_cv = Q_base_checkvalve(wn_dict, Qmax, n, Q_lb, logspace_ratio, dH_critical, dense_coef)
    aValve_over, bValve_over = CheckValveCoefsOver(Q_base_cv)
    aValve_under, bValve_under = CheckValveCoefsUnder(Q_base_cv)

    #Flow Directions
    PositiveFlowLinks, NegativeFlowLinks, ReversibleFlowLinks = FlowDirection(wn_dict, Qmin, Qmax)
    return aPipe_over, bPipe_over, aPipe_under, bPipe_under, aPumpPower_flow,
        bPumpPower_flow, aPumpPower_head, bPumpPower_head,aValve_over, bValve_over,
        aValve_under, bValve_under, PositiveFlowLinks, NegativeFlowLinks, ReversibleFlowLinks
end
