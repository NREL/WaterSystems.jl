function dict_to_struct(data::Dict{String,Any})
    haskey(data, "Junction") ? junctions = junction_to_struct(data["Junction"]) : @warn("Key Error : key 'Junction' not found in WaterSystems dictionary, this will result in an empty Junction array")
    haskey(data, "Tank") ? tanks = tank_to_struct(data["Tank"], junctions) : @warn("Key Error : key 'Tank' not found in WaterSystems dictionary, this will result in an empty Tank array")
    haskey(data, "Reservoir") ? res = res_to_struct(data["Reservoir"], junctions) : @warn("Key Error : key 'Reservoir' not found in WaterSystems dictionary, this will result in an empty Reservoir array")
    haskey(data, "Pipe") ? pipes = pipe_to_struct(data["Pipe"], junctions) : @warn("Key Error : key 'Pipe' not found in WaterSystems dictionary, this will result in an empty Pipe array")
    haskey(data, "Valve") ? valves = valve_to_struct(data["Valve"], junctions) : @warn("Key Error : key 'Valve' not found in WaterSystems dictionary, this will result in an empty Valve array")
    haskey(data, "Pump") ? pumps = pump_to_struct(data["Pump"], junctions) : @warn("Key Error : key 'Pump' not found in WaterSystems dictionary, this will result in an empty Pump array")
    haskey(data, "Demand") ? demands = demand_to_struct(data["Demand"], junctions) : @warn("Key Error : key 'demand' not found in WaterSystems dictionary, this will result in an empty demand array")
    d = data["wntr"]
    simulations = Simulation(d["duration"], d["timeperiods"], d["num_timeperiods"], d["start"], d["end"])
    return junctions, tanks, res, pipes, valves, pumps, demands, simulations
end

function junction_to_struct(data::Dict{String, Any})
    junctions = [Junction(j["name"], j["elevation"], j["head"], j["minimum_pressure"], j["coordinates"]) for (key,j) in data]
    return junctions
end

function tank_to_struct(data::Dict{Int64,Any}, junctions::Array{Junction,1})
    tanks = Array{R where {R<:RoundTank},1}(undef, length(data))
    for (ix,(key, t)) in enumerate(data)
        junction = [junc for junc in junctions if junc.name == t["name"]]
        tanks[ix] = RoundTank(t["name"], junction[1], t["volumelimits"], t["diameter"], t["volume"], t["area"], t["level"], t["levellimits"])
    end
    return tanks
end

function res_to_struct(data::Dict{Int64, Any}, junctions::Array{Junction,1})
    res = Array{S where {S<:StorageReservoir},1}(undef,length(data))
    for (ix, (key, r)) in enumerate(data)
        junction = [junc for junc in junctions if junc.name == r["name"]]
        res[ix] = StorageReservoir(r["name"], junction[1], r["elevation"])
    end
    return res
end

function pipe_to_struct(data::Dict{Int64,Any}, junctions::Array{Junction,1})
    pipes = Array{P where {P<:Pipe}, 1}(undef, length(data))
    for (ix, (key, p)) in enumerate(data)
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_to = [junc for junc in junctions if junc.name == j_to["name"]][1]
        junction_from = [junc for junc in junctions if junc.name == j_from["name"]][1]
        if p["cv"] == false
            if p["control_pipe"]
                pipes[ix] = ControlPipe(ReversibleFlowPipe( p["name"], (from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"]), GateValve(p["initial_status"]))
            else
                pipes[ix] = ReversibleFlowPipe(p["name"], (from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"])

            end
        else
            pipes[ix] = CheckValvePipe(p["name"], (from = junction_from, to = junction_to) ,p["diameter"], p["length"], p["roughness"], p["headloss"], p["flow"], p["initial_status"])
        end
    end
    return pipes
end

function valve_to_struct(data::Dict{Int64, Any}, junctions::Array{Junction,1})
    valves = Array{PR where {PR <: PressureReducingValve},1}(undef, length(data))
    for (ix,(key, v)) in enumerate(data)
        #push!(valves, PressureReducingValve(...))
        j_from = v["connectionpoints"].from
        j_to = v["connectionpoints"].to
        junction_to = [junc for junc in junctions if junc.name == j_to["name"]][1]
        junction_from = [junc for junc in junctions if junc.name == j_from["name"]][1]
        if v["valvetype"] == "PRV"
            valves[ix] = PressureReducingValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        elseif v["valvetype"] == "PSV"
            valves[ix] = PressureSustainingValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        elseif v["valvetype"] == "PBV"
            valves[ix] = PressureBreakerValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        elseif v["valvetype"] == "FCV"
            valves[ix] = FlowControlValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        elseif v["valvetype"] == "TCV"
            valves[ix] = ThrottleControlValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        else
            valves[ix] = GeneralPurposeValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
        end
    end
    return valves
end

function pump_to_struct(data::Dict{Int64,Any}, junctions::Array{Junction,1})
    pumps = Array{C where {C <:ConstSpeedPump},1}(undef, length(data))
    for (ix, (key, p)) in enumerate(data)
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_to = [junc for junc in junctions if junc.name == j_to["name"]][1]
        junction_from = [junc for junc in junctions if junc.name == j_from["name"]][1]
        pumps[ix] = ConstSpeedPump(p["name"], (from = junction_from, to = junction_to), p["status"], p["pumpcurve"], p["efficiency"], p["energyprice"])
    end
    return pumps
end
function demand_to_struct(data::Dict{Int64,Any}, junctions::Array{Junction,1})
    demands = Array{W where {W <:WaterDemand},1}(undef, length(data))
    for (ix, (key, d)) in enumerate(data)
        junction = [junc for junc in junctions if junc.name == d["node"]["name"]]
        demands[ix] = WaterDemand(d["name"], junction[1] , d["status"], d["max_demand"], d["demand"], d["demandforecast"])
    end
    return demands
end


