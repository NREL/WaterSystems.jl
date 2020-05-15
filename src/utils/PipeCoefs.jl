function PipeCoefsOver(wn_dict::Dict{Any,Any}, Q_base::Dict{String,Array{Float64,1}})
    pipes = wn_dict["pipes"]
    aPipe = Dict{String, Array{Float64,1}}()
    bPipe = Dict{String, Array{Float64,1}}()

    for (key, pipe) in pipes
        name = pipe["name"]
        Q_base_current = Q_base[name]
        Q_power_current = Q_base_current.^1.852
        aPipe_current = Vector{Union{Nothing,Float64}}(nothing, length(Q_base_current)-1)
        bPipe_current = Vector{Union{Nothing,Float64}}(nothing, length(Q_base_current)-1)
        for i in range(1, length(aPipe_current))
            aPipe_current[i] = (Q_power_current[i+1]-Q_power_current[i])/(Q_base_current[i+1]-Q_base_current[i])
            bPipe_current[i] =Q_power_current[i] - aPipe_current[i]*Q_base_current[i]
        end 
        aPipe[name] = aPipe_current
        bPipe[name] = bPipe_current
    end 
    return(Q_base, aPipe, bPipe)
end

function PipeCoefsUnder(wn_dict::Dict{Any,Any}, Q_base::Dict{String,Array{Float64,1}})
    pipes = wn_dict["pipes"]
    aPipe = Dict{String, Array{Float64,1}}()
    bPipe = Dict{String, Array{Float64,1}}()
    for (key, pipe) in pipes
        name = pipe["name"]
        Q_base_current = Q_base[name]
        Q_power_current = Array{Union{Nothing,Float64}}(nothing,length(Q_base_current))
        aPipe_current = Array{Union{Nothing,Float64}}(nothing,length(Q_base_current)) #note # of slopes = # of points unlike over estimate
        bPipe_current = Array{Union{Nothing,Float64}}(nothing,length(Q_base_current))
        for i = 1:length(Q_base_current)
            Q_power_current[i] = Q_base_current[i]^1.852
            bPipe_current[i] = 1.852 * Q_base_current[i]^0.852 #slope of tangent line
            aPipe_current[i] = Q_power_current[i] - bPipe_current[i]*Q_base_current[i]
        end
        aPipe[name] = aPipe_current
        bPipe[name] = bPipe_current
    end
    return(Q_base, aPipe, bPipe)
end

function Q_base_pipe(wn_dict::Dict{Any,Any}, Qmin::Dict{String,Float64}, Qmax::Dict{String,Float64}, n::Int64, Q_lb::Float64, log_density::Union{Int64,Float64}, density_boost::Union{Int64, Float64}, lin_density::Union{Float64,Int64}, linlog_cut::Union{Float64,Int64},dH_critical::Float64)
    pipes = wn_dict["pipes"]
    Q_base = Dict{String, Array{Float64,1}}()
    for (key, pipe) in pipes
        name = pipe["name"]
        Q_bar = maximum([abs(Qmin[name]), abs(Qmax[name])])
        if Q_bar <= Q_lb
            Q_base[name] = [0, Q_lb]
        else
            HW_multiplier = (1/pipe["roughness"])^1.852 *10.67 *pipe["length"]*(1/pipe["diameter"])^4.87
            if Q_bar ^1.852*HW_multiplier >= dH_critical
                log_density_current = log_density*density_boost
                log_density_current = Int(floor(log10(Q_bar*linlog_cut/Q_lb)*log_density_current))+1
                lin_density_current = lin_density* density_boost
            else
                log_density_current = log_density_current
                log_density_current = Int(floor(log10(Q_bar *linlog_cut/Q_lb)*log_density_current)) +1 
                lin_density_current = lin_density 
            end
            Q_base_log = exp10.(range(log10(Q_lb), log10(Q_bar*linlog_cut), step = log_density_current))
            Q_base_lin = exp10.(range(Q_bar*linlog_cut, Q_bar, step = lin_density))
            Q_base[name] = [0; Q_base_log; Q_base_lin[1:length(Q_base_lin)]]
        end 
        Q_base_current = Q_base[name]
        length(Q_base[name]) > n+1 ? error("Please Choose another n > $length(Q_base[name])") : nothing
    end
    return(Q_base)
end
