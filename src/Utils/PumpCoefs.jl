
function FlowHeadPower(wn_dict::Dict{Any,Any})
    g = 9.81
    rho = 1000
    for (name, pump) in wn_dict["pumps"]
        eff_curve = pump["efficiency"]
        if pump["pump_type"] == "HEAD"
            pump_curve_name = pump["pump_curve_name"]
            pump_curve = wn["curves"][pump_curve_name]["points"]
        else
            pump_curve = [(pump["power"],0.0)] #power pump types gives fixed power value,
            #0 is dummy variable to fit tuple type until we decide what we want to do
        end
        flow = Array{Float64}(length(pump_curve))
        power = Array{Float64}(length(pump_curve))
        head = Array{Float64}(length(pump_curve))
        if eff_curve != None
            Q = Array{Float64}(length(eff_curve))
            eff = Array{Float64}(length(eff_curve))
            for i = 1:length(eff_curve)
                Q[i] = eff_curve[i][1]
                eff[i] = eff_curve[i][2]/100 #percentage
            end
            coefs = poly_fit(Q, eff, 3)
            f(Q) = coefs[1] + coefs[2]*Q + coefs[3] * Q^2 +coefs[4] * Q^3

            for i = 1:length(pump_curve)
                if pump_curve[i] != 0
                    flow[i] = pump_curve[i][1]
                    head[i] = pump_curve[i][2]

                    if pump_curve[i][1] <= eff_curve[length(eff_curve)-1][1]
                        eff = f(flow[i])
                    else
                        back = 1
                        while pump_curve[i - back][1] > eff_curve[length(eff_curve)-1][1]
                            back = back +1
                            eff = f(pump_curve[i-back][1])
                        end
                    end
                power[i] = (1e-3 *rho * g * flow[i] * head[i]/eff)

            elseif wn_dict["options"]["energy"]["global_efficiency"] != None
                eff_global = wn_dict["options"]["energy"]["global_efficiency"]
                for j = 1:length(pump_curve)
                    flow[i] = pump_curve[i][1]
                    head[i] = pump_curve[i][2]
                    power[i] = 1e-3 * rho *g * flow[i] *head[i]/eff
                end
            else
                eff_gloabl = 0.65
                for j = 1:length(pump_curve)
                    flow[i] = pump_curve[i][1]
                    head[i] = pump_curve[i][2]
                    power[i] = 1e-3 * rho *g * flow[i] * head[i]/eff
                end
            end
        end
    end
    return(flow, power, head)
end

function PumpPowerCoefs_Flow(flow::Array{Float64}, power::Array{Float64}, aPumpPower::Dict{String,Float64}, bPumpPower::Dict{String,Float64})
    coef = linear_fit(flow, power)
    aPumpPower[name] = coef[1]
    bPumpPower[name] = coef[2]
    if bPumpPower[name] * minimum(flow) + aPumpPower[name] <0
        aPumpPower[name], bPumpPower[name] = linear_fit([maximum(flow), minimum(flow)], [maximum(power), minimum(power)])
    end
    return(aPumpPower, bPumpPower)
end

function PumpPowerCoefs_Head(flow::Array{Float64}, head::Array{Float64}, aPumpPower::Dict{String,Float64}, bPumpPower::Dict{String,Float64})
    coef = linear_fit(head, power)
    aPumpPower[name] = coef[1]
    bPumpPower[name] = coef[2]
    if bPumpPower[name] * minimum(head) + aPumpPower[name] <0
        aPumpPower[name], bPumpPower[name] = linear_fit([maximum(head), minimum(head)], [maximum(power), minimum(power)])
    end
    return(aPumpPower, bPumpPower)
end
