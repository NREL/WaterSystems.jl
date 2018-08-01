function slope_intercept(wn_dict::Dict{Any,Any}, wn::PyCall.PyObject, link_results::Dict{Any,Any}, node_results::Dict{Any,Any}, num_timesteps::Int64)
    slopes = Dict{String,Any}()
    intercepts = Dict{String, Any}()
    pump_off = Dict{String, Any}()
    slope_sum = 0
    intercept_sum = 0
    count = 0
    for (key, pump) in wn_dict["pumps"]
        name = pump["name"]
        flow = link_results["flowrate"][name][:values][1:num_timesteps]
        headloss = link_results["headloss"][name][:values][1:num_timesteps]
        efficiency = nothing
        try
            efficiency = pump["efficiency"][:points]
        catch
            wn_dict["options"]["energy"]["global_efficiency"] != nothing ? efficiency = wn_dict["options"]["energy"]["global_efficiency"]: efficiency = 0.65
        end
        if length(efficiency) > 1
            energy = [((1000.0 * 9.81 * headloss[i] * flow[i])/efficiency[1][1]) for i = 1:num_timesteps]
        else
            energy = [((1000.0 * 9.81 * headloss[i] * flow[i])/efficiency) for i = 1:num_timesteps]
        end
        flows = Array{Float64}(0)
        energies = Array{Float64}(0)
        for i= 1:length(energy)
            if energy[i] != 0.0 && flow[i] != 0.0
                flows = vcat(flows,flow[i])
                energies = vcat(energies, energy[i])
            end
        end
        if length(energies) != 0.0
            count = count +1
            intercept, slope = LeastSquares(flows, energies)
            slopes[key] = slope
            intercepts[key] = intercept
            slope_sum = slope_sum + slope
            intercept_sum = intercept_sum + intercept
        else
            pump_off[key] = key
        end
    end

    avg_slope = slope_sum/count
    avg_intercept = intercept_sum/count
    for (key, name) in pump_off
        slopes[key] = avg_slope
        intercepts[key] = avg_intercept
    end
    return slopes, intercepts
end

function LeastSquares(flows::Array{Float64}, energies::Array{Float64})
    #if pump never turns on, delete control that inhibits pump, calulation energy, then replace control
        avg_energy = mean(energies)
        a, b = linear_fit(flows, energies)
        error = Array{Float64}(0)
        for i = 1:length(energies)
            push!(error, energies[i] - (avg_energy +b *flows[i]))
        end
        avg_error = mean(error)
        intercept = avg_energy + avg_error
        return intercept, b
    # total_error = energies - (intercept + b * flows)
end
