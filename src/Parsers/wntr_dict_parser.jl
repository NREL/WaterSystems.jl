@pyimport wntr.metrics.economic as metric
@pyimport wntr.sim.epanet as sim
include("wntr_dict.jl")
function make_dict(inp_file::String)
    junctions = Dict{Int64,Any}()
    nodes = Dict{String,Any}()
    tanks = Dict{Int64,Any}()
    reservoirs = Dict{Int64,Any}()
    pipes = Dict{Int64,Any}()
    valves = Dict{Int64,Any}()
    pumps = Dict{Int64,Any}()
    demands = Dict{Int64, Any}()
    data = Dict{String,Any}("Node" =>nodes, "Junction" => junctions, "Tank" => tanks, "Reservoir" =>reservoirs, "Pipe" => pipes, "Valve" => valves, "Pump" => pumps, "demand" => demands)

    wn = wntr_dict(inp_file)
    duration = wn["options"]["time"]["duration"]
    time_periods = wn["options"]["time"]["report_timestep"]

    duration != 0 ? duration_hours = from_seconds(duration): error("Duration is set to 0. Modify .inp file.")



    timeperiods_hours = time_periods/3600

    duration_hours[2]!= 0 && duration_hours[3]!= 0 ? warn("Duration is not and integer number of hours.") : duration_hours = Int64(duration_hours[1])
    start_time = wn["options"]["time"]["report_start"]
    num_timeperiods = duration/time_periods

    mod(num_timeperiods, 1) == 0 ? num_timeperiods = Int(num_timeperiods): error("Duration does not correspond to a full timestep.")

    hours, minutes, seconds  = from_seconds(start_time)
    start = "$hours:$minutes:$seconds"
    start_day =  DateTime(start, "H:M:S")
    end_day = start_day + Second(duration-time_periods)
    time_ahead = collect(start_day:Second(time_periods):end_day)

    data["wntr"] = Dict{String,Any}("duration"=> duration-hours, "timeperiods" => timeperiods_hours, "num_timeperiods" => num_timeperiods, "start" => start_day, "end" => end_day)

    node_results = wn["node_results"]
    link_results = wn["link_results"]


    junction_dict(wn, node_results, data, junctions, nodes, num_timeperiods, time_ahead)
    tank_dict(wn, node_results, data, tanks, nodes, num_timeperiods, time_ahead)
    res_dict(wn, node_results, data, reservoirs, nodes, num_timeperiods, time_ahead)
    pipe_dict(wn, link_results, data, pipes, num_timeperiods, time_ahead)
    valve_dict(wn, data, valves, num_timeperiods, time_ahead)
    pump_dict(wn, data, pumps, node_results, link_results, timeperiods_hours, num_timeperiods, duration_hours, time_ahead)
    demands_dict(data, nodes, node_results, time_ahead, num_timeperiods)
    return data
end


function junction_dict(wn::Dict{Any,Any}, node_results::Dict{Any,Any}, data::Dict{String,Any}, junctions::Dict{Int64, Any}, nodes::Dict{String,Any}, num_timeperiods::Int64, time_ahead::Vector{DateTime})

    for (key,junc) in wn["junctions"]
        name = junc["name"]
        index_junc = key
        #head and demand are current at each node
        head = node_results["head"][name][:values][1] #head at first timestep (initial_head)
        head = convert(Float64,head)
        demand = node_results["demand"][name][:values][1:num_timeperiods] #to chop the last demand value (recurring initial value)
        demand = convert(Array{Float64,1}, demand)
        demand_timeseries = TimeSeries.TimeArray(time_ahead, demand)
        demand_forcast = demand_timeseries #will possibly add perturbation later
        data["Junction"][index_junc] = Dict{String,Any}("number" => index_junc, "name" => name, "elevation" => junc["elevation"], "head" => head, "demand" => demand_timeseries, "demandforcast" => demand_forcast, "minimum_pressure" => junc["minimum_pressure"], "coordinates" => @NT(lat = junc["coordinates"][2], lon = junc["coordinates"][1]))
        data["Node"][name] = Dict{String,Any}("number" => index_junc, "name" => name, "elevation" => junc["elevation"], "head" => head, "demand" => demand_timeseries, "demandforcast" => demand_forcast, "minimum_pressure" => junc["minimum_pressure"], "coordinates" => @NT(lat = junc["coordinates"][2], lon = junc["coordinates"][1]))
    end
end

function tank_dict(wn::Dict{Any,Any}, node_results::Dict{Any,Any}, data::Dict{String,Any}, tanks::Dict{Int64, Any}, nodes::Dict{String,Any}, num_timeperiods::Int64, time_ahead::Vector{DateTime})
    num_nodes = wn["num_junctions"]
    index_tank = num_nodes
    for (key,tank) in wn["tanks"]
        #head  and demand are initial values
        index_tank = index_tank + 1
        name = tank["name"]
        #assign minimum pressure to the stardard for nodes
        junc = wn["junctions"][1]
        min_pressure = junc["minimum_pressure"]

        head = node_results["head"][name][:values][1] #head at first timestep (initial_head)
        demand = node_results["demand"][name][:values][1:num_timeperiods] #to chop the last demand value (recurring initial value)
        demand_timeseries = TimeSeries.TimeArray(time_ahead, demand) #demand at first timestep (initial_demand)
        demand_forcast = demand_timeseries #will possibly add perturbation later
        area = π * (tank["diameter"]/2)^2 ;
        volume = area * tank["init_level"];
        volumelimits = [x * area for x in [tank["min_level"],tank["max_level"]]];

        data["Node"][name] = Dict{String,Any}("number" => index_tank, "name" => name, "elevation" => tank["elevation"], "head" => convert(Float64,head), "demand" => demand_timeseries, "demandforcast" => demand_forcast, "minimum_pressure" => min_pressure, "coordinates" => @NT(lat = tank["coordinates"][2], lon = tank["coordinates"][1]))
        data["Tank"][index_tank - num_nodes ] = Dict{String, Any}("name" => name, "node" => data["Node"][name], "volumelimits" => @NT(min = volumelimits[1],max = volumelimits[2]), "diameter" => tank["diameter"], "volume" => volume, "area" => area, "level" => tank["init_level"], "levellimits" => @NT(min = tank["min_level"], max = tank["max_level"]))

    end
end

function res_dict(wn::Dict{Any,Any}, node_results::Dict{Any,Any}, data::Dict{String,Any}, reservoirs::Dict{Int64, Any}, nodes::Dict{String, Any}, num_timeperiods::Int64, time_ahead::Vector{DateTime})
    num_nodes = wn["num_junctions"] + wn["num_tanks"]
    index_res = num_nodes
    for (key,res) in wn["reservoirs"]
        index_res = index_res +1
        name = res["name"]
        head = node_results["head"][name][:values][1] #head at first timestep (initial_head)
        demand = node_results["demand"][name][:values][1:num_timeperiods] #to chop the last demand value (recurring initial value)
        demand_timeseries = TimeSeries.TimeArray(time_ahead, demand)
        demand_forcast = demand_timeseries #will possibly add perturbation later
        data["Node"][name] = Dict{String,Any}("number" => index_res, "name" => name, "elevation" => res["base_head"], "head" => convert(Float64,head), "demand" => demand_timeseries, "demandforcast" => demand_forcast, "minimum_pressure" => 0, "coordinates" => @NT(lat = res["coordinates"][2], lon = res["coordinates"][1])) #array of pseudo nodes @ res
        data["Reservoir"][index_res - num_nodes] = Dict{String,Any}("name" => name,"node" => data["Node"][name], "elevation" => res["base_head"]) #base_head = elevation

    end
end

function pipe_dict(wn::Dict{Any,Any}, link_results::Dict{Any, Any}, data ::Dict{String, Any}, pipes::Dict{Int64, Any}, num_timeperiods::Int64, time_ahead::Vector{DateTime})
    index_pipe = 0
    for (key,pipe) in wn["pipes"]
        index_pipe = index_pipe + 1
        name = pipe["name"]
        headloss = link_results["headloss"][name][:values][1] #headloss at first time step
        flowrate = link_results["flowrate"][name][:values][1] #flowrate at first time step
        junction_start = data["Node"][pipe["start_node_name"]]
        junction_end = data["Node"][pipe["end_node_name"]]
        data["Pipe"][index_pipe] = Dict{String,Any}("number" => index_pipe, "name" => name, "connectionpoints" => @NT(from = junction_start, to = junction_end), "diameter" => pipe["diameter"], "length" => pipe["length"],"roughness" => pipe["roughness"], "headloss" => convert(Float64,headloss), "flow" => convert(Float64,flowrate), "initial_status" => pipe["initial_status"])
    end
end

function valve_dict(wn::Dict{Any,Any}, data::Dict{String,Any}, valves::Dict{Int64, Any}, num_timeperiods::Int64, time_ahead::Vector{DateTime})
    num_links = wn["num_pipes"]
    index_valve = num_links
    for (key,valve) in wn["valves"]
        index_valve = index_valve + 1
        name = valve["name"]
        junction_start = data["Node"][valve["start_node_name"]]
        junction_end = data["Node"][valve["end_node_name"]]
        status_index = valve["initial_status"] + 1  # 1=Closed, 2=Open, 3 = Active, 4 = CheckValve
        status_string = ["Closed", "Open", "Active","Check Valve"][status_index]
        data["Valve"][index_valve - num_links] = Dict{String,Any}("number" => index_valve, "name" => name, "connectionpoints" => @NT(from = junction_start, to = junction_end), "status" => status_string , "diameter" => valve["diameter"], "pressure_drop" => valve["setting"])
    end
end

function pump_dict(wn::Dict{Any, Any}, data::Dict{String,Any}, pumps::Dict{Int64, Any}, node_results::Dict{Any, Any}, link_results::Dict{Any, Any}, timeperiods::Float64, num_timeperiods::Int64, duration_hours::Int64, time_ahead::Vector{DateTime})
    num_links = wn["num_pipes"] + wn["num_valves"]
    index_pump = num_links
    wn_python = wn["wn"]
    # @time slopes, intercepts = slope_intercept(wn, wn_python, link_results, node_results, num_timeperiods)
    for (key,pump) in wn["pumps"]
        energy = 0
        name = pump["name"]
        index_pump = index_pump + 1
        junction_start = data["Node"][pump["start_node_name"]]
        junction_end = data["Node"][pump["end_node_name"]]

        if pump["pump_type"] == "HEAD"
            pump_curve_name = pump["pump_curve_name"]
            pump_curve = wn["curves"][pump_curve_name]["points"]
        else
            pump_curve = [(pump["power"],0.0)] #power pump types gives fixed power value,
            #0 is dummy variable to fit tuple type until we decide what we want to do
        end

        #energy price
        price = wn["options"]["energy"]["global_price"]
        pattern = wn["options"]["energy"]["global_pattern"]
        price_array2 = Array{Any}(0)

        if price == 0.0
            # warn("Price is set to 0. Using randomly generated price array with higher weights during peak hours (4pm-8pm).")
            timeperiods_per_hour = 1/(timeperiods)
            #TO:DO check to make sure time_steps / hour is an int or divisor of 4
            price_array = [2*rand(Int(timeperiods_per_hour*16))+1; 7*rand(Int(timeperiods_per_hour*4))+3; 2*rand(Int(timeperiods_per_hour*4))+3]
            if duration_hours > 24
                days = Int(duration_hours/24)
                for i=1:days
                    price_array2 = vcat(price_array2, price_array)
                end
                price_array = price_array2
            end
        elseif typeof(pattern) == Void
            price_array = price * ones(length(time_ahead))
        else
            price_array = price * pattern
            if duration_hours > 24
                days = Int(duration_hours/24)
                for i=1:days
                    price_array2 = vcat(price_array2, price_array)
                end
                price_array = price_array2
            end
        end
        l = length(time_ahead)
        p = length(price_array)
        l == p ? energyprice = TimeSeries.TimeArray(time_ahead, price_array) : println("$l and $p")
        # energyprice = TimeSeries.TimeArray(time_ahead, price_array)
        #efficiency
        efficiency = pump["efficiency"]
        if efficiency == nothing
            # warn("Pump efficiency is 0. Default will be 65% for pump $pump.")
            efficiency = .65
        end

        #energy

        # @time intercept, slope = LeastSquares(name, wn, wn_python, link_results, node_results, num_timeperiods)
        intercept = 1 #intercepts[key]
        slope = 1 #slopes[key]
        data["Pump"][index_pump - num_links] =Dict{String,Any}("number" => index_pump, "name" => name, "connectionpoints" => @NT(from = junction_start, to = junction_end), "status" => pump["status"], "pumpcurve" => pump_curve, "efficiency" => efficiency, "energyprice" => energyprice, "intercept" => intercept, "slope" => slope)
    end
end

function demands_dict(data::Dict{String,Any}, nodes::Dict{String,Any}, node_results::Dict{Any,Any}, time_ahead::Vector{DateTime}, num_timeperiods::Int64)
    demands = Array{WaterDemand}(0)
    max_demand = 20 #placeholder
    i = 0
    for (name, node) in nodes
        i = i+1
        demand = node_results["demand"][name][:values][1:num_timeperiods]
        data["demand"][i] = Dict{String, Any}("name" =>name, "node" =>node, "status" =>true, "max_demand" => max_demand, "demand" => TimeSeries.TimeArray(time_ahead, demand))
    end
end

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
