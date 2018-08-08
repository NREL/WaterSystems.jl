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
    return junctions, tanks, res, pipes, valves, pumps, demands, simulations
end
function dict_to_struct(data::Dict{String,Any}, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64, tight_coef::Float64)
    Parameters = Parameterize(data["wntr_dict"], n, Q_lb, logspace_ratio, dH_critical, dense_coef, tight_coef)
    haskey(data, "Junction") ? junctions = junction_to_struct(data["Junction"]) : warn("Key Error : key 'Junction' not found in WaterSystems dictionary, this will result in an empty Junction array")
    haskey(data, "Node") ? nodes = node_to_struct(data["Node"]) : warn("Key Error : key 'Node' not found in WaterSystems dictionary, this will result in an empty Node array")
    haskey(data, "Tank") ? tanks = tank_to_struct(data["Tank"]) : warn("Key Error : key 'Tank' not found in WaterSystems dictionary, this will result in an empty Tank array")
    haskey(data, "Reservoir") ? res = res_to_struct(data["Reservoir"]) : warn("Key Error : key 'Reservoir' not found in WaterSystems dictionary, this will result in an empty Reservoir array")
    haskey(data, "Pipe") ? pipes = pipe_to_struct(data["Pipe"], Parameters) : warn("Key Error : key 'Pipe' not found in WaterSystems dictionary, this will result in an empty Pipe array")
    haskey(data, "Valve") ? valves = valve_to_struct(data["Valve"]) : warn("Key Error : key 'Valve' not found in WaterSystems dictionary, this will result in an empty Valve array")
    haskey(data, "Pump") ? pumps = pump_to_struct(data["Pump"], Parameters) : warn("Key Error : key 'Pump' not found in WaterSystems dictionary, this will result in an empty Pump array")
    haskey(data, "demand") ? demands = demand_to_struct(data["demand"]) : warn("Key Error : key 'demand' not found in WaterSystems dictionary, this will result in an empty demand array")
    d = data["wntr"]
    simulations = Simulation(d["duration"], d["timeperiods"], d["num_timeperiods"], d["start"], d["end"])
    return junctions, tanks, res, pipes, valves, pumps, demands, simulations
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
    for (ix,(key, t)) in enumerate(data)
        node = t["node"]
        junction = Junction(node["number"], node["name"], node["elevation"], node["head"], node["minimum_pressure"], node["coordinates"])
        tanks[ix] = RoundTank(t["name"], junction, t["volumelimits"], t["diameter"], t["volume"], t["area"], t["level"], t["levellimits"])
    end
    return tanks
end

function res_to_struct(data::Dict{Int64, Any})
    res = Array{StorageReservoir}(length(data))
    for (ix, (key, r)) in enumerate(data)
        node = r["node"]
        junction = Junction(node["number"], node["name"], node["elevation"], node["head"], node["minimum_pressure"], node["coordinates"])
        res[ix] = StorageReservoir(r["name"], junction, r["elevation"])
    end
    return res
end

function pipe_to_struct(data::Dict{Int64,Any})
    pipes = Array{Pipe}(length(data))
    for (ix, (key, p)) in enumerate(data)
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        if p["cv"] == false
            if p["control_pipe"]
                pipes[ix] = ControlPipe(ReversibleFlowPipe(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"]), GateValve(p["initial_status"]))
            else
                pipes[ix] = ReversibleFlowPipe(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"])

            end
        else
            pipes[ix] = CheckValvePipe(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"])
        end
    end
    return pipes
end

function valve_to_struct(data::Dict{Int64, Any})
    valves = Array{PressureReducingValve}(length(data))
    for (ix,(key, v)) in enumerate(data)
        #push!(valves, PressureReducingValve(...))
        j_from = v["connectionpoints"].from
        j_to = v["connectionpoints"].to
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        if v["valvetype"] == "PRV"
            valves[ix] = PressureReducingValve(v["number"], v["name"], @NT(from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        elseif v["valvetype"] == "PSV"
            valves[ix] = PressureSustainingValve(v["number"], v["name"], @NT(from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        elseif v["valvetype"] == "PBV"
            valves[ix] = PressureBreakerValve(v["number"], v["name"], @NT(from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        elseif v["valvetype"] == "FCV"
            valves[ix] = FlowControlValve(v["number"], v["name"], @NT(from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        elseif v["valvetype"] == "TCV"
            valves[ix] = ThrottleControlValve(v["number"], v["name"], @NT(from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        else
            valves[ix] = GeneralPurposeValve(v["number"], v["name"], @NT(from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        end
    end
    return valves
end

function pump_to_struct(data::Dict{Int64,Any})
    pumps = Array{ConstSpeedPump}(length(data))
    for (ix, (key, p)) in enumerate(data)
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        pumps[ix] = ConstSpeedPump(p["number"], p["name"], @NT(from = junction_from, to = junction_to) ,p["status"], p["pumpcurve"], p["efficiency"], p["energyprice"])
    end
    return pumps
end
function demand_to_struct(data::Dict{Int64,Any})
    demands = Array{WaterDemand}(length(data))
    for (key, d) in data
        node_data = d["node"]
        number = node_data["number"]
        node = Junction(number, node_data["name"], node_data["elevation"], node_data["head"], node_data["minimum_pressure"], node_data["coordinates"])
        demands[number] = WaterDemand(d["name"], number, node , d["status"], d["max_demand"], d["demand"], d["demandforecast"])
    end
    return demands
end


function pipe_to_struct(data::Dict{Int64,Any}, Parameters::Dict{String,Any})
    pipes = Array{Pipe}(length(data))
    for (ix, (key, p)) in enumerate(data)
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        name = p["name"]
        if p["cv"] == false
            flows = Parameters["Q_basePipe"][name]
            slopes = Parameters["bPipe_under"][name]
            intercepts = Parameters["aPipe_under"][name]
            headloss_parameters = Array{@NT(flow::Float64, slope::Float64, intercept::Float64)}(length(flows))
            flow_limits = @NT(Qmin = Parameters["Qmin"][name], Qmax = Parameters["Qmax"][name])
            for j = 1:length(flows)
                headloss_parameters[j] = @NT(flow = flows[j], slope = slopes[j], intercept = intercepts[j])
            end
            if p["control_pipe"]
                if name in Parameters["ReversibleFlowLinks"]
                    pipes[ix] = ControlPipe(ReversibleFlowPipe(p["number"], name, @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], flow_limits, headloss_parameters), GateValve(p["initial_status"]))
                elseif name in Parameters["PositiveFlowLinks"]
                    pipes[ix] = ControlPipe(PositveFlowPipe(p["number"], name, @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], flow_limits, headloss_parameters), GateValve(p["initial_status"]))

                else
                    pipes[ix] = ControlPipe(NegativeFlowPipe(p["number"], name, @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], flow_limits, headloss_parameters), GateValve(p["initial_status"]))
                end
            else
                if name in Parameters["ReversibleFlowLinks"]
                    pipes[ix] = ReversibleFlowPipe(p["number"], name, @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], flow_limits, headloss_parameters)
                elseif name in Parameters["PositiveFlowLinks"]
                    pipes[ix] = StandardPositiveFlowPipe(p["number"], name, @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], flow_limits, headloss_parameters)

                else
                    pipes[ix] = NegativeFlowPipe(p["number"], name, @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], flow_limits, headloss_parameters)
                end
            end
        else
            flows = Parameters["Q_baseCV"][name]
            slopes = Parameters["bCheckValve_under"][name]
            intercepts = Parameters["aCheckValve_under"][name]
            flow_limits = @NT(Qmin = Parameters["Qmin"][name], Qmax = Parameters["Qmax"][name])
            headloss_parameters = Array{@NT(flow::Float64, slope::Float64, intercept::Float64)}(length(flows))
            for j = 1:length(flows)
                headloss_parameters[j] = @NT(flow = flows[j], slope = slopes[j], intercept = intercepts[j])
            end
            pipes[ix] = CheckValvePipe(p["number"], name, @NT(from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"], flow_limits, headloss_parameters)
        end
    end
    return pipes
end

function pump_to_struct(data::Dict{Int64,Any}, Parameters::Dict{String,Any})
    pumps = Array{ConstSpeedPump}(length(data))
    for (ix, (key, p)) in enumerate(data)
        name = p["name"]
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        flows = Parameters["flow"][name]
        powers = Parameters["power"][name]
        slopes = Parameters["bPumpPower_head"][name]
        intercepts = Parameters["aPumpPower_head"][name]
        power_parameters = Array{@NT(flow::Float64, power::Float64, slope::Float64, intercept::Float64)}(length(flows))
        for j = 1:length(flows)
            power_parameters[j] = @NT(flow = flows[j], power = powers[j], slope = slopes, intercept = intercepts)
        end
        junction_from = Junction(j_from["number"], j_from["name"], j_from["elevation"], j_from["head"], j_from["minimum_pressure"], j_from["coordinates"])
        junction_to = Junction(j_to["number"], j_to["name"], j_to["elevation"], j_to["head"], j_to["minimum_pressure"], j_to["coordinates"])
        pumps[ix] =  ConstSpeedPump(p["number"], name, @NT(from = junction_from, to = junction_to) ,p["status"], p["pumpcurve"], p["efficiency"], p["energyprice"], power_parameters)
    end
    return pumps
end
