function Get_Coeffs(wn_dict::Dict{Any,Any},Qmin::Dict{String, Float64}, Qmax::Dict{String,Float64}, Hmin::Dict{String, Float64}, Hmax::Dict{String,Float64})
    #coefs go here
    # Pipes
    pipes = wn_dict["pipes"]
    for (name, pipe) in pipes
        Q_bar = maximum(abs(Qmin[name], abs(Qmax[name])))
        if Q_bar <= Q_lb
            Q_base[name] = [0,Q_lb]
        else
            HW_multiplier = (1/pipe["roughness"])^1.852 *10.67 *pipe["length"]*pipe["diameter"]^4.87
            if Q_bar ^1.852*HW_multiplier >= dH_critical
                density = logspace_ratio*dense_coef
            else
                density = logspace_ratio
            end
        end
end
