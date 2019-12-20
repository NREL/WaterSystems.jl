## much of this is modified from legacy Amanda Mason code and appears to have a lot of
## unnecessary and/or redundant code, JJS, 12/5/19

"""
Create a dictionary of the network using wntr to parse the inp file
"""
function make_dict(inp_file::String)
    junctions = Dict{String,Any}()
    tanks = Vector{Any}()
    reservoirs = Vector{Any}()
    demands = Vector{Any}()
    links = Dict{String,Any}()
    pipes = Vector{Any}()
    pumps = Vector{Any}()
    valves = Vector{Any}()

    wn = wntr_dict(inp_file)
    
    duration = wn["options"]["time"]["duration"]
    duration != 0 ? duration_hours = from_seconds(duration)[1] : error("Duration is set to 0. Simulation will not run. Modify .inp file.")
    time_periods = wn["options"]["time"]["report_timestep"]
    timeperiods_hours = time_periods/3600
    
    start_time = wn["options"]["time"]["report_start"]
    num_timeperiods = duration/time_periods

    mod(num_timeperiods, 1) == 0 ? num_timeperiods = Int(num_timeperiods) : error("Duration does not correspond to a full timestep.")

    hours, minutes, seconds  = from_seconds(start_time)
    start = "$hours:$minutes:$seconds"
    start_day =  DateTime(start, "H:M:S")
    end_day = start_day + Second(duration-time_periods)

    time_ahead = collect(start_day:Second(time_periods):end_day)
    ## should not use results! JJS 12/19/19
    node_results = wn["node_results"]
    link_results = wn["link_results"]
    
    junction_dict(wn, node_results, junctions)
    tank_dict(wn, node_results, tanks, junctions, num_timeperiods, time_ahead)
    res_dict(wn, node_results, reservoirs, junctions, num_timeperiods, time_ahead)
    # removing 'time_ahead' info from demands_dict; can remove it from tank_dict and
    # res_dict also, JJS 12/19/19
    demands_dict!(wn, demands)
    link_dict!(wn, link_results, links, junctions)
    pipe_dict(wn, link_results, pipes,junctions)
    pump_dict(wn, junctions,pumps, node_results, link_results)
    valve_dict(wn, valves)

    data = Dict{String,Any}( "Junction" => junctions, "Tank" => tanks,
                             "Reservoir" =>reservoirs, "Link" => links, "Pipe" => pipes,
                             "Valve" => valves, "Pump" => pumps, "Demand" => demands)

    data["wntr"] = Dict{String,Any}("duration"=> duration_hours,
                                    "timeperiods" => timeperiods_hours,
                                    "num_timeperiods" => num_timeperiods,
                                    "start" => start_day, "end" => end_day)
    # data["wntr_dict"] = wn
    return data
end


# these functions should all have '!' appended to their names
function junction_dict(wn::Dict{Any,Any}, node_results::Dict{Any,Any}, junctions::Dict{String,Any})

    for junc in wn["junctions"]
        name = junc["name"]
        #head and demand are current at each node
        head = get(node_results["head"],name).values[1] #Meters Total Head/ Hydraulic Head = Pressure Head + Elevation
        head = convert(Float64,head)
        junctions[name] = Dict{String,Any}("name" => name, "elevation" => junc["elevation"], "head" => head, "minimum_pressure" => junc["minimum_pressure"], "coordinates" => (lat = junc["coordinates"][2], lon = junc["coordinates"][1]))
    end
end

function demands_dict!(wn::Dict{Any,Any}, demands::Vector{Any})
    ## this has been redone, not using simulation results, and not pulling the actual
    ## values, only the name of the pattern JJS 12/12/19
    for junction in wn["junctions"]
        name = junction["name"]
        base_demand = junction["base_demand"]
        if base_demand != 0 # or nothing???? need to test with inp files with blank demands
            demand_list = junction["demand_timeseries_list"]
            if length(demand_list) != 1
                @warn("Only one demand series is supported at a junction. The first will be used")
            end
            # `demand_list[0]` gives a warning, not sure why; so using get(demand_list, 0)
            # for now, JJS 12/12/19
            pattern_name = get(demand_list, 0).pattern_name
            # the absolute demand values -- not using now, JJS 12/19/19
            #demand = base_demand*get(demand_list, 0).pattern.multipliers 
            #demand_timeseries = TimeSeries.TimeArray(time_ahead, demand)
            push!(demands, Dict{String, Any}("name" =>name, "node" =>junction,
                                             "base_demand" => base_demand,
                                             "pattern_name" => pattern_name))
        end
    end
end

function tank_dict(wn::Dict{Any,Any}, node_results::Dict{Any,Any}, tanks::Vector{Any}, junctions::Dict{String,Any}, num_timeperiods::Int64, time_ahead::Vector{DateTime})
    #assign minimum pressure to the stardard for nodes
    junc = wn["junctions"][1]
    min_pressure = junc["minimum_pressure"] #m assumes fliud density of 1000 kg/m^3
    for tank in wn["tanks"]
        #head  and demand are initial values
        name = tank["name"]
        head = get(node_results["head"],name).values[1] #m Total Head/Hydraulc Head
        # demand = get(node_results["demand"],name).values[1:num_timeperiods] #m^3/sec
        # demand_timeseries = TimeSeries.TimeArray(time_ahead, demand) #demand at first timestep (initial_demand)
        # demand_forecast = demand_timeseries #will possibly add perturbation later
        if tank["vol_curve_name"] != nothing
            @warn("A tank in this network is not cylindrical. Only cylindrical tanks are currently supported.")
        end
        # area, volume, and volume-limits can be removed as they are not used in the struct;
        # JJS 12/12/19
        area = π * (tank["diameter"]/2)^2 ; #m^2
        volume = area * tank["init_level"]; #m^3
        volumelimits = [x * area for x in [tank["min_level"],tank["max_level"]]];
        haskey(junctions, name) ? junc_name = "Junction- " * name : junc_name = name
        junctions[name] = Dict{String,Any}("name" => junc_name, "elevation" => tank["elevation"], "head" => convert(Float64,head), "minimum_pressure" => min_pressure, "coordinates" => (lat = tank["coordinates"][2], lon = tank["coordinates"][1]))
        push!(tanks, Dict{String, Any}("name" => name, "volumelimits" => (min = volumelimits[1],max = volumelimits[2]), "diameter" => tank["diameter"], "volume" => volume, "area" => area, "level" => tank["init_level"], "levellimits" => (min = tank["min_level"], max = tank["max_level"])))

    end
end

function res_dict(wn::Dict{Any,Any}, node_results::Dict{Any,Any}, reservoirs::Vector{Any}, junctions::Dict{String,Any}, num_timeperiods::Int64, time_ahead::Vector{DateTime})
    for res in wn["reservoirs"]
        name = res["name"]
        head = get(node_results["head"],name).values[1] #m Total head/ Hydraulic head note: base_head = elevation
        # demand = get(node_results["demand"],name).values[1:num_timeperiods] #m^3/sec
        # demand_timeseries = TimeSeries.TimeArray(time_ahead, demand)
        # demand_forecast = demand_timeseries #will possibly add perturbation later
        haskey(junctions, name) ? junc_name = "Junction- " * name : junc_name = name
        junctions[name] = Dict{String,Any}("name" => junc_name, "elevation" => res["base_head"], "head" => convert(Float64,head), "minimum_pressure" => 0, "coordinates" => (lat = res["coordinates"][2], lon = res["coordinates"][1])) #array of pseudo nodes @ res
        push!(reservoirs, Dict{String,Any}("name" => name, "elevation" => res["base_head"])) #base_head = elevation

    end
end

# adding this as holdover until all this dict parsing code can be rewritten, JJS 12/11/19
function link_dict!(wn::Dict{Any,Any}, link_results::Dict{Any, Any}, links::Dict{String,Any},
                   junctions::Dict{String,Any})
    for link in wn["links_vec"]
        name = link["name"]
        junction_start = junctions[link["start_node_name"]]
        junction_end = junctions[link["end_node_name"]]
        links[name] = Dict{String,Any}("name" => name, "connectionpoints" => (from = junction_start, to = junction_end))
    end
end

function pipe_dict(wn::Dict{Any,Any}, link_results::Dict{Any, Any}, pipes::Vector{Any}, junctions::Dict{String,Any})
    for (key,pipe) in wn["pipes"]
        name = pipe["name"]
        headloss = get(link_results["headloss"],name).values[1] #m
        flowrate = get(link_results["flowrate"],name).values[1] #m^3/sec
        junction_start = junctions[pipe["start_node_name"]]
        junction_end = junctions[pipe["end_node_name"]]
        push!(pipes, Dict{String,Any}("name" => name, "connectionpoints" => (from = junction_start, to = junction_end), "diameter" => pipe["diameter"], "length" => pipe["length"],"roughness" => pipe["roughness"], "headloss" => convert(Float64,headloss), "flow" => convert(Float64,flowrate), "initial_status" => pipe["initial_status"], "control_pipe" => pipe["control_pipe"], "cv" => pipe["cv"]))
    end
end

function valve_dict(wn::Dict{Any,Any}, valves::Vector{Any})
    for valve in wn["valves"]
        name = valve["name"]
        if typeof(valve["valve_type"]) == String
            valve_type = valve["valve_type"]
        else
            valve_type = "GPV"
        end 
        junction_start = data["Node"][valve["start_node_name"]]
        junction_end = data["Node"][valve["end_node_name"]]
        status_index = valve["initial_status"] + 1  # 1=Closed, 2=Open, 3 = Active, 4 = CheckValve
        status_string = ["Closed", "Open", "Active","Check Valve"][status_index] #Active = partially open
        push!(valves, Dict{String,Any}("name" => name, "connectionpoints" => (from = junction_start, to = junction_end), "status" => status_string , "diameter" => valve["diameter"], "pressure_drop" => valve["setting"], "valvetype"=>valve_type))
    end
end

function pump_dict(wn::Dict{Any, Any}, junctions::Dict{String,Any}, pumps::Vector{Any}, node_results::Dict{Any, Any}, link_results::Dict{Any, Any})
    for pump in wn["pumps"]
        energy = 0
        efficiency = nothing
        name = pump["name"]
        junction_start = junctions[pump["start_node_name"]]
        junction_end = junctions[pump["end_node_name"]]

        if pump["pump_type"] == "HEAD"
            pump_curve_name = pump["pump_curve_name"]
            pump_curve = wn["curves"][pump_curve_name]["points"]
        else
            pump_curve = [(pump["power"],0.0)] #power pump types gives fixed power value,
            #0 is dummy variable to fit tuple type until we decide what we want to do
        end

        #energy price
        price = wn["options"]["energy"]["global_price"] # Power  $/kW hrs
        pattern = wn["options"]["energy"]["global_pattern"]# $/kW hrs
        price_array2 = Array{Any}(undef,0)
        price_array = Array{Any}(undef,0)
        energyprice = TimeSeries.TimeArray(TimeSeries.today(), [1.0])
        # if price == 0
        #     pricearray = price
        #     # warn("Price is set to 0. Using randomly generated price array with higher weights during peak hours (4pm-8pm).")
        #     # timeperiods_per_hour = 1/(timeperiods)
        #     # #TO:DO check to make sure time_steps / hour is an int or divisor of 4
        #     #price_array = [2*rand(Int(timeperiods_per_hour*16))+1; 7*rand(Int(timeperiods_per_hour*4))+3; 2*rand(Int(timeperiods_per_hour*4))+3]
        #     if duration_hours > 24
        #         days = Int(duration_hours/24)
        #         for i=1:days
        #             price_array2 = vcat(price_array2, price_array)
        #         end
        #         price_array = price_array2
        #     end
        # elseif typeof(pattern) == Nothing
        #     price_array = price * ones(length(time_ahead))
        # else
        #     price_array = price * pattern
        #     if duration_hours > 24
        #         days = Int(duration_hours/24)
        #         for i=1:days
        #             price_array2 = vcat(price_array2, price_array)
        #         end
        #         price_array = price_array2
        #     end
        # end
        # l = length(time_ahead)
        # p = length(price_array)
        # l == p ? energyprice = TimeSeries.TimeArray(time_ahead, price_array) : println("$l and $p")
        # energyprice = TimeSeries.TimeArray(time_ahead, price_array)
        #efficiency
        try
            efficiency = pump["efficiency"].points
        catch
            wn["options"]["energy"]["global_efficiency"] != nothing ? efficiency = wn["options"]["energy"]["global_efficiency"] : efficiency = 0.65
        end
        push!(pumps, Dict{String,Any}("name" => name, "connectionpoints" => (from = junction_start, to = junction_end), "status" => pump["status"], "pumpcurve" => pump_curve, "efficiency" => efficiency, "energyprice" => energyprice))
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
