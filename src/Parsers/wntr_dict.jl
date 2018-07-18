@pyimport wntr.network.model as model #import wntr network model
@pyimport wntr.sim.epanet as sim

function wntr_dict(inp_file::String)
    wn = model.WaterNetworkModel(inp_file)
    wns =  sim.EpanetSimulator(wn)
    results = wns[:run_sim]()
    node_results = results[:node] #dictionary of head, pressure, demand, quality
    link_results = results[:link] #dictionary of status, flowrate, velocity, {headloss, setting, friciton factor, reaction rate, link quality} = epanet simulator only
    wntr_dict = wn[:todict]()
    nodes = wntr_dict["nodes"]
    links = wntr_dict["links"]
    node_dicts(nodes, wntr_dict)
    link_dicts(links, wntr_dict)
    wntr_dict["node_results"] = node_results
    wntr_dict["link_results"] = link_results
    wntr_dict["wn"] = wn

    curves_dict(wntr_dict)
    return wntr_dict
end

function link_dicts(links::Array{Dict{Any, Any},1}, wntr_dict::Dict{Any, Any})
    pipe_dict = Dict{Int64, Any}()
    valve_dict = Dict{Int64, Any}()
    pump_dict = Dict{Int64, Any}()
    l = 0
    m = 0
    n = 0
    for link in links
        if link["link_type"] == "Pipe"
            l = l + 1
            pipe_dict[l] = link
        elseif link["link_type"] == "Pump"
            m = m + 1
            pump_dict[m] = link
            if pump_dict[m]["efficiency"] == nothing
                # warn("Pump efficiency is 0. Default will be 65% for pump $pump.")
                pump_dict[m]["efficiency"] = 0.65
            end
        else
            n = n + 1
            valve_dict[n] = link
        end
    end
    wntr_dict["num_pipes"] = l
    wntr_dict["num_pumps"] = m
    wntr_dict["num_valves"] = n
    wntr_dict["pipes"] = pipe_dict
    wntr_dict["valves"] = valve_dict
    wntr_dict["pumps"] = pump_dict
end

function node_dicts(nodes::Array{Dict{Any, Any},1}, wntr_dict::Dict{Any,Any})
    junction_dict= Dict{Int64, Any}()
    tank_dict = Dict{Int64, Any}()
    reservoir_dict = Dict{Int64, Any}()
    i = 0
    j = 0
    k = 0
    for node in nodes
        if node["node_type"] == "Junction"
            i = i+1
            junction_dict[i] = node
        elseif node["node_type"] == "Tank"
            j = j + 1
            tank_dict[j] = node
        else
            k = k + 1
            reservoir_dict[k] = node
        end
    end
    wntr_dict["num_junctions"] = i
    wntr_dict["num_tanks"] = j
    wntr_dict["num_reservoirs"] = k
    wntr_dict["junctions"] = junction_dict
    wntr_dict["tanks"] = tank_dict
    wntr_dict["reservoirs"] = reservoir_dict
end

function curves_dict(wntr_dict::Dict{Any,Any})
    curves = wntr_dict["curves"]
    curves_dict = Dict{String,Any}()
    for curve in curves
        curves_dict[curve["name"]] = curve
    end
    delete!(wntr_dict, "curves")
    wntr_dict["curves"] = curves_dict
end
