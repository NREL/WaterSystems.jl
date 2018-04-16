export dict_to_struct


# Parameters:
#     Ct : Electricity cost in time period t
#     γ : Specific weight of water
#     ηij : Efficiency of pump installed on pipe (i, j)
#     Q U : Maximum rate of flow through ijpipe (i, j)
#     Dj,t : Demand at junction j in period t
#     Ei : Elevation of node i
#     PjL: Minimum water level in tank j 
#     PjU : Maximum water level in tank j 
#     Aj: Surface area of tank j
#     delta_T : Length of each time period
# Sets:
#     N: The set of pipes
#     P: The set of pipes thatcontain pumps
#     R: The set of reservoirs
#     K : The set of tanks
#     J: The set of junctions
#     T : The set of time periods

function dict_to_struct(data::Dict)
    junctions = Array{Junction}(0)
    tanks = Array{Tank}(0)
    #loads = Array{WaterDemand}(0) 

    for i in 1:length(data["nodes"])
        node = data["nodes"][i];
        #junctions
        if node["node_type"] == "Junction"
            push!(junctions,Junction(i,
                    node["name"],
                    node["elevation"]))
        elseif node["node_type"] == "Tank"
            push!(tanks,Tank(i,
                node["name"],
                node["elevation"], 
                node["init_level"],
                (node["min_level"], node["max_level"]),
                node["diameter"],
                node["min_vol"],
                node["vol_curve"]
               ))
        end
            #pressurelims = [node["minimum_pressure"],
            #node["leak_area"],
            #node["coordinates"],
            #node["nominal_pressure"],
            #node["initial_quality"],
            #node["demand"],
            #node["tag"],
            #node["leak_demand"],
            #node["node_type"],
            #node["leak_status"],
            #node["leak_discharge_coeff"],

        #resivoirs

        #tanks


        # d = data["junction"][string(i2)]

        # push!(nodes, Bus(d["bus_i"], string("node", string(i)), bus_types[d["bus_type"]], 0, d["vm"], (d["vmin"], d["vmax"]), d["base_kv"])) # NOTE: angle 0, tuple(min, max)
        # # If there is a load for this bus, only information so far is the installed load.
        # if d["demand"] != 0.0
        #     push!(Loads, StaticLoad(string("Load", string(i2)), nodes[i2], "P", d["pd"], d["qd"],
        #         # hardcoded until we get a better structure for economic data for loads
        #         node["demand_timeseries_list"],

        #         # load_econ("interruptible", 1000, 999),
        #         TimeSeries.TimeArray(Dates.today(), [1.0])
        #         ))
        # end
    end

    # Pipelines = Array{Pipeline}(0)
    # for d in data["connection"]
    #     # Check if transformer2w, else line
    #         push!(Pipelines, Line(d[1], convert(Bool, d[2]["br_status"]),
    #             (nodes[d[2]["f_bus"]], nodes[d[2]["t_bus"]]),
    #             d[2]["br_r"], d[2]["br_x"], d[2]["br_b"],
    #             d[2]["rate_a"], (d[2]["angmin"], d[2]["angmax"]))
    #             )
    #     end
    # end

    return junctions
end