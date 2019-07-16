#This splits the wntr dictionary (links, nodes) into its sub compononents 
function wntr_dict(inp_file::String)
    wn = model.WaterNetworkModel(inp_file)
    wns =  sim.EpanetSimulator(wn)
    results = wns.run_sim()
    node_results = results.node #dictionary of head, pressure, demand, quality
    link_results = results.link #dictionary of status, flowrate, velocity, {headloss, setting, friciton factor, reaction rate, link quality} = epanet simulator only
    wntr_dict = wn.todict()
    node_dicts(wntr_dict)
    link_dicts(wntr_dict)
    curves_dict(wntr_dict)
    wntr_dict["node_results"] = node_results
    wntr_dict["link_results"] = link_results
<<<<<<< HEAD
=======
    wntr_dict["wn"] = wn

    curves_dict(wntr_dict)
    wntr_dict = convert(Dict{String,Any}, wntr_dict) # TODO: this is hacky and shouldn't be required, fix this by creating the correct dict from the wntr call
>>>>>>> update-build
    return wntr_dict
end

function link_dicts(wntr_dict::Dict{Any, Any})
    links = wntr_dict["links"]
    pipe_dict = Dict{Int64, Any}()
    valve_dict = Dict{Int64, Any}()
    pump_dict = Dict{Int64, Any}()
    control_pipe = Array{Union{Nothing,String}}(nothing,0)
    for (i, (name,control)) in enumerate(wntr_dict["controls"])
        target = control._then_actions[1]._target_obj
        target.link_type == "Pipe" ? push!(control_pipe, target.name) : nothing
    end
    l = 0
    m = 0
    n = 0
    for link in links
        if link["link_type"] == "Pipe"
            l = l + 1
            pipe_dict[l] = link
            pipe_dict[l]["control_pipe"] = link["name"] in control_pipe
        elseif link["link_type"] == "Pump"
            m = m + 1
            pump_dict[m] = link
        else
            n = n + 1
            valve_dict[n] = link
        end
    end
    wntr_dict["pipes"] = pipe_dict
    wntr_dict["valves"] = valve_dict
    wntr_dict["pumps"] = pump_dict
end

function node_dicts(wntr_dict::Dict{Any,Any})
    nodes = wntr_dict["nodes"]
    junction_dict= Dict{Int64, Any}()
<<<<<<< HEAD
    tank_dict = Dict{Int64, Any}()
    reservoir_dict = Dict{Int64, Any}()
    i = 0
    j = 0
    k = 0
    for node in nodes
        name = node["name"]
=======
    tank_dict = Dict{Int64, Any}() # can this be 
    reservoir_dict = Dict{Int64, Any}()
    nodes_name = Dict{Int64,Any}()
    for (n,node) in enumerate(nodes)
        nodes_name[n] = node
>>>>>>> update-build
        if node["node_type"] == "Junction"
            i = i + 1
            junction_dict[i] = node
        elseif node["node_type"] == "Tank"
            j = j + 1
            tank_dict[j] = node
        else
            k = k + 1
            reservoir_dict[k] = node
            #reservoir_dict[k]["elevation"] = reservoir_dict[k]["base_head"]
        end
    end
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

