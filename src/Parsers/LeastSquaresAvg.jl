function slope_intercept(wn_dict::Dict{Any,Any}, wn::PyCall.PyObject, link_results::Dict{Any,Any}, node_results::Dict{Any,Any}, num_timesteps::Int64)
    slopes = Dict{Int64,Any}()
    intercepts = Dict{Int64, Any}()
    pump_off = Array{Int64}(0)
    slope_sum = 0
    intercept_sum = 0
    count = 0
    for (key, pump) in wn_dict["pumps"]
        name = pump["name"]
        @time energy = metric.pump_energy(link_results["flowrate"], node_results["head"], wn)[name][:values][1:num_timesteps]
        flow = link_results["flowrate"][name][:values][1:num_timesteps]
        flows = Array{Float64}(0)
        energies = Array{Float64}(0)
        for i= 1:length(energy)
            if energy[i] != 0 && flow[i] !=0
                flows = vcat(flows,flow[i])
                energies = vcat(energies, energy[i])
            end
        end
        if length(energies) != 0
            count = count +1
            intercept, slope = LeastSquares(flows, energies)
            slopes[key] = slope
            intercepts[key] = intercept
            slope_sum = slope_sum + slope
            intercept_sum = intercept_sum + intercept
        else
            push!(pump_off, key)
        end
    end

    avg_slope = slope_sum/count
    avg_intercept = intercept_sum/count
    for key in pump_off
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
