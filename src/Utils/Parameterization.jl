include("PipeCoefs.jl")
#Pipe Coefs
Parameterize(wn_dict::Dict{Any,Any})
    Q_base = Q_base(wn_dict, n, Q_lb, logspace_ratio, dH_critical, dense_coef)
    aPipe_over, bPipe_over = PipeCoefsOver(wn_dict, Q_base)
    aPipe_under, bPipe_under = PipeCoefsUnder(wn_dict, Q_base)
