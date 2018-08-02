function dict_to_struct(data::Dict{String,Any})
    haskey(data, "Junction") ? junctions = junction_to_struct(data["Junction"]) : warn("Key Error : key 'Junction' not found in WaterSystems dictionary, this will result in an empty Junction array")
    haskey(data, "Node") ? nodes = node_to_struct(data["Node"]) : warn("Key Error : key 'Node' not found in WaterSystems dictionary, this will result in an empty Node array")
    haskey(data, "Tank") ? tanks = tank_to_struct(data["Tank"]) : warn("Key Error : key 'Tank' not found in WaterSystems dictionary, this will result in an empty Tank array")
    haskey(data, "Reservoir") ? res = res_to_struct(data["Reservoir"]) : warn("Key Error : key 'Reservoir' not found in WaterSystems dictionary, this will result in an empty Reservoir array")
    haskey(data, "Pipe") ? pipes = pipe_to_struct(data["Pipe"]) : warn("Key Error : key 'Pipe' not found in WaterSystems dictionary, this will result in an empty Pipe array")
    haskey(data, "Valve") ? valves = valve_to_struct(data["Valve"]) : warn("Key Error : key 'Valve' not found in WaterSystems dictionary, this will result in an empty Valve array")
    haskey(data, "Pump") ? pumps = pump_to_struct(data["Pump"]) : warn("Key Error : key 'Pump' not found in WaterSystems dictionary, this will result in an empty Pump array")
    haskey(data, "demand") ? demands = demand_to_struct(data["demand"]) : warn("Key Error : key 'demand' not found in WaterSystems dictionary, this will result in an empty demand array")
    d = data["wntr"]
    simulations = Simulation(d["duration"], d["timeperiods"], d["num_timeperiods"], d["start"], d["end"])
    links = vcat(pipes, valves, pumps)
    return nodes, junctions, tanks, res, links, pipes, valves, pumps, demands, simulations
end
function dict_to_struct(data::Dict{String,Any}, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64, tight_coef::Float64)
    haskey(data, "Junction") ? junctions = junction_to_struct(data["Junction"]) : warn("Key Error : key 'Junction' not found in WaterSystems dictionary, this will result in an empty Junction array")
    haskey(data, "Node") ? nodes = node_to_struct(data["Node"]) : warn("Key Error : key 'Node' not found in WaterSystems dictionary, this will result in an empty Node array")
    haskey(data, "Tank") ? tanks = tank_to_struct(data["Tank"]) : warn("Key Error : key 'Tank' not found in WaterSystems dictionary, this will result in an empty Tank array")
    haskey(data, "Reservoir") ? res = res_to_struct(data["Reservoir"]) : warn("Key Error : key 'Reservoir' not found in WaterSystems dictionary, this will result in an empty Reservoir array")
    haskey(data, "Valve") ? valves = valve_to_struct(data["Valve"]) : warn("Key Error : key 'Valve' not found in WaterSystems dictionary, this will result in an empty Valve array")
    haskey(data, "demand") ? demands = demand_to_struct(data["demand"]) : warn("Key Error : key 'demand' not found in WaterSystems dictionary, this will result in an empty demand array")
    haskey(data, "wntr_dict") ? parameters = parameter_to_struct(data["wntr_dict"], n, Q_lb, logspace_ratio, dH_critical, dense_coef, tight_coef) : warn("Key Error : key 'wntr_dict' not found in WaterSystems dictionary, this will result in an empty demand array")
    d = data["wntr"]
    aPipe_over, bPipe_over, aPipe_under, bPipe_under, Q_baseP, aValve_over, bValve_over,
    aValve_under, bValve_under, Q_base_cv, PositiveFlowLinks, NegativeFlowLinks, ReversibleFlowLinksflow,
    flow, head, power, aPumpPower_flow, bPumpPower_flow, aPumpPower_head, bPumpPower_head = Parameterize(wn_dict, n, Q_lb, logspace_ratio, dH_critical, dense_coef, tight_coef)
    if haskey(data, "Pipe")
        pipes = pipe_to_struct_parameters(data["Pipe"], aPipe_over, bPipe_over, aPipe_under, bPipe_under, Q_baseP, aValve_over, bValve_over,
        aValve_under, bValve_under, Q_base_cv, PositiveFlowLinks, NegativeFlowLinks, ReversibleFlowLinksflow)
    else
        warn("Key Error : key 'Pipe' not found in WaterSystems dictionary, this will result in an empty Pipe array")
    end
    if haskey(data, "Pump")
        pumps = pump_to_struct_parameters(data["Pump"], flow, head, power, aPumpPower_flow, bPumpPower_flow, aPumpPower_head, bPumpPower_head)
    else
        warn("Key Error : key 'Pump' not found in WaterSystems dictionary, this will result in an empty Pipe array")
    end
    simulations = Simulation(d["duration"], d["timeperiods"], d["num_timeperiods"], d["start"], d["end"])
    links = vcat(pipes, valves, pumps)
    return nodes, junctions, tanks, res, links, pipes, valves, pumps, demands, simulations, parameters
end

function junction_to_struct(data::Dict{Int64,Any})
    junctions = [Junction(j["number"], j["name"], j["elevation"], j["head"], j["minimum_pressure"], j["coordinates"]) for (key,j) in data]
    return junctions
end
function node_to_struct(data::Dict{String, Any})
    nodes = [Junction(j["number"], j["name"], j["elevation"], j["head"], j["minimum_pressure"], j["coordinates"]) for (key,j) in data]
    return nodes
end

function tank_to_struct(data::Dict{Int64,Any})
    tanks = Array{RoundTank}(length(data))
    for (key, t) in data
        node = t["node"]
        junction = Junction(node["number"], node["name"], node["elevation"], node["head"], node["minimum_pressure"], node["coordinates"])
        push!(tanks, RoundTank(t["name"], junction, t["volumelimits"], t["diameter"], t["volume"], t["area"], t["level"], t["levellimits"]))
    end
    return tanks
end

function res_to_struct(data::Dict{Int64, Any})
    res = Array{Reservoir}(0)
    for (key, r) in data
        node = r["node"]
        junction = Junction(node["number"], node["name"], node["elevation"], node["head"], node["minimum_pressure"], node["coordinates"])
        push!(res, Reservoir(r["name"], junction, r["elevation"]))
    end
    return res
end

function pipe_to_struct(data::Dict{Int64,Any})
    pipes = Array{RegularPipe}(0)
    for (key, p) in data
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        if p["cv"] == false
            push!(pipes,RegularPipe(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], p["control_pipe"]))
        else
            push!(pipe, CheckValvePipe(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], p["control_pipe"]))
        end
    end
    return pipes
end
 function valve_to_struct(data::Dict{Int64, Any})
     valves = Array{PressureReducingValve}(0)
     for (key, v) in data
         #if v["valve_type"] == "PRV"
         #push!(valves, PressureReducingValve(...))
         j_from = v["connectionpoints"].from
         j_to = v["connectionpoints"].to
         junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
         junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
         push!(valves,PressureReducingValve(v["number"], v["name"], @NT(from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"]))
     end
     return valves
 end

function pump_to_struct(data::Dict{Int64,Any})
    pumps = Array{ConstSpeedPump}(0)
    for (key, p) in data
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        push!(pumps, ConstSpeedPump(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["status"], p["pumpcurve"], p["efficiency"], p["energyprice"]))
    end
    return pumps
end
function demand_to_struct(data::Dict{Int64,Any})
    demands = Array{WaterDemand}(length(data),1)
    for (key, d) in data
        node_data = d["node"]
        number = node_data["number"]
        node = Junction(number, node_data["name"], node_data["elevation"], node_data["head"], node_data["minimum_pressure"], node_data["coordinates"])
        demands[number, 1] = WaterDemand(d["name"], number, node , d["status"], d["max_demand"], d["demand"], d["demandforecast"])
    end
    return demands
end

function parameter_to_struct(wn_dict::Dict{Any,Any}, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64, tight_coef::Float64)
    aPipe_over, bPipe_over, aPipe_under, bPipe_under, aPumpPower_flow,
    bPumpPower_flow, aPumpPower_head, bPumpPower_head,aValve_over, bValve_over,
    aValve_under, bValve_under, PositiveFlowLinks, NegativeFlowLinks, ReversibleFlowLinks = Parameterize(wn_dict, n, Q_lb, logspace_ratio, dH_critical, dense_coef, tight_coef)
    parameters = Parameters(aPipe_over, bPipe_over, aPipe_under, bPipe_under,
                            aPumpPower_flow, bPumpPower_flow, aPumpPower_head,
                            bPumpPower_head,aValve_over, bValve_over,aValve_under,
                            bValve_under, PositiveFlowLinks, NegativeFlowLinks,
                            ReversibleFlowLinks)
    return parameters
end

function pipe_to_struct_parameters(data::Dict{Int64,Any}, aPipe_over:: Dict{String, Array{Float64,1}},
                                    bPipe_over::Dict{String, Array{Float64,1}}, aPipe_under::Dict{String, Array{Float64,1}},
                                    bPipe_under::Dict{String, Array{Float64,1}}, Q_Base:: Array{Float64},
                                    aValve_over:: Dict{String, Array{Float64,1}}, bValve_over::Dict{String, Array{Float64,1}},
                                    aValve_under::Dict{String, Array{Float64,1}},bValve_under::Dict{String, Array{Float64,1}},
                                    Q_Base_cv:: Array{Float64}, PositiveFlowLinks::Array{String},
                                    NegativeFlowLinks::Array{String}, ReversibleFlowLinks::Array{String})
    pipes = Array{RegularPipe}(0)
    for (key, p) in data
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        flow_direction = "Not Assigned"
        if p["name"] in ReversibleFlowLinks
            flow_direction = "Reversible"
        elseif p["name"] in PositiveFlowLinks
            flow_direction = "Positive"
        else
            flow_direction = "Negative"
        end
        if p["cv"] == false
            push!(pipes,RegularPipe(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], p["control_pipe"], flow_direction, aPipe_over, bPipe_over, aPipe_under, bPipe_under, Q_Base))
        else
            push!(pipe, CheckValvePipe(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], p["control_pipe"], flow_direction, aValve_over, bValve_over, aValve_under, bValve_under, Q_Base_cv))
        end
    end
    return pipes
end

function pump_to_struct_parameters(data::Dict{Int64,Any}, flow::Dict{String, Array{Float64,1}}, head::Dict{String, Array{Float64,1}},
                                    power::Dict{String, Array{Float64,1}}, aPumpPower_flow::Dict{String, Array{Float64,1}},
                                    bPumpPower_flow::Dict{String, Array{Float64,1}}, aPumpPower_head::Dict{String, Array{Float64,1}},
                                    bPumpPower_head::Dict{String, Array{Float64,1}})
    pumps = Array{ConstSpeedPump}(0)
    for (key, p) in data
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        push!(pumps, ConstSpeedPump(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["status"], p["pumpcurve"], p["efficiency"], p["energyprice"], flow, head, power, aPumpPower_flow, bPumpPower_flow, aPumpPower_head, bPumpPower_head))
    end
    return pumps
end
