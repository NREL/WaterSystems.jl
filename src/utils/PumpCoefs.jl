const gravity = 9.81 # m/s^2
const density = 1000.0 # kg/m^3
# fixed value for Gh0 -- allow users to specify this value?
const Gh0 = 1.25

"""
Calculate slope and intercept for normalized power curve
"""
function power_coeffs(Gh0::Float64)
    # with fixed Gh0 value, then we have fixed values for slope and intercept for normalized
    # power curve
    
    # a least-squares fit -- would be more mathematically rigorouse to use an analytical
    # formula for the fit (TBD)
    N = 100
    Qhat = Array(range(0.5, 1.5, length=N))
    Phat = ((1 - Gh0)*Qhat.^2 .+ Gh0)./(2 .- Qhat)
    A = hcat(Qhat, ones(N))
    slope, intcpt = A\Phat
    return slope, intcpt
end

const pow_slp, pow_int = power_coeffs(Gh0)

"""
Estimate single-point head curve for a pump of 'POWER' type in the .inp file. 
"""
function head_curve_from_power(power::Float64, efficiency::Float64, flows::Vector{Float64})
    flows_nz = flows[flows .> 0] # nonzero flow values
    Q_nominal = sum(flows_nz)/length(flows_nz) # m^3/s
    G_nominal = efficiency/100*power/(density*gravity*Q_nominal) # m 
    head_curve = Vector{Tuple{Float64,Float64}}(undef,1)
    head_curve[1] = (Q_nominal,G_nominal)
    return head_curve
end


"""
Compute the pump parameters for normalized pump curves. Returns (Qbep, etabep, Gbep, slope,
intcpt).
"""
function norm_pump_params(pump::Dict{String,Any}, c_dict::Dict{String,Curve})

    # efficiency
    Qbep = NaN
    if pump["efficiency"] isa String
        eff_curve_tuples = c_dict[pump["efficiency"]].points
        eff_curve = array_from_tuples(eff_curve_tuples)
        eff_curve[:,2] = eff_curve[:,2]
        
        # fit efficiency curve to determine Qbep and etabep
        A = hcat(eff_curve[:,1].^2, eff_curve[:,1])
        a, b = A\eff_curve[:,2]
        Qbep = -0.5*b/a
        etabep = -0.25*b^2/a
    else
        # presume the single-value for efficiency is at the BEP
        etabep = pump["efficiency"]
    end

    # head
    head_curve_tuples = c_dict[pump["head_curve_name"]].points
    head_curve = array_from_tuples(head_curve_tuples)
    if isnan(Qbep)
        # an efficiency curve was not provided, and so we must determine Qbep from the head
        # curve
        if size(head_curve)[1] == 1
            Qbep = head_curve[1,1]
            Gbep = head_curve[1,2]
        else
            A = hcat(head_curve[:,1].^2, ones(size(head_curve,1)))
            a, c = A\head_curve[:,2]
            Gbep = c/Gh0
            Qbep = sqrt((1 - Gh0)*Gbep/a)
        end    
    else
        if size(head_curve)[1] == 1
            # probably rare that there is an efficiency curve and single-point or no head
            # curve -- nonetheless, it is a corner case that may be worth investigating
            # because Qbep would be overdetermined, and the two values may not agree
            #Qbep_alt = head_curve[1,1]
            Gbep = head_curve[1,2]
        else
            # again, we could determine Qbep from the head curve and check wether it agrees
            # with the value determined from the efficiency curve -- will presume that the
            # one from the efficiency curve is more accurate
            A = (1 - Gh0)/Qbep^2*head_curve[:,1].^2 .+ Gh0
            Gbep = A\head_curve[:,2]
        end
    end

    # Power at the BEP
    Pbep = density*gravity/(etabep/100)*Gbep*Qbep
    
    return Qbep, etabep, Gbep, Pbep
end


"""
Convert an array of tuples to a 2D array. Presumes that the tuples are all the same
length and type (there is currently no check).
"""
function array_from_tuples(T)
    m = length(T)
    n = length(T[1])
    typename = typeof(T[1][1])
    A = Array{typename}(undef, (m,n))
    for i in 1:m
        for j in 1:n
            A[i,j] = T[i][j]
        end
    end
    return A
end

# function PumpPowerCoefs_Flow(wn_dict::Dict{Any,Any}, flow::Dict{String,Array{Float64,1}}, power::Dict{String,Array{Float64,1}})
#     aPumpPower = Dict{String,Float64}()
#     bPumpPower = Dict{String,Float64}()
#     for (name, pump) in wn_dict["pumps"]
#         coef = linear_fit(flow[name], power[name])
#         aPumpPower[name] = coef[1]
#         bPumpPower[name] = coef[2]
#         if bPumpPower[name] * minimum(flow[name]) + aPumpPower[name] < 0.0
#             aPumpPower[name], bPumpPower[name] = linear_fit([maximum(flow[name]), minimum(flow[name])], [maximum(power[name]), minimum(power[name])])
#         end
#     end
#     return(aPumpPower, bPumpPower)
# end

# function PumpPowerCoefs_Head(wn_dict::Dict{Any,Any},head::Dict{String,Array{Float64,1}}, power::Dict{String,Array{Float64,1}})
#     aPumpPower = Dict{String,Float64}()
#     bPumpPower = Dict{String,Float64}()
#     for (name, pump) in wn_dict["pumps"]
#         coef = linear_fit(head[name], power[name])
#         aPumpPower[name] = coef[1]
#         bPumpPower[name] = coef[2]
#         if bPumpPower[name] * minimum(head[name]) + aPumpPower[name] < 0.0
#             aPumpPower[name], bPumpPower[name] = linear_fit([maximum(head[name]), minimum(head[name])], [maximum(power[name]), minimum(power[name])])
#         end
#     end
#     return(aPumpPower, bPumpPower)
# end
