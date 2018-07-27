@pyimport wntr.network.controls as controls
function H_extrema(wn_dict::Dict{Any,Any})
    pumps = wn["pumps"]
    Hmin = Dict{String,Float64}()
    Hmax = Dict{String,Float64}()
    for (key, pump) in pumps
        node1 = pumps["connectionpoints"].from
        elev1 = node1["elevation"]

        node2 = pumps["connectionpoints"].to
        elev2 = node2["elevation"]

        node_results = wn["node_results"]
        link_results = wn["link_results"]

        pump_head = (node_results["pressure"][node2][:values] + elev2) - (node_results["pressure"][node1][:values] + elev1)
        pump_status = link_results["status"][key][:values]

        pump_head = pump_head .* pump_status #only care about head when pump is on
        pump_head = pump_head[pump_head .> 0]

        if length(pump_head) > 0
            try
                Hmin[key] = minimum(minimum(pump_head), Hmin[key])
                Hmax[key] = maximum(maximum(pump_head), Hmax[key])
            catch
                Hmin[key] = minimum(pump_head)
                Hmax[key] = maximum(pump_head)
            end
        end
    end
    return Hmin, Hmax


end
