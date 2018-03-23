export dict_to_struct

function dict_to_struct(data::Dict)

    NBus = SystemParam(length(data["junction"]), base_kv, data["baseMVA"], 1); # TODO: Check busses have same base voltage

    nodes = Array{Junction}(0)
    Loads = Array{WaterDemand}(0) # Using least constrained Load

    for (i, i2) in zip([1:length(data["junction"]);], sort!([parse(Int, key) for key in keys(data["junction"])])) # Parse key as int for proper sorting

        d = data["junction"][string(i2)]

        push!(nodes, Bus(d["bus_i"], string("node", string(i)), bus_types[d["bus_type"]], 0, d["vm"], (d["vmin"], d["vmax"]), d["base_kv"])) # NOTE: angle 0, tuple(min, max)
        # If there is a load for this bus, only information so far is the installed load.
        if d["demand"] != 0.0
            push!(Loads, StaticLoad(string("Load", string(i2)), nodes[i2], "P", d["pd"], d["qd"],
                # hardcoded until we get a better structure for economic data for loads
                # load_econ("interruptible", 1000, 999),
                TimeSeries.TimeArray(Dates.today(), [1.0])
                ))
        end
    end

    Pipelines = Array{Pipeline}(0)
    for d in data["connection"]
        # Check if transformer2w, else line
            push!(Pipelines, Line(d[1], convert(Bool, d[2]["br_status"]),
                (nodes[d[2]["f_bus"]], nodes[d[2]["t_bus"]]),
                d[2]["br_r"], d[2]["br_x"], d[2]["br_b"],
                d[2]["rate_a"], (d[2]["angmin"], d[2]["angmax"]))
                )
        end
    end
