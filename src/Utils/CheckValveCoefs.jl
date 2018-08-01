function CheckValveCoefsOver(Q_base::Dict{String, Array{Float64,1}})
    aCheckValve = Dict{String, Array{Float64,1}}()
    bCheckValve = Dict{String, Array{Float64,1}}()
    for (name, Q_base_current) in Q_base
        Q_power_current = Array{Float64}(length(Q_base_current))
        aCheckValve_current = Array{Float64}(length(Q_base_current)-1)
        bCheckValve_current = Array{Float64}(length(Q_base_current)-1)
        for i = 1:length(Q_base_current)
            Q_power_current[i] = Q_base_current[i]^1.852
        end
        for i = 1:length(Q_base_current)-1
            bCheckValve_current[i] = (Q_power_current[i+1] - Q_power_current[i])/(Q_base_current[i+1] - Q_base_current[i])
            aCheckValve_current[i] = Q_power_current[i] - bCheckValve_current[i] * Q_base_current[i]
        end
        aCheckValve[name] = aCheckValve_current
        bCheckValve[name] = bCheckValve_current
    end
    return(aCheckValve, bCheckValve)
end

function CheckValveCoefsUnder(Q_base::Dict{String, Array{Float64,1}})
    aCheckValve = Dict{String, Array{Float64,1}}()
    bCheckValve = Dict{String, Array{Float64,1}}()
    for (name, Q_base_current) in Q_base
        Q_power_current = Array{Float64}(length(Q_base_current))
        aCheckValve_current = Array{Float64}(length(Q_base_current)-1)
        bCheckValve_current = Array{Float64}(length(Q_base_current)-1)
        for i = 1:length(Q_base_current)
            Q_power_current[i] = Q_base_current[i]^1.852
        end
        for i = 1:length(Q_base_current)-1
            bCheckValve_current[i] = 1.852*Q_base_current[i] ^0.852
            aCheckValve_current[i] = Q_power_current[i] - bCheckValve_current[i]*Q_base_current[i]
        end
        aCheckValve[name] = aCheckValve_current
        bCheckValve[name] = bCheckValve_current
    end
    return(aCheckValve, bCheckValve)
end

function Q_base_checkvalve(wn_dict::Dict{Any,Any}, Qmax::Dict{String, Float64}, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64)
    pipes = wn_dict["pipes"]
    Q_base = Dict{String, Array{Float64,1}}()
    for (ix, pipe) in pipes
        if pipe["cv"] == true
            name = pipe["name"]
            Q_bar = 5#Qmax[name]
            if Q_bar <= Q_lb
                Q_base[name] = [0, Q_lb]
            else
                HW_multiplier = (1/pipe["roughness"])^1.852 *10.67 *pipe["length"]*pipe["diameter"]^4.87
                if Q_bar ^1.852*HW_multiplier >= dH_critical
                    density = logspace_ratio*dense_coef
                else
                    density = logspace_ratio
                end
                num_log = floor(Int64,log10(Q_bar/Q_lb)*density+1)
                Q_base[name] = [0; logspace(log10(Q_lb), log10(Q_bar), num_log +1)]
            end
            length(Q_base[name]) > n ? error("Please Choose another n > $length(Q_base[name])") : nothing
        end
    end
    return(Q_base)
end
