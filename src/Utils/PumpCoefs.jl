function FlowHeadPower(wn_dict::Dict{Any,Any})
    g = 9.81
    rho = 1000
    flow_dict = Dict{String, Array{Float64,1}}()
    power_dict = Dict{String, Array{Float64,1}}()
    head_dict = Dict{String, Array{Float64,1}}()
    for (name, pump) in wn_dict["pumps"]
        eff_curve = nothing
        if pump["pump_type"] == "HEAD"
            pump_curve_name = pump["pump_curve_name"]
            pump_curve = wn_dict["curves"][pump_curve_name]["points"]
        else
            pump_curve = [(pump["power"],0.0)] #power pump types gives fixed power value,
            #0 is dummy variable to fit tuple type until we decide what we want to do
        end

        try
            eff_curve = pump["efficiency"][:points]
        catch
            wn_dict["options"]["energy"]["global_efficiency"] != nothing ? eff_curve = wn_dict["options"]["energy"]["global_efficiency"]: eff_curve = 0.65
        end
        len = max(length(pump_curve), length(eff_curve))
        flow = Array{Float64}(length(pump_curve))
        power = Array{Float64}(length(pump_curve))
        head = Array{Float64}(length(pump_curve))
        if length(eff_curve) > 1
            Q = Array{Float64}(length(eff_curve))
            eff = Array{Float64}(len)
            for i = 1:length(eff_curve)
                Q[i] = eff_curve[i][1]
                eff[i] = eff_curve[i][2]/100 #percentage
            end
            coefs = poly_fit(Q, eff[1:length(eff_curve)], 3)
            f(Q) = coefs[1] + coefs[2]*Q + coefs[3] * Q^2 +coefs[4] * Q^3
            for i = 1:length(pump_curve)
                if pump_curve[i] != 0
                    flow[i] = pump_curve[i][1]
                    head[i] = pump_curve[i][2]

                    if pump_curve[i][1] <= eff_curve[length(eff_curve)][1]
                        eff[i] = f(flow[i])
                    else
                        back = 1
                        while pump_curve[i - back][1] > eff_curve[length(eff_curve)][1]
                            back = back +1
                            eff[i] = f(pump_curve[i-back][1])
                        end
                    end
                    power[i] = (1e-3 *rho * g * flow[i] * head[i]/eff[i])
                end
            end
        else
            for j = 1:length(pump_curve)
                eff = eff_curve
                flow[j] = pump_curve[j][1]
                head[j] = pump_curve[j][2]
                power[j] = 1e-3 * rho *g * flow[j] *head[j]/eff

            end
        end
        flow_dict[name] = flow
        head_dict[name] = head
        power_dict[name] = power
    end
    return(flow_dict, head_dict, power_dict)
end

function PumpPowerCoefs_Flow(wn_dict::Dict{Any,Any}, flow::Dict{String,Array{Float64,1}}, power::Dict{String,Array{Float64,1}})
    aPumpPower = Dict{String,Float64}()
    bPumpPower = Dict{String,Float64}()
    for (name, pump) in wn_dict["pumps"]
        coef = linear_fit(flow[name], power[name])
        aPumpPower[name] = coef[1]
        bPumpPower[name] = coef[2]
        if bPumpPower[name] * minimum(flow[name]) + aPumpPower[name] < 0.0
            aPumpPower[name], bPumpPower[name] = linear_fit([maximum(flow[name]), minimum(flow[name])], [maximum(power[name]), minimum(power[name])])
        end
    end
    return(aPumpPower, bPumpPower)
end

function PumpPowerCoefs_Head(wn_dict::Dict{Any,Any},head::Dict{String,Array{Float64,1}}, power::Dict{String,Array{Float64,1}})
    aPumpPower = Dict{String,Float64}()
    bPumpPower = Dict{String,Float64}()
    for (name, pump) in wn_dict["pumps"]
        coef = linear_fit(head[name], power[name])
        aPumpPower[name] = coef[1]
        bPumpPower[name] = coef[2]
        if bPumpPower[name] * minimum(head[name]) + aPumpPower[name] < 0.0
            aPumpPower[name], bPumpPower[name] = linear_fit([maximum(head[name]), minimum(head[name])], [maximum(power[name]), minimum(power[name])])
        end
    end
    return(aPumpPower, bPumpPower)
end
