@pyimport wntr.network.controls as controls
@pyimport wntr.sim.epanet as sims
function Q_extrema(wn_dict::Dict{Any,Any}, Q_lb::Float64, tight_coef::Float64)
    Qmax_dict = Dict{String, Float64}()
    Qmin_dict = Dict{String, Float64}()
    wn = wn_dict["wn"]
    controls_dict = wn_dict["controls"]
    control_names = keys(controls_dict)

    ############ Level Limits Only ##################################
    tank_level(wn, wn_dict, Qmax_dict, Qmin_dict, tight_coef, Q_lb)
    ############ Tank Controls and Level Limits #####################
    remove_controls(wn)

    tank_triggers(wn, wn_dict, controls_dict, control_names, Qmax_dict, Qmin_dict, tight_coef, Q_lb)
    ################ Tank Controls only #############################
    for (key, tank) in wn_dict["tanks"]
        wn[:get_node](key)[:init_level] = tank["init_level"]
    end
    run_sims(wn, wn_dict, Qmax_dict, Qmin_dict, 1, 1, tight_coef, Q_lb)
    ############## Restore wn ########################################
    remove_controls(wn)
    for (name, control) in controls_dict
        wn[:add_control](name, control)
    end
    ############## Random Level Limits Only ##########################

    tank_level_rand(wn, wn_dict, Qmax_dict, Qmin_dict, tight_coef, Q_lb)

    ############## Random Tank Controls and Random Level Limits ######
    remove_controls(wn)
    tank_triggers_rand(wn, wn_dict, controls_dict, control_names, Qmax_dict, Qmin_dict, tight_coef, Q_lb)

    ############# Random Tank Controls Only ##########################
    for (key, tank) in wn_dict["tanks"]
        wn[:get_node](key)[:init_level] = tank["init_level"]
    end
    run_sims(wn, wn_dict, Qmax_dict, Qmin_dict, 1, 1, tight_coef, Q_lb)

    ############ Finalize Qmax/Qmin ##################################
    num_tanks = length(wn_dict["tanks"])
    num_sim = 2*num_tanks
    run_sims(wn, wn_dict, Qmax_dict, Qmin_dict, num_sim, num_sim, tight_coef, Q_lb)


    return Qmax_dict, Qmin_dict

end

function tank_triggers(wn::PyCall.PyObject, wn_dict::Dict{Any,Any}, controls_dict::Dict{Any,Any}, control_names::Base.KeyIterator{Dict{Any,Any}}, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)
    num_controls = length(control_names)
    for name in control_names
        source_obj = controls_dict[name][:_condition][:_source_obj]
        source_obj_name = source_obj[:name]
        tank = wn_dict["tanks"][source_obj_name]
        interval = tank["max_level"] - tank["min_level"]
        cond1 = controls.ValueCondition(source_obj, "level", ">", tank["max_level"] - interval*0.05)
        cond2 = controls.ValueCondition(source_obj, "level", "<", tank["min_level"] + interval*0.05)

        target_obj = controls_dict[name][:_then_actions][1][:_target_obj]
        target_obj_name = target_obj[:name]
        act1 = controls.ControlAction(target_obj, "status", 0)
        act2 = controls.ControlAction(target_obj, "status", 1)

        control1 = controls.Control(cond1, act1)
        control2 = controls.Control(cond2, act2)

        wn[:add_control]("$name-1", control1)
        wn[:add_control]("$name-2", control2)
    end
    run_sims(wn, wn_dict, Qmax_dict, Qmin_dict, 1, 1, tight_coef, Q_lb)
end

function tank_level(wn::PyCall.PyObject, wn_dict::Dict{Any,Any}, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)
    num_tanks = length(wn_dict["tanks"])
    num_sim = 2*num_tanks

    for sim = 1:num_sim
        switch = bin(sim, num_tanks)
        for (i, name) in enumerate(keys(wn_dict["tanks"]))
            switch[i] == '0' ? wn[:get_node](name)[:init_level] = wn_dict["tanks"][name]["max_level"] : wn[:get_node](name)[:init_level] = wn_dict["tanks"][name]["min_level"]
        end
        run_sims(wn, wn_dict, Qmax_dict, Qmin_dict, num_sim, sim, tight_coef, Q_lb)
    end
end

function tank_triggers_rand(wn::PyCall.PyObject, wn_dict::Dict{Any,Any}, controls_dict::Dict{Any,Any}, control_names::Base.KeyIterator{Dict{Any,Any}}, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)
    controls_dict = wn_dict["controls"]
    control_names = keys(controls_dict)
    for name in control_names
        source_obj = controls_dict[name][:_condition][:_source_obj]
        source_obj_name = source_obj[:name]
        tank = wn_dict["tanks"][source_obj_name]
        interval = tank["max_level"] - tank["min_level"]

        rand_coefs = rand(2)
        sort!(rand_coefs)
        cond1 = controls.ValueCondition(source_obj, "level", ">", tank["min_level"]+ interval*rand_coefs[2])
        cond2 = controls.ValueCondition(source_obj, "level", "<", tank["min_level"]+ interval*rand_coefs[1])

        target_obj = controls_dict[name][:_then_actions][1][:_target_obj]
        target_obj_name = target_obj[:name]
        act1 = controls.ControlAction(target_obj, "status", 0)
        act2 = controls.ControlAction(target_obj, "status", 1)

        control1 = controls.Control(cond1, act1)
        control2 = controls.Control(cond2, act2)

        wn[:add_control]("$name-1", control1)
        wn[:add_control]("$name-2", control2)
    end
    run_sims(wn, wn_dict, Qmax_dict, Qmin_dict, 1, 1, tight_coef, Q_lb)
end

function tank_level_rand(wn::PyCall.PyObject, wn_dict::Dict{Any,Any}, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)

    num_tanks = length(wn_dict["tanks"])
    num_sim = 2*num_tanks

    for sim = 1:num_sim
        for (i, name) in enumerate(keys(wn_dict["tanks"]))
            rand_coef = rand(1)
            wn[:get_node](name)[:init_level] = wn_dict["tanks"][name]["min_level"] + rand_coef[1]*(wn_dict["tanks"][name]["max_level"]- wn_dict["tanks"][name]["min_level"])
        end
        run_sims(wn, wn_dict, Qmax_dict, Qmin_dict, num_sim, sim, tight_coef, Q_lb)
    end
end

function remove_controls(wn::PyCall.PyObject)
    for name in wn[:control_name_list]
        wn[:remove_control](name)
    end
end

function run_sims(wn::PyCall.PyObject, wn_dict::Dict{Any,Any}, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, num_sim::Int64, sim::Int64, tight_coef::Float64, Q_lb::Float64)
    wns = sims.EpanetSimulator(wn)
    print(sim)
    results = wns[:run_sim]()
    link_results = results[:link]
    pipes = wn_dict["pipes"]
    valves = wn_dict["valves"]
    links = merge(pipes, valves)
    for (key, link) in links
        name = link["name"]
        flows = link_results["flowrate"][name][:values]
        convert(Array{Float64}, flows)
        if sim == 1
            Qmin_dict[name] = convert(Float64,minimum(flows))
            Qmax_dict[name] = convert(Float64, maximum(flows))
        elseif sim < num_sim
            Qmin = Qmin_dict[name]
            Qmax = Qmax_dict[name]

            Qmin_dict[name] = minimum([Qmin, minimum(flows)])
            Qmax_dict[name] = maximum([Qmax, maximum(flows)])
        else
            Qmax_val = Qmax_dict[name]
            Qmin_val = Qmin_dict[name]
            gap = Qmax_val - Qmin_val
            if Qmin_val <= 0
                Qmin_dict[name] = Qmin_val - tight_coef*gap
            else
                Qmin_dict[name] = minimum([Q_lb, Qmin_val])
            end
            if Qmax_val >= 0
                Qmax_dict[name] = Qmax_val + tight_coef*gap
            else
                Qmax_dict[name] = maximum([Qmax_val, -Q_lb])
            end
        end
    end

    for (key, pump) in wn_dict["pumps"]
        name = pump["name"]
        flow = link_results["flowrate"][name][:values]
        convert(Array{Float64}, flow)
        if sim != 1
            flow = flow[flow .> 0]
        end

        if length(flow) !=0 || sim == num_sim
            if sim == 1
                Qmin_dict[name] = minimum(flow)
                Qmax_dict[name]= maximum(flow)
            elseif sim < num_sim
                Qmax = Qmax_dict[name]
                Qmin = Qmin_dict[name]
                Qmin_dict[name] = minimum([Qmin, minimum(flow)])
                Qmax_dict[name] = maximum([Qmax, maximum(flow)])
            else
                Qmin_val = Qmin_dict[name]
                Qmax_val = Qmax_dict[name]

                gap = Qmax_val - Qmin_val
                println("$name")
                if pump["pump_type"] == "HEAD"
                    println("$sim")
                    pump_curve_name = pump["pump_curve_name"]
                    pump_churve = wn_dict["curves"][pump_curve_name]["points"]
                else
                    pump_curve = [(pump["power"],0.0)] #power pump types gives fixed power value,
                end

                Qmin_dict[name] = maximum([pump_curve[1][1], Qmin_val - tight_coef*gap])
                Qmax_dict[name] = minimum([pump_curve[length(pump_curve)][1], Qmax_val + tight_coef*gap])
            end
        end
    end
end
# else
#     Qmin_val = Qmin_dict[name]
#     Qmax_val = Qmax_dict[name]
#
#     gap = Qmax_val - Qmin_val
#
#     pump_curve_name = pump["pump_curve_name"]
#     pump_curve = wn["curves"][pump_curve_name]["points"]
#     Qmin[name] = maximum(pump_curve[1][1], Qmin_val - tight_coef*gap)
#     Qmax[name] = minimum(pump_curve[length(pump_curve)][1], Qmax_val +tight_coef*gap)
# end

#     else
#         Qmax_val = Qmax_dict[name]
#         Qmin_val = Qmin_dict[name]
#         gap = Qmax_val - Qmin_val
#         if Qmin_val <= 0
#             Qmin_dict[name] = Qmin_val - tight_coef*gap
#         else
#             Qmin_dict[name] = minimum(Q_lb, Qmin_val)
#         end
#         if Qmax_val >= 0
#             Qmax_dict[name] = Qmax_val + tight_coef*gap
#         else
#             Qmax_dict[name] = maximum(Qmax_val, -Q_lb)
#         end
#     end
# end
# elseif sim == num_sim
#     for (key, tank) in wn_dict["tanks"]
#         wn[:get_node](key)[:init_level] = tank["init_level"]
#     end
#     control_names = wn[:control_name_list]
#     for name in control_names
#         println(name)
#         wn[:remove_control](name)
#     end
#     for (key, control) in wn_dict["controls"]
#         println("key $key")
#         wn[:add_control](key, control)
#     end
# end
# else
#     controls_dict = wn_dict["controls"]
#     control_names = keys(controls_dict)
#     for name in control_names
#         println(name)
#         wn[:remove_control](name)
#     end
#     for name in control_names
#         source_obj = controls_dict[name][:_condition][:_source_obj]
#         source_obj_name = source_obj[:name]
#         tank = wn_dict["tanks"][source_obj_name]
#         interval = tank["max_level"] - tank["min_level"]
#
#         rand_coefs = rand(2)
#         sort!(rand_coefs)
#         cond1 = controls.ValueCondition(source_obj, "level", ">", tank["min_level"]+ interval*rand_coefs[2])
#         cond2 = controls.ValueCondition(source_obj, "level", "<", tank["min_level"]+ interval*rand_coefs[1])
#
#         target_obj = controls_dict[name][:_then_actions][1][:_target_obj]
#         target_obj_name = target_obj[:name]
#         act1 = controls.ControlAction(target_obj, "status", 0)
#         act2 = controls.ControlAction(target_obj, "status", 1)
#
#         control1 = controls.Control(cond1, act1)
#         control2 = controls.Control(cond2, act2)
#
#         wn[:add_control]("$name-1", control1)
#         wn[:add_control]("$name-2", control2
