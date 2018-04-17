export wn_to_struct


function wn_to_struct(inp_file::String)
    junctions = Array{Junction}(0)
    tanks = Array{Tank}(0)
    reservoirs = Array{Reservoir}(0)
    pipes = Array{Pipe}(0)
    valves = Array{Valve}(0)
    pumps = Array{Pump}(0)
    #loads = Array{WaterDemand}(0) 
    net = WaterSystems.wntr[:network]
    wn = net[:WaterNetworkModel](inp_file)

    for junc in wn[:junction_name_list]
        #junctions
        j = wn[:get_node](junc)
        push!(junctions,Junction(j.name, 
                j.elevation, 
                j.head, 
                j.demand_timeseries_list, 
                j.minimum_pressure, 
                j.coordinates))
    end

    for tank in wn[:tank_name_list]
        #tanks
        t = wn[:get_node](tank)
        push!(tanks,Tank(t.name,
                t.elevation
                t.head,
                t.level,
                t.min_level,
                t.max_level,
                t.min_vol,
                t.vol_curve,
                t.diameter,
                t.coordinates))
    end

    for res in wn[:reservoir_name_list]
        #reservoirs
        r = wn[:get_node](res)
        push!(reservoirs,Reservoir(r.name,
                r.base_head,
                r.head_timeseries,
                r.coordinates))
    end

    for pipe in wn[:pipe_name_list]
        #pipes
        p = wn[:get_link](pipe)
        push!(pipes,Pipe(p.name,
                (p.start_node,p.end_node),
                p.status,
                p.diameter,
                p.length,
                p.roughness,
                p.minor_loss,
                p.flow))
    end

    for valve in wn[:valve_name_list]
        #valves
        v = wn[:get_link](valve)
        push!(valves,Valve(v.name,
            (v.start_node,v.end_node),
            v.status,#needs intrepretation
            v.initial_status,#needs intrepretation
            v.diameter,
            v.flow,
            v.setting,
            v.initial_setting,
            v.valve_type))
    end

    for pump in wn{:pump_name_list}
        #pumps
        p = wn[:get_link](pump)
        push!(valves,Valve(p.name,
            (p.start_node,p.end_node),
            p.status,#needs intrepretation
            p.initial_status,#needs intrepretation
            p.flow,
            p.setting,
            p.initial_setting,
            p.pump_type,
            p.efficiency,
            p.energy_price,
            p.speed_timeseries))
    end

    return junctions, tanks, reservoirs, pipes, valves, pumps
end