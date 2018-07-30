function PipeCoefsOver(wn_dict::Dict{Any,Any}, Q_base::Dict{String,Float64})
    pipes = wn_dict["pipes"]
    aPipe = Dict{String, Float64}
    bPipe = Dict{String, Float64}
    for (name, pipe) in pipes
        Q_base_current = Q_base[name]
        Q_power_current = Array{Float64}(length(Q_base_current))

        for i = 1: length(Q_base_current)
            Q_power_current[i] = Q_base_current[i]^1.852
        end
        aPipe_current = Array{Float64}(length(Q_base_current)-1)
        bPipe_current = Array{Float64}(length(Q_base_current)-1)
        for j = 1:length(aPipe_current)
            aPipe_current[i], bPipe_current[i] = linear_fit(Q_base_current, Q_power_current)
        end
        aPipe[name] = aPipe_current
        bPipe[name] = bPipe_current
        return (aPipe, bPipe)
    end
end

function PipeCoefsUnder(wn_dict::Dict{Any,Any}, Q_base::Dict{String,Float64})
    pipes = wn_dict["pipes"]
    for (name, pipe) in pipes
        Q_base_current = Q_base[name]
        Q_power_current = Array{Float64}(length(Q_base_current))
        aPipe_current = Array{Float64}(length(Q_base_current)) #note # of slopes = # of points unlike over estimate
        bPipe_current = Array{Float64}(length(Q_base_current))
        for i = 1:length(Q_base_current)
            Q_power_current[i] = Q_base_current[i]^1.852
            aPipe_current[i] = 1.852 * Q_base_current[i]^0.852 #slope of tangent line
            bPipe_current[i] = Q_power_current[i] - aPipe_current[i]*Q_base_current[i]
        end
        aPipe[name] = aPipe_current
        bPipe[name] =bPipe_current
    end
    return(aPipe, bPipe)
end

function Q_base(wn_dict::Dict{Any,Any}, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64)
    pipes = wn_dict["pipes"]
    Q_base = Dict{String, Float64}()
    for (name, pipe) in pipes
        Q_bar = maximum(abs(Qmin[name], abs(Qmax[name])))
        if Q_bar <= Q_lb
            Q_base[name] = [0, Q_lb]
        else
            HW_multiplier = (1/pipe["roughness"])^1.852 *10.67 *pipe["length"]*pipe["diameter"]^4.87
            if Q_bar ^1.852*HW_multiplier >= dH_critical
                density = logspace_ratio*dense_coef
            else
                density = logspace_ratio
            end
            num_log = int(log10(Q_bar/Q_lb)*density)+1
            Q_base[name] = [0; logspace(log10(Q_lb), log10(Q_bar), num_log +1)]
        end
        length(Q_base[name]) > n+1 ? error("Please Choose another n > $length(Q_base[name])") : nothing
    end
    return(Q_base)
end
