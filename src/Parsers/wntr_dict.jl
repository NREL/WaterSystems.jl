metric = pyimport("wntr.metrics.economic")
model = pyimport("wntr.network.model") #import wntr network model
sim = pyimport("wntr.sim.epanet")
function wntr_dict(inp_file::String)
    wn = model.WaterNetworkModel(inp_file)
    wns =  sim.EpanetSimulator(wn)
    results = wns.run_sim()
    node_results = results.node #dictionary of head, pressure, demand, quality
    link_results = results.link #dictionary of status, flowrate, velocity, {headloss, setting, friciton factor, reaction rate, link quality} = epanet simulator only
    wntr_dict = wn.todict()
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
    pump_dict = Dict{String, Any}()
    control_pipe = Array{Union{Nothing,String}}(nothing,0)
    for (i, (name,control)) in enumerate(wntr_dict["controls"])
        target = control._then_actions[1]._target_obj
        target.link_type == "Pipe" ? push!(control_pipe, target.name) : nothing
    end
    for link in links
        name = link["name"]
        if link["link_type"] == "Pipe"
            l = length(pipe_dict) + 1
            pipe_dict[l] = link
            pipe_dict[l]["control_pipe"] = link["name"] in control_pipe
        elseif link["link_type"] == "Pump"
            pump_dict[name] = link
        else
            n = length(valve_dict) + 1
            valve_dict[n] = link
        end
    end
    wntr_dict["num_pipes"] = length(pipe_dict)
    wntr_dict["num_pumps"] = length(pump_dict)
    wntr_dict["num_valves"] = length(valve_dict)
    wntr_dict["pipes"] = pipe_dict
    wntr_dict["valves"] = valve_dict
    wntr_dict["pumps"] = pump_dict
end

function node_dicts(nodes::Array{Dict{Any, Any},1}, wntr_dict::Dict{Any,Any})
    junction_dict= Dict{Int64, Any}()
    tank_dict = Dict{String, Any}()
    reservoir_dict = Dict{Int64, Any}()
    nodes_name = Dict{String,Any}()
    for node in nodes
        name = node["name"]
        nodes_name[name] = node
        if node["node_type"] == "Junction"
            i = length(junction_dict) + 1
            junction_dict[i] = node
        elseif node["node_type"] == "Tank"
            tank_dict[name] = node
        else
            k = length(reservoir_dict) + 1
            reservoir_dict[k] = node
            reservoir_dict[k]["elevation"] = reservoir_dict[k]["base_head"]
        end
    end
    delete!(wntr_dict, "nodes")
    wntr_dict["nodes"] = nodes_name
    wntr_dict["num_junctions"] = length(junction_dict)
    wntr_dict["num_tanks"] = length(tank_dict)
    wntr_dict["num_reservoirs"] = length(reservoir_dict)
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
