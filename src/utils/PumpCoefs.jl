const gravity = 9.81 # m/s^2
const density = 1000.0 # kg/m^3

"""
Estimate single-point head curve for a bump of 'POWER' type in the .inp file. 
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
Compute the pump parameters for normalized pump curves -- in progress
"""
function norm_pump_params(pump::Dict{String,Any}, c_dict::Dict{String,Curve})

    if pump["efficiency"] isa String
        eff_curve_tuples = c_dict[pump["efficiency"]]
        eff_curve = [[T[1], T[2]/100] for T in eff_curve_tuples]

         # fit efficiency curve to determine Qbep and etabep
        A = hcat(eff_curve[:,1].^2, eff_curve[:,1])
        a, b = A\effcurve[:,2]
        Qbep = -0.5*b/a
        etabep = -0.25*b^2/a
    else
        # presume the single-value for efficiency is at the BEP
        etabep = pump["efficiency"]

        #### then we need to determine Qbep from the head curve!!! algebra TBD, JJS 12/29/19
    end
        
#     head_curve_tuples = c_dict[pump["head_curve_name"]]
# #    if 
#     f(Q) = coefs[1] + coefs[2]*Q + coefs[3] * Q^2 +coefs[4] * Q^3
#     for i = 1:length(pump_curve)
#         if pump_curve[i] != 0
#             flow[i] = pump_curve[i][1]
#             head[i] = pump_curve[i][2]
            
#             if pump_curve[i][1] <= eff_curve[length(eff_curve)][1]
#                 eff[i] = f(flow[i])
#             else
#                 back = 1
#                 while pump_curve[i - back][1] > eff_curve[length(eff_curve)][1]
#                     back = back +1
#                     eff[i] = f(pump_curve[i-back][1])
#                 end
#             end
#             power[i] = (1e-3 *rho * g * flow[i] * head[i]/eff[i])
#         end
#     end
#         for j = 1:length(pump_curve)
#             eff = eff_curve
#             flow[j] = pump_curve[j][1]
#             head[j] = pump_curve[j][2]
#             power[j] = 1e-3 * rho *g * flow[j] *head[j]/eff
            
#         end
#     end
#     flow_dict[name] = flow
#     head_dict[name] = head
#     power_dict[name] = power
#     return(flow_dict, head_dict, power_dict)
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
