## much of this is modified from legacy Amanda Mason code and appears to have a lot of
## unnecessary and/or redundant code; rather than creating the "data" dictionary, why not
## just create the Julia struct objects directly from the python wntr dictionary? JJS,
## 12/26/19

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
    patterns = Vector{Any}()
    curves = Vector{Any}()

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
    ## now only used (I think) for getting pump-flow estimates when head-curve not provided;
    ## should we only run an EPANET simulation in that case? JJS 12/28/19
    node_results = wn["node_results"]
    link_results = wn["link_results"]
    
    junction_dict(wn, node_results, junctions)
    tank_dict(wn, node_results, tanks, junctions, num_timeperiods, time_ahead)
    res_dict(wn, node_results, reservoirs, junctions, num_timeperiods, time_ahead)
    # removing 'time_ahead' info from demand_dict; can remove it from tank_dict and
    # res_dict also, JJS 12/19/19
    demand_dict!(wn, demands)
    pattern_dict!(wn, patterns)
    curve_dict!(wn, curves)
    link_dict!(wn, links, junctions)
    pipe_dict!(wn, pipes)
    pump_dict!(wn, link_results, pumps, curves) # will add to curves if pumps are power type
    valve_dict(wn, valves)

    data = Dict{String,Any}( "Junction" => junctions, "Tank" => tanks,
                             "Reservoir" =>reservoirs, "Link" => links, "Pipe" => pipes,
                             "Valve" => valves, "Pump" => pumps, "Demand" => demands,
                             "Pattern" => patterns, "Curve" => curves)

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

function demand_dict!(wn::Dict{Any,Any}, demands::Vector{Any})
    ## this has been redone, not using simulation results, and not pulling the actual
    ## values, only the name of the pattern; JJS 12/12/19
    ### add a field for average or maximum demand? the scaling of base_demand values can
    ### vary wildly (along with patterns) -- see Net3, for example, JJS 12/24/19
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

function pattern_dict!(wn::Dict{Any,Any}, patterns::Vector{Any})
    for pattern in wn["patterns"]
        push!(patterns, Dict{String,Any}("name" => pattern["name"],
                                         "multipliers" => pattern["multipliers"]))
    end
end

function curve_dict!(wn::Dict{Any,Any}, curves::Vector{Any})
    for (i, (name,curve)) in enumerate(wn["curves"])
        push!(curves, Dict{String,Any}("name" => name, "type" => curve["curve_type"],
                                       "points" => curve["points"]))
    end
end

# adding this as holdover until all this dict parsing code can be rewritten, JJS 12/11/19
function link_dict!(wn::Dict{Any,Any}, links::Dict{String,Any},
                   junctions::Dict{String,Any})
    for link in wn["links_vec"]
        name = link["name"]
        junction_start = junctions[link["start_node_name"]]
        junction_end = junctions[link["end_node_name"]]
        links[name] = Dict{String,Any}("name" => name, "connectionpoints"
                                       => (from = junction_start, to = junction_end))
    end
end

function pipe_dict!(wn::Dict{Any,Any}, pipes::Vector{Any})
    for (key,pipe) in wn["pipes"]
        name = pipe["name"]
        push!(pipes, Dict{String,Any}("name" => name,
                                      "diameter" => pipe["diameter"],
                                      "length" => pipe["length"],
                                      "roughness" => pipe["roughness"],
                                      "initial_status" => pipe["initial_status"],
                                      "control_pipe" => pipe["control_pipe"],
                                      "cv" => pipe["cv"]))
    end
end

function pump_dict!(wn::Dict{Any, Any}, link_results::Dict{Any,Any}, pumps::Vector{Any},
                    curves::Vector{Any})
    # get global value to use for pump efficiency when not provided
    global_effnc = wn["options"]["energy"]["global_efficiency"]
    # I think wntr will always populate global efficiency; if not, we can use these lines,
    # JJS 12/27/19
    # if global_effnc == nothing
    #     global_effnc = 0.75 
    # end

    ## global energy price and pattern?
    global_price = wn["options"]["energy"]["global_price"]
    global_pattern = wn["options"]["energy"]["global_pattern"]
    
    for pump in wn["pumps"]
        name = pump["name"]
        # pump head and efficiency OR power values
        type = pump["pump_type"] # HEAD or POWER
        efficiency = pump["efficiency"]
        if type == "HEAD"
            head_curve_name = pump["pump_curve_name"]
            if efficiency == nothing
                efficiency = global_effnc
            else # then will a curve always be provided? need to check if pump-specific
                # single-values are ever used in .inp files
                efficiency = efficiency.name # efficiency curve name
            end
            power = nothing
        else # POWER -- this needs testing, e.g., with ky3.inp JJS 12/29/19
            efficiency = global_effnc # needed for estimating BEP
            power = pump["power"] # W
            # use sim results to estimate the nominal flow rate of the pump for BEP
            #flows = link_results["flowrate"].name # doesn't work
            flows = link_results["flowrate"][name] # gives a warning in 1.3
            # convert from pyobject (pandas I think) to julia -- there may be a more
            # elegant way to do this... JJS 12/28/19
            flows = [val for val in flows]
            head_curve_name = name*"_head_power"
            ## here, the head is calculated from the flow and power; instead, take the head
            ## value from the simulation results as well and just ignore the power? there
            ## are clear inconsistencies here! JJS 01/02/20
            head_point = head_curve_from_power(power, efficiency, flows) # utils/PumpCoefs.jl
            push!(curves, Dict{String,Any}("name" => head_curve_name,
                                           "type" => "HEAD",
                                           "points" => head_point))
        end
        
        # energy base price and pattern
        # why would energy price (and pattern) be specific to each pump???  JJS 12/27/19
        price = pump["energy_price"]
        if price == nothing
            price = global_price
        end
        price_pattern = pump["energy_pattern"]
        if price_pattern == nothing
            price_pattern = global_pattern
        end

        push!(pumps, Dict{String,Any}("name" => name,
                                      "type" => type,
                                      "head_curve_name" => head_curve_name,
                                      "efficiency" => efficiency,
                                      "power" => power,
                                      "price" => price,
                                      "price_pattern" => price_pattern))
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
