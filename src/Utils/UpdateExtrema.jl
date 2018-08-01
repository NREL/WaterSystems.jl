@pyimport wntr.network.controls as controls
@pyimport wntr.sim.epanet as sims
function UpdateExtrema(wn::PyCall.PyObject, wn_dict::Dict{Any,Any}, Qmax_dict::Dict{String, Float64},
                        Qmin_dict::Dict{String,Float64}, Hmax_dict::Dict{String, Float64},
                        Hmin_dict::Dict{String,Float64}, num_sim::Int64, sim::Int64,
                        tight_coef::Float64, Q_lb::Float64)
    link_results, node_results = run_sims(wn)
    UpdateFlowRange(wn, wn_dict, link_results, node_results, Qmax_dict, Qmin_dict, num_sim, sim, tight_coef, Q_lb)
    UpdateHeadRange(wn_dict, Hmax_dict, Hmin_dict, link_results, node_results)
end

function run_sims(wn::PyCall.PyObject)
    wns = sims.EpanetSimulator(wn)
    results = wns[:run_sim]()
    link_results = results[:link]
    node_results = results[:node]
    return link_results, node_results
end
function UpdateFlowRange(wn::PyCall.PyObject, wn_dict::Dict{Any,Any},
                    link_results::Dict{Any,Any}, node_results::Dict{Any,Any},
                    Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64},
                    num_sim::Int64, sim::Int64, tight_coef::Float64, Q_lb::Float64)

    pipes = wn_dict["pipes"]
    valves = wn_dict["valves"]
    links = merge(pipes, valves)
    for (key, link) in links
        name = link["name"]
        flows = link_results["flowrate"][name][:values]
        convert(Array{Float64}, flows)
        if sim == 1
            Qmin_dict[name] = convert(Float64,minimum(flows))
            Qmax_dict[name] = convert(Float64, maximum(flows))
        elseif sim < num_sim
            Qmin = Qmin_dict[name]
            Qmax = Qmax_dict[name]

            Qmin_dict[name] = minimum([Qmin, minimum(flows)])
            Qmax_dict[name] = maximum([Qmax, maximum(flows)])
        else
            Qmax_val = Qmax_dict[name]
            Qmin_val = Qmin_dict[name]
            gap = Qmax_val - Qmin_val
            if Qmin_val <= 0
                Qmin_dict[name] = Qmin_val - tight_coef*gap
            else
                Qmin_dict[name] = minimum([Q_lb, Qmin_val])
            end
            if Qmax_val >= 0
                Qmax_dict[name] = Qmax_val + tight_coef*gap
            else
                Qmax_dict[name] = maximum([Qmax_val, -Q_lb])
            end
        end
    end

    for (key, pump) in wn_dict["pumps"]
        name = pump["name"]
        flow = link_results["flowrate"][name][:values]
        convert(Array{Float64}, flow)
        if sim != 1
            flow = flow[flow .> 0]
        end

        if length(flow) !=0 || sim == num_sim
            if sim == 1
                Qmin_dict[name] = minimum(flow)
                Qmax_dict[name]= maximum(flow)
            elseif sim < num_sim
                Qmax = Qmax_dict[name]
                Qmin = Qmin_dict[name]
                Qmin_dict[name] = minimum([Qmin, minimum(flow)])
                Qmax_dict[name] = maximum([Qmax, maximum(flow)])
            else
                Qmin_val = Qmin_dict[name]
                Qmax_val = Qmax_dict[name]

                gap = Qmax_val - Qmin_val
                if pump["pump_type"] == "HEAD"
                    pump_curve_name = pump["pump_curve_name"]
                    pump_curve = wn_dict["curves"][pump_curve_name]["points"]
                else
                    pump_curve = [(pump["power"],0.0)] #power pump types gives fixed power value,
                end

                Qmin_dict[name] = maximum([pump_curve[1][1], Qmin_val - tight_coef*gap])
                Qmax_dict[name] = minimum([pump_curve[length(pump_curve)][1], Qmax_val + tight_coef*gap])
            end
        end
    end
end

function UpdateHeadRange(wn_dict::Dict{Any,Any}, Hmax_dict::Dict{String, Float64},
                        Hmin_dict::Dict{String,Float64}, link_results::Dict{Any,Any},
                        node_results::Dict{Any,Any})
    pumps = wn_dict["pumps"]
    nodes = wn_dict["nodes"]
    for (key, pump) in pumps
        name1 = pump["start_node_name"]
        elev1 = nodes[name1]["elevation"]

        name2 = pump["end_node_name"]
        elev2 = nodes[name2]["elevation"]

        pump_head = (node_results["pressure"][name2][:values] + elev2) - (node_results["pressure"][name1][:values] + elev1)
        pump_status = link_results["status"][key][:values]

        pump_head = pump_head .* pump_status #only care about head when pump is on
        pump_head = pump_head[pump_head .> 0]

        if length(pump_head) > 0
            try
                Hmin_dict[key] = min(minimum(pump_head), Hmin_dict[key])
                Hmax_dict[key] = max(maximum(pump_head), Hmax_dict[key])
            catch
                Hmin_dict[key] = minimum(pump_head)
                Hmax_dict[key] = maximum(pump_head)
            end
        end
    end
    return Hmin_dict, Hmax_dict
end
