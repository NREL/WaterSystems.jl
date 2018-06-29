@pyimport wntr.network.model as model #import wntr network model
@pyimport wntr.sim.epanet as sim
@pyimport wntr.metrics.economic as metric
@time print("pyimport")

function from_seconds(time)
    hours =0
    minutes = 0
    seconds = 0
    if time >= 3600
        minutes, seconds = fldmod(time, 60)
        hours, minutes = fldmod(minutes, 60)
    elseif time >=60
        minutes, seconds = fldmod(time, 60)
    else
        seconds = time
    end
    return hours, minutes, seconds
end

function wn_to_struct(inp_file)
    #initialize arrays for input into package
    junctions = Array{Junction}(0) #only junctions with demands
    nodes = Array{Junction}(0) #all nodes (junctions, tanks, reservoirs)
    tanks = Array{RoundTank}(0)
    reservoirs = Array{Reservoir}(0)
    reservoir_nodes = Array{Junction}(0)
    pipes = Array{RegularPipe}(0)
    valves = Array{PressureReducingValve}(0)
    pumps = Array{ConstSpeedPump}(0)

    #set up WaterNetwork using WNTR
    wn = model.WaterNetworkModel(inp_file) #Water Network
    @time println("Wntr model")
    wns = sim.EpanetSimulator(wn) #Simulation either Demand Driven(DD) or Presure Dependent Demand(PDD), default DD
    results = wns[:run_sim]()
    @time println("Wntr simulation")
    node_results = results[:node] #dictionary of head, pressure, demand, quality
    link_results = results[:link] #dictionary of status, flowrate, velocity, {headloss, setting, friciton factor, reaction rate, link quality} = epanet simulator only

    #timeseries information
    duration = wn[:options][:time][:duration]
    time_step = wn[:options][:time][:report_timestep]
    duration_hours = from_seconds(duration)
    time_step_hours = time_step/3600

    if duration_hours[2] & duration_hours[3] != 0
        warn("Duration is not and integer number of hours.")
    else
        duration_hours = Int64(duration_hours[1])
    end

    start_time = wn[:options][:time][:report_start]
    num_timesteps = duration/time_step

    if mod(num_timesteps, 1) == 0
        num_timesteps = Int(num_timesteps)
    else
        error("Duration does not correspond to a full timestep.")
    end
    hrs_mins_secs = from_seconds(start_time)
    hours = hrs_mins_secs[1]
    minutes = hrs_mins_secs[2]
    seconds = hrs_mins_secs[3]
    start = "$hours:$minutes:$seconds"
    start_day =  DateTime(start, "H:M:S")
    time_ahead = collect(start_day:Second(time_step):start_day + Second(duration-time_step))

    #nodes
    index_junc = 0
    for junc in wn[:junction_name_list]
        index_junc = index_junc + 1
        #head and demand are current at each node
        j = wn[:get_node](junc)
        head = node_results["head"][junc][:values][1] #head at first timestep (initial_head)
        demand = node_results["demand"][junc][:values][1:num_timesteps] #to chop the last demand value (recurring initial value)
        demand_timeseries = TimeSeries.TimeArray(time_ahead, demand)
        node = Junction(index_junc, junc, j[:elevation], convert(Float64,head), demand_timeseries, j[:minimum_pressure], @NT(lat = j[:coordinates][2], lon = j[:coordinates][1]))
        push!(junctions, node )
        push!(nodes, node)
    end
    @time println("junction array")
    #Tanks
    #currently for roundtank only
    index_tank = wn[:num_junctions]
    for tank in wn[:tank_name_list]
        #head  and demand are initial values
        index_tank = index_tank + 1
        t = wn[:get_node](tank)
        #assign minimum pressure to the stardard for nodes
        junc = wn[:junction_name_list]
        j = wn[:get_node](junc[1])
        min_pressure = j[:minimum_pressure]

        head = node_results["head"][tank][:values][1] #head at first timestep (initial_head)
        demand = node_results["demand"][tank][:values][1:num_timesteps] #to chop the last demand value (recurring initial value)
        demand_timeseries = TimeSeries.TimeArray(time_ahead, demand) #demand at first timestep (initial_demand)
        area = π * (t[:diameter]/2)^2 ;
        volume = area * t[:init_level];
        volumelimits = [x * area for x in [t[:min_level],t[:max_level]]];

        node = Junction(index_tank, t[:name], t[:elevation], convert(Float64,head), demand_timeseries, min_pressure, @NT(lat = t[:coordinates][2], lon = t[:coordinates][1]))
        push!(nodes, node)
        push!(tanks,RoundTank(tank, node, @NT(min = volumelimits[1],max = volumelimits[2]), t[:diameter], volume, area, t[:init_level], @NT(min = t[:min_level], max = t[:max_level])))

    end
    @time println("tank array")
    #Reservoirs
    index_res = wn[:num_junctions] + wn[:num_tanks]
    for res in wn[:reservoir_name_list]
        index_res = index_res +1
        r = wn[:get_node](res)
        head = node_results["head"][res][:values][1] #head at first timestep (initial_head)
        demand = node_results["demand"][res][:values][1:num_timesteps] #to chop the last demand value (recurring initial value)
        demand_timeseries = TimeSeries.TimeArray(time_ahead, demand)
        node = Junction(index_res, res, r[:base_head], convert(Float64,head), demand_timeseries, 0, @NT(lat = r[:coordinates][2], lon = r[:coordinates][1])) #array of pseudo nodes @ res
        push!(nodes, node)
        push!(reservoirs,Reservoir(res, node, r[:base_head])) #base_head = elevation

    end
    @time println("res array")

    #Pipes
    pipe_index = 0
    for pipe in wn[:pipe_name_list]
        pipe_index = pipe_index + 1
        p = wn[:get_link](pipe)
        headloss = link_results["headloss"][pipe][:values][1] #headloss at first time step
        flowrate = link_results["flowrate"][pipe][:values][1] #flowrate at first time step
        junction_start = nothing
        junction_end = nothing
        s = wn[:get_node](p[:start_node_name])
        e = wn[:get_node](p[:end_node_name])
        #from node
        if s[:node_type]  == "Junction"
            for junc = 1:length(nodes)
                if nodes[junc].name == s[:name]
                    junction_start = nodes[junc]
                    break
                end
            end
        elseif s[:node_type]  == "Tank"
            for tank = 1:length(tanks)
                if tanks[tank].node.name == s[:name]
                    junction_start = tanks[tank].node
                    break
                end
            end
        else
            for res = 1:length(reservoirs)
                if reservoirs[res].node.name == s[:name]
                    junction_start = reservoirs[res].node
                end
            end
        end
        #to node
        if e[:node_type] == "Junction"
            for junc =1:length(nodes)
                if nodes[junc].name == e[:name]
                    junction_end = nodes[junc]
                    break
                end
            end
        elseif e[:node_type]  == "Tank"
                for tank =1:length(tanks)
                    if tanks[tank].node.name == e[:name]
                        junction_end = tanks[tank].node
                        break
                    end
                end
            else
                for res = 1:length(reservoirs)
                    if reservoirs[res].node.name == e[:name]
                        junction_end = reservoirs[res].node
                    end
                end
            end
            push!(pipes,RegularPipe(pipe_index, pipe, @NT(from = junction_start, to = junction_end),p[:diameter],p[:length],p[:roughness], convert(Float64,headloss), convert(Float64,flowrate), p[:initial_status]))
        end
    @time println("pipe array includes if statements")
    #Valves
    #currently for Pressure Reducing Valve Only
    valve_index = wn[:num_pipes]
    for valve in wn[:valve_name_list]
        valve_index = valve_index + 1
        v = wn[:get_link](valve)
        junction_start = nothing
        junction_end = nothing
        s = wn[:get_node](v[:start_node_name])
        e = wn[:get_node](v[:end_node_name])

        #from node
        if s[:node_type]  == "Junction"
            for junc = 1:length(nodes)
                if nodes[junc].name == s[:name]
                    junction_start = nodes[junc]
                    break
                end
            end
        elseif s[:node_type]  == "Tank"
            for tank = 1:length(tanks)
                if tanks[tank].node.name == s[:name]
                    junction_start = tanks[tank].node
                    break
                end
            end
        else
            for res = 1:length(reservoirs)
                if reservoirs[res].node.name == s[:name]
                    junction_start = reservoirs[res].node
                end
            end
        end
        #to node
        if e[:node_type] == "Junction"
            for junc = 1:length(nodes)
                if nodes[junc].name == e[:name]
                    junction_end = nodes[junc]
                    break
                end
            end
        elseif e[:node_type]  == "Tank"
                for tank =1:length(tanks)
                    if tanks[tank].node.name == e[:name]
                        junction_end = tanks[tank].node
                        break
                    end
                end
        else
            for res = 1:length(reservoirs)
                if reservoirs[res].node.name == e[:name]
                    junction_end = reservoirs[res].node
                end
            end
        end
        status_index = v[:initial_status] + 1  # 1=Closed, 2=Open, 3 = Active, 4 = CheckValve
        status_string = ["Closed", "Open", "Active","Check Valve"][status_index]
        push!(valves, PressureReducingValve(valve_index, valve, @NT(from = junction_start, to = junction_end), status_string , v[:diameter], v[:setting]))
    end
    @time println("valves array includes if statements ")
    #Pumps
    pump_index = wn[:num_pipes] + wn[:num_valves]

    for pump in wn[:pump_name_list]
        energy = 0
        pump_index = pump_index + 1
        p = wn[:get_link](pump)
        junction_start = nothing
        junction_end = nothing
        s= wn[:get_node](p[:start_node_name])
        e = wn[:get_node](p[:end_node_name])
        #from node
        if s[:node_type]  == "Junction"
            for junc = 1:length(nodes)
                if nodes[junc].name == s[:name]
                    junction_start = nodes[junc]
                    break
                end
            end
        elseif s[:node_type]  == "Tank"
            for tank = 1:length(tanks)
                if tanks[tank].node.name == s[:name]
                    junction_start = tanks[tank].node
                    break
                end
            end
        else
            for res = 1:length(reservoirs)
                if reservoirs[res].node.name == s[:name]
                    junction_start = reservoirs[res].node
                end
            end
        end
        #to node
        if e[:node_type] == "Junction"
            for junc =1:length(nodes)
                if nodes[junc].name == e[:name]
                    junction_end = nodes[junc]
                    break
                end
            end
        elseif e[:node_type]  == "Tank"
                for tank =1:length(tanks)
                    if tanks[tank].node.name == e[:name]
                        junction_end = tanks[tank].node
                        break
                    end
                end
        else
            for res = 1:length(reservoirs)
                if reservoirs[res].node.name == e[:name]
                    junction_end = reservoirs[res].node
                end
            end
        end
        if p[:pump_type] == "HEAD"
            pump_curve_name = p[:pump_curve_name]
            pump_curve = wn[:get_curve](pump_curve_name)[:points]
        else
            pump_curve = [(p[:power],0.0)] #power pump types gives fixed power value,
            #0 is dummy variable to fit tuple type until we decide what we want to do
        end
        #energy price
        price = wn[:options][:energy][:global_price]
        pattern = wn[:options][:energy][:global_pattern]
        if price == 0
            warn("Price is set to 0. Using randomly generated price array with higher weights during peak hours (4pm-8pm).")
            price_array = [2*rand(16)+1; 7*rand(4)+3; 2*rand(4)+3]
        elseif pattern == None
            price_array = price * ones(length(time_ahead))
        else
            price_array = price * pattern
        end
        energyprice = TimeSeries.TimeArray(time_ahead, price_array)

        #efficiency
        efficiency = p[:efficiency]
        if efficiency == nothing
            warn("Pump efficiency is 0. Default will be 65% for pump $pump.")
            efficiency = .65
        end

        #energy
        energy = TimeSeries.TimeArray(time_ahead, metric.pump_energy(link_results["flowrate"], node_results["head"], wn)[pump][:values][1:num_timesteps])
        push!(pumps,ConstSpeedPump(pump_index, pump, @NT(from = junction_start, to = junction_end),p[:status], pump_curve, efficiency, energyprice, energy))
    end
    @time println("pumps array includes if statements ")
    #additional arrays
    links = vcat(pipes, valves, pumps)
    demands = Array{WaterDemand}(0)
    max_demand = 20 #placeholder
    for i = 1:length(nodes)
        name = nodes[i].name
        demand = node_results["demand"][name][:values][1:num_timesteps]
        push!(demands, WaterDemand(name, nodes[i], true, max_demand, TimeSeries.TimeArray(time_ahead, demand)))
    end
    @time println("WaterDemand")
    return nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, duration_hours, time_step_hours
end
