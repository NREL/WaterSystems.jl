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
    return wntr_dict
end

function link_dicts(wntr_dict::Dict{Any, Any})
    links = wntr_dict["links"]
    pipe_dict = Dict{Int64,Any}()
    valves = Vector{Any}()
    pumps = Vector{Any}()
    control_pipe = Array{Union{Nothing,String}}(nothing,0)
    for (i, (name,control)) in enumerate(wntr_dict["controls"])
        target = control._then_actions[1]._target_obj
        target.link_type == "Pipe" ? push!(control_pipe, target.name) : nothing
    end
    l = 0
    for link in links
        if link["link_type"] == "Pipe"
            l = l + 1
            pipe_dict[l] = link
            pipe_dict[l]["control_pipe"] = link["name"] in control_pipe
        elseif link["link_type"] == "Pump"
            push!(pumps, link)
        else
            push!(valves,link)
        end
    end
    wntr_dict["pipes"] = pipe_dict
    wntr_dict["valves"] = valves
    wntr_dict["pumps"] = pumps
end

function node_dicts(wntr_dict::Dict{Any,Any})
    nodes = wntr_dict["nodes"]
    junctions= Vector{Any}()
    tanks =  Vector{Any}() # TODO: Does this need to be a dict?
    reservoirs= Vector{Any}() # TODO: Does this need to be a dict?
    for node in nodes
        if node["node_type"] == "Junction"
            push!(junctions, node)
        elseif node["node_type"] == "Tank"
            push!(tanks, node)
        else
            push!(reservoirs, node)
        end
    end
    wntr_dict["junctions"] = junctions
    wntr_dict["tanks"] = tanks
    wntr_dict["reservoirs"] = reservoirs
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

