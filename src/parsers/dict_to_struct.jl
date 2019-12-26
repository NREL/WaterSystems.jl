# modifying from Amanda's legacy parsing code, JJS 12/5/19

"""
Convert dictionary of water network to WaterSystems structure
"""
function dict_to_struct(data::Dict{String,Any})
    # I stripped away the checks for the existence of each of these -- may need them for not
    # required features, e.g., tanks, JJS 12/11/19
    junctions = junction_to_struct(data["Junction"])
    j_dict = Dict{String, Junction}(junction.name => junction for junction in junctions)
    arcs = link_to_struct(data["Link"], j_dict)
    res = res_to_struct(data["Reservoir"], j_dict)
    tanks = tank_to_struct(data["Tank"], j_dict)
    demands = demand_to_struct(data["Demand"], j_dict)
    curves = curve_to_struct(data["Curve"])
    # stopped here
    pipes = pipe_to_struct(data["Pipe"], junctions)
    pumps = pump_to_struct(data["Pump"], junctions)
    valves = valve_to_struct(data["Valve"], junctions)

    # create functions to populate pump params, patterns
    
    d = data["wntr"]
    simulations = Simulation(d["duration"], d["timeperiods"], d["num_timeperiods"], d["start"], d["end"])
    return junctions, tanks, res, pipes, valves, pumps, demands, simulations
end

"""
Create array of junctions using WaterSystems.Junction type
"""
function junction_to_struct(j_dict::Dict{String, Any})
    junctions = [Junction(name, junction["elevation"], junction["head"],
                          junction["minimum_pressure"], junction["coordinates"])
                 for (name, junction) in j_dict]
    return junctions
end

"""
Create array of arcs using WaterSystems.Arc type
"""
function link_to_struct(l_dict::Dict{String, Any}, j_dict::Dict{String,Junction})
    arcs = Vector{Arc}(undef, length(l_dict))
    for (i, (name,link)) in enumerate(l_dict)
        from_name = link["connectionpoints"][:from]["name"]
        to_name = link["connectionpoints"][:to]["name"]
        arcs[i] = Arc(name, j_dict[from_name], j_dict[to_name])
    end
    return arcs
end

"""
Create array of reservoirs using WaterSystems.Reservoir type.
"""
function res_to_struct(r_vec::Vector{Any}, j_dict::Dict{String,Junction})
    reservoirs = Vector{Reservoir}(undef,length(r_vec))
    for (i, reservoir) in enumerate(r_vec)
        name = reservoir["name"]
        reservoirs[i] = Reservoir(name, true, j_dict[name])
    end
    return reservoirs
end

""" 
Create array of tanks using WaterSystems.Tank subtypes. Only cylindrical tanks are
currently supported.
"""

function tank_to_struct(t_vec::Vector{Any}, j_dict::Dict{String,Junction})
    tanks = Vector{Tank}(undef, length(t_vec))
    for (i, tank) in enumerate(t_vec)
        name = tank["name"]
        tanks[i] = CylindricalTank(name, true, j_dict[name], tank["diameter"], tank["level"],
                                   tank["levellimits"])
    end
    return tanks
end

"""
Create array of demands using WaterSystems.WaterDemand subtypes. Only static demands are
currently supported.
"""
function demand_to_struct(d_vec::Vector{Any}, j_dict::Dict{String,Junction})
    # only populating base_demand and the pattern name; the actual forecast will be created
    # and added separately, following the paradigm of PowerSystems.jl
    demands = Vector{WaterDemand}(undef, length(d_vec))
    for (i,  demand) in enumerate(d_vec)
        name = demand["name"]
        base_demand = demand["base_demand"]
        pattern_name = demand["pattern_name"]
        demands[i] = StaticDemand(name, true, j_dict[name], base_demand, pattern_name)
    end
    return demands
end

"""
Create array of curves using WaterSystems.Curve subtype.
"""
function curve_to_struct(c_vec::Vector{Any})
    curves = Vector{Curve}(undef, length(c_vec))
    for (i,curve) in enumerate(c_vec)
        curves[i] = Curve(curve["name"], curve["type"], curve["points"])
    end
    return curves
end

function pipe_to_struct(data::Vector{Any}, junctions::Array{Junction,1})
    pipes = Array{P where {P<:Pipe}, 1}(undef, length(data))
    for (ix, p) in enumerate(data)
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

#ignoring valves for now, JJS 12/5/19
function valve_to_struct(data::Vector{Any})
    if size(data["Valve"])[1] != 0
        @warn("There appears to be pressure/flow control valves in this network, but these valves are not currently handled by WaterSystems.jl")
    end
    return Nothing()
end
# function valve_to_struct(data::Vector{Any}, junctions::Array{Junction,1})
#     valves = Array{PR where {PR <: PressureReducingValve},1}(undef, length(data))
#     for (ix, v) in enumerate(data)
#         #push!(valves, PressureReducingValve(...))
#         j_from = v["connectionpoints"].from
#         j_to = v["connectionpoints"].to
#         junction_to = [junc for junc in junctions if junc.name == j_to["name"]][1]
#         junction_from = [junc for junc in junctions if junc.name == j_from["name"]][1]
#         if v["valvetype"] == "PRV"
#             valves[ix] = PressureReducingValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
#         elseif v["valvetype"] == "PSV"
#             valves[ix] = PressureSustainingValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
#         elseif v["valvetype"] == "PBV"
#             valves[ix] = PressureBreakerValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
#         elseif v["valvetype"] == "FCV"
#             valves[ix] = FlowControlValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
#         elseif v["valvetype"] == "TCV"
#             valves[ix] = ThrottleControlValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
#         else
#             valves[ix] = GeneralPurposeValve(v["name"], (from = junction_from, to = junction_to) ,v["status"], v["diameter"], v["pressure_drop"])
#         end
#     end
#     return valves
# end

function pump_to_struct(data::Vector{Any}, junctions::Array{Junction,1})
    pumps = Array{C where {C <:ConstSpeedPump},1}(undef, length(data))
    for (ix, p) in enumerate(data)
        j_from = p["connectionpoints"].from
        j_to = p["connectionpoints"].to
        junction_to = [junc for junc in junctions if junc.name == j_to["name"]][1]
        junction_from = [junc for junc in junctions if junc.name == j_from["name"]][1]
        pumps[ix] = ConstSpeedPump(p["name"], (from = junction_from, to = junction_to), p["status"], p["pumpcurve"], p["efficiency"], p["energyprice"])
    end
    return pumps
end
