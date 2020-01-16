# modifying from Amanda's legacy parsing code, JJS 12/5/19

const small = 1e-6
const large = 1e6

"""
Convert dictionary of water network to WaterSystems structure
"""
function dict_to_struct(data::Dict{String,Any})
    # I stripped away the checks for the existence of each of these -- may need them for not
    # required features, e.g., tanks, JJS 12/11/19
    junctions = junction_to_struct(data["Junction"])
    j_dict = Dict{String, Junction}(junction.name => junction for junction in junctions)
    arcs = link_to_struct(data["Link"], j_dict)
    a_dict = Dict{String, Arc}(arc.name => arc for arc in arcs)
    res = res_to_struct(data["Reservoir"], j_dict)
    tanks = tank_to_struct(data["Tank"], j_dict)
    demands = demand_to_struct(data["Demand"], j_dict)
    patterns = pattern_to_struct(data["Pattern"])
    curves = curve_to_struct(data["Curve"])
    pipes = pipe_to_struct(data["Pipe"], a_dict)
    pumps = pump_to_struct(data["Pump"], a_dict, curves, patterns)
    valves = valve_to_struct(data["Valve"], a_dict)

    return junctions, arcs, res, tanks, demands, patterns, curves, pipes, pumps, valves
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
Create array of tanks using WaterSystems.Tank types. Only cylindrical tanks are
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
Create array of demands using WaterSystems.WaterDemand types. Only static demands are
currently supported.
"""
function demand_to_struct(d_vec::Vector{Any}, j_dict::Dict{String,Junction})
    # Only populating base_demand and the pattern name; the actual forecast will be created
    # and added separately, following the paradigm of PowerSystems.jl. Note that the
    # base_demand and pattern values can vary wildly with no consistent scaling. Would it be
    # useful (considering the computational cost) to rescale all of the base demands and the
    # patterns? See "demand_dict!" in wntr_dict_parser.jl, JJS 12/26/19
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
Create array of patterns using WaterSystems.Pattern type.
"""
function pattern_to_struct(p_vec::Vector{Any})
    patterns = Vector{Pattern}(undef, length(p_vec))
    for (i,curve) in enumerate(p_vec)
        patterns[i] = Pattern(curve["name"], curve["multipliers"])
    end
    return patterns
end

"""
Create array of curves using WaterSystems.Curve type.
"""
function curve_to_struct(c_vec::Vector{Any})
    curves = Vector{Curve}(undef, length(c_vec))
    for (i,curve) in enumerate(c_vec)
        curves[i] = Curve(curve["name"], curve["type"], curve["points"])
    end
    return curves
end

"""
Create array of pipes using WaterSystems.Pipe types.
"""
function pipe_to_struct(pi_vec::Vector{Any}, a_dict::Dict{String,Arc})
    pipes = Vector{Pipe}(undef, length(pi_vec))
    #unid_flowlimits = CVPipe(nothing).flowlimits # neat trick to get defaults, not using
    #bidi_flowlimits = GatePipe(nothing).flowlimits
    unid_flowlimits = (min = small, max = large)
    bidi_flowlimits = (min = -large, max = large)
    for (i, pipe) in enumerate(pi_vec)
        name = pipe["name"]
        if pipe["cv"] == true
            pipes[i] = CVPipe(name, a_dict[name], true, pipe["diameter"], pipe["length"],
                              pipe["roughness"], unid_flowlimits, nothing, nothing)
        elseif pipe["control_pipe"] == true
            # add initial status (open/closed)? would need to add the field, JJS 12/26/19
            pipes[i] = GatePipe(name, a_dict[name], true, pipe["diameter"], pipe["length"],
                               pipe["roughness"], bidi_flowlimits, nothing, nothing, nothing)
        else
            pipes[i] = OpenPipe(name, a_dict[name], true, pipe["diameter"], pipe["length"],
                                pipe["roughness"], bidi_flowlimits, nothing, nothing)
        end
    end
    return pipes
end

"""
Create array of pumps using WaterSystem.Pump type.
"""
function pump_to_struct(pu_vec::Vector{Any}, a_dict::Dict{String,Arc}, c_vec::Vector{Curve},
                        pa_vec::Vector{Pattern})
    pumps = Vector{Pump}(undef, length(pu_vec))
    c_dict = Dict{String, Curve}(curve.name => curve for curve in c_vec)
    pa_dict = Dict{String, Pattern}(patt.name => patt for patt in pa_vec)
    flowlimits = (min = small, max = large)
    for (i, pump) in enumerate(pu_vec)
        name = pump["name"]
        # creat EPANETPumpParams object for the pump
        if pump["efficiency"] isa String
            efficiency = c_dict[pump["efficiency"]]
        else
            efficiency = pump["efficiency"]
        end
        epanet_params = EPANETPumpParams(pump["type"], pump["power"],
                                        c_dict[pump["head_curve_name"]],
                                        efficiency)
        # calculate normalized params and create the object
         # in utils/PumpCoefs.jl
        Qbep, etabep, Gbep, Pbep = norm_pump_params(pump, c_dict)
        norm_coefs = NormPumpParams(Qbep, etabep, Gbep, Pbep)
        # create the pump parameters object, including base price and pattern
        pump_params = PumpParams(epanet_params, norm_coefs, pump["price"],
                                 pump["price_pattern"])
        # create the pump object
        pumps[i] = Pump(name, a_dict[name], true, pump_params, flowlimits, nothing, nothing,
                        nothing)
    end
    return pumps
end

#ignoring valves for now, JJS 12/5/19
function valve_to_struct(v_vec::Vector{Any}, a_dict::Dict{String,Arc})
    if size(v_vec)[1] != 0
        @warn("There appears to be pressure/flow control valves in this network, but these valves are not currently handled by WaterSystems.jl")
    end
    return nothing
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
