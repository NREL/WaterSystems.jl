function LeastSquares(name::String, wn_dict::Dict{Any,Any}, wn::PyCall.PyObject, link_results::Dict{Any,Any}, node_results::Dict{Any,Any}, num_timesteps::Int64)
    energy = metric.pump_energy(link_results["flowrate"], node_results["head"], wn)[name][:values][1:num_timesteps]
    flow = link_results["flowrate"][name][:values][1:num_timesteps]
    flows = Array{Float64}(0)
    energies = Array{Float64}(0)
    for i= 1:length(energy)
        if energy[i] != 0 && flow[i] !=0
            flows = vcat(flows,flow[i])
            energies = vcat(energies, energy[i])
        end
    end
    #if pump never turns on, delete control that inhibits pump, calulation energy, then replace control
    if length(energies) == 0
        # warn("$name does not turn on. Ajusting controls to allow for turn on of pump.")
        controls_dict = wn_dict["controls"]
        control_info = Array{PyCall.PyObject}(0)
        control_names = Array{String}(0)
        for control in keys(controls_dict)
            push!(control_info, controls_dict[control])
            push!(control_names, control)
            wn[:remove_control](control)
        end
        wns = sim.EpanetSimulator(wn) #Simulation either Demand Driven(DD) or Presure Dependent Demand(PDD), default DD
        results = wns[:run_sim]()
        node_results = results[:node] #dictionary of head, pressure, demand, quality
        link_results = results[:link]
        energy = metric.pump_energy(link_results["flowrate"], node_results["head"], wn)[name][:values][1:num_timesteps]
        flow = link_results["flowrate"][name][:values][1:num_timesteps]
        flows = Array{Float64}(0)
        energies = Array{Float64}(0)
        for i= 1:length(energy)
            if energy[i] != 0 && flow[i] !=0
                flows = vcat(flows,flow[i])
                energies = vcat(energies, energy[i])
            end
        end
        for (ix, control) in enumerate(control_names)
            wn[:add_control](control, control_info[ix])
        end
    end

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
