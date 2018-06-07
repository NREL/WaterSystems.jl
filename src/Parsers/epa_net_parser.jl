export wn_to_struct

##this section includes code that will most likely be called in the module or provided when calling the function
#I include it here to test this piece of code indivually
using TimeSeries
using PowerModels
using DataFrames
# This packages will be removed with Julia v0.7
using Compat
using NamedTuples
using PyCall

include("WaterSystems.jl/src/Models/topological_elements.jl")
include("WaterSystems.jl/src/Models/storage.jl")
include("WaterSystems.jl/src/Models/transport_elements.jl")
include("WaterSystems.jl/src/Models/pumps.jl")
include("WaterSystems.jl/src/Models/water_demand.jl")


###############################################################################
# function definition

@pyimport wntr.network.model as model #import wntr network mod
function wn_to_struct(inp_file)
    #initialize arrays for input into package
    junctions = Array{Junction}(0)
    tanks = Array{RoundTank}(0)
    reservoirs = Array{Reservoir}(0)
    pipes = Array{RegularPipe}(0)
    valves = Array{PressureReducingValve}(0)
    pumps = Array{ConstSpeedPump}(0)

    #set up WaterNetwork using winter
    wn = model.WaterNetworkModel(inp_file)

    #junctions
    for junc in wn[:junction_name_list]
        #question1 is the timeseries in a usable format...output looks like '<Demands: [<TimeSeries: base=0.0, pattern='1', category='EN2 base'>]>
        j = wn[:get_node](junc)
        push!(junctions,Junction(wn[:num_junctions],j[:name],j[:elevation],j[:head],j[:demand_timeseries_list],j[:minimum_pressure],@NT(lat = j[:coordinates][2], lon = j[:coordinates][1])))
    end

    #tanks
    for tank in wn[:tank_name_list]
        t = wn[:get_node](tank)
        #for roundtank only
        #to get junction structure of nodes connected to tank
        pipe = wn[:get_links_for_node](tank)
        #initialize array in case of multiple pipes connected to tank
        #Shouldn't need this once we figure out the node/junction nonesense
        node = nothing
        for i = length(pipe)
            end_junction = wn[:get_link](pipe[i])[:end_node_name]
            start_junction = wn[:get_link](pipe[i])[:start_node_name]
            if  end_junction != tank
                #there should be a more efficient way to do this but couldn't figure out how to get the index of the Junction
                #in junctions containing the appropriate name
                j = wn[:get_node](end_junction)
                node = Junction(wn[:num_junctions],j[:name],j[:elevation],j[:head],j[:demand_timeseries_list],j[:minimum_pressure],@NT(lat = j[:coordinates][2], lon = j[:coordinates][1]))
            else
                j = wn[:get_node](start_junction)
                node = Junction(wn[:num_junctions],j[:name],j[:elevation],j[:head],j[:demand_timeseries_list],j[:minimum_pressure],@NT(lat = j[:coordinates][2], lon = j[:coordinates][1]))
        end
        end
        area = π * t[:diameter] ;
        volume = area * t[:init_level];
        volumelimits = [x * area for x in [t[:min_level],t[:max_level]]];
        push!(tanks,RoundTank(t[:name],node,@NT(min = volumelimits[1],max = volumelimits[2]),volume,area,t[:init_level],@NT(min = t[:min_level], max = t[:max_level])))

    end

    #reservoirs
    #later include r[:head_timeseries]
    for res in wn[:reservoir_name_list]
        r = wn[:get_node](res)
        push!(reservoirs,Reservoir(r[:name],r[:base_head])) #base_head = elevation
        #Reservoir()
    end

    #pipes
    for pipe in wn[:pipe_name_list]
        p = wn[:get_link](pipe)
        #test is node is type junction, if not it does not include the pipe in the output
        s= wn[:get_node](p[:start_node_name])
        e = wn[:get_node](p[:end_node_name])
        if s[:node_type]  == "Junction" &&  e[:node_type] == "Junction"
            junction_start = Junction(wn[:num_junctions], s[:name],s[:elevation],s[:head],s[:demand_timeseries_list],s[:minimum_pressure],@NT(lat = s[:coordinates][2], lon = s[:coordinates][1]))
            junction_end = Junction(wn[:num_junctions], e[:name],e[:elevation],e[:head],e[:demand_timeseries_list],e[:minimum_pressure],@NT(lat = e[:coordinates][2], lon = e[:coordinates][1]))
            push!(pipes,RegularPipe(p[:name], @NT(from = junction_start, to = junction_end),p[:diameter],p[:length],p[:roughness], [(0.0,0.0)],p[:flow]))
        end
    end

    #valves does not work yet
    for valve in wn[:valve_name_list]
        v = wn[:get_link](valve)
        s = wn[:get_node](v[:start_node_name])
        e = wn[:get_node](v[:end_node_name])
        if s[:node_type]  == "Junction" &&  e[:node_type] == "Junction"
            junction_start = Junction(wn[:num_junctions], s[:name],s[:elevation],s[:head],s[:demand_timeseries_list],s[:minimum_pressure],@NT(lat = s[:coordinates][2], lon = s[:coordinates][1]))
            junction_end = Junction(wn[:num_junctions], e[:name],e[:elevation],e[:head],e[:demand_timeseries_list],e[:minimum_pressure],@NT(lat = e[:coordinates][2], lon = e[:coordinates][1]))
            push!(valves, PressureReducingValve(v[:name], @NT(from = junction_start, to = junction_end), v[:status], v[:diameter], v[:setting]))
        end
    end

    #pumps does not work yet
    # for pump in wn[:pump_name_list]
    #     p = wn[:get_link](pump)
    #     #test is node is type junction, if not it does not include the pump in the output
    #     s= wn[:get_node](p[:start_node_name])
    #     e = wn[:get_node](p[:end_node_name])
    #     #wn[:get_curve](wn[:curve_name_list][1]) curves??
    #     #p[:energy_price]
    #     if s[:node_type]  == "Junction" &&  e[:node_type] == "Junction"
    #         junction_start = Junction(wn[:num_junctions], s[:name],s[:elevation],s[:head],s[:demand_timeseries_list],s[:minimum_pressure],@NT(lat = s[:coordinates][2], lon = s[:coordinates][1]))
    #         junction_end = Junction(wn[:num_junctions], e[:name],e[:elevation],e[:head],e[:demand_timeseries_list],e[:minimum_pressure],@NT(lat = e[:coordinates][2], lon = e[:coordinates][1]))
    #         push!(pumps,ConstSpeedPump(p[:name],@NT(from = junction_start, to = junction_end),p[:status], [(0.0,0.0)] , [(0.0,0.0)], p[:efficiency], nothing))
    #     end
    #
    # end

    return junctions, tanks, reservoirs, pipes, valves #, pumps
end
