@pyimport wntr.network.controls as controls
@pyimport wntr.sim.epanet as sims
include("UpdateExtrema.jl")
include("ManipulateTanks.jl")
include("ManipulatePumps.jl")
function Q_extrema(wn_dict::Dict{Any,Any}, Q_lb::Float64, tight_coef::Float64)
    Qmax_dict = Dict{String, Float64}()
    Qmin_dict = Dict{String, Float64}()
    Hmin_dict = Dict{String,Float64}()
    Hmax_dict= Dict{String,Float64}()
    wn = wn_dict["wn"]
    controls_dict = wn_dict["controls"]
    control_names = keys(controls_dict)
    duration = wn["options"]["time"]["duration"]
    time_periods = wn["options"]["time"]["report_timestep"]
    time_periods = convert(Float64, time_periods)
    time_steps = 24 #duration/time_periods
    #time_steps = convert(Int64, time_steps)
    ############ Level Limits Only ##################################
    tank_level(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, tight_coef, Q_lb)
    ############ Tank Controls and Level Limits #####################
    remove_controls(wn)

    tank_triggers(wn, wn_dict, controls_dict, control_names, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, tight_coef, Q_lb)
    ################ Tank Controls only #############################
    for (key, tank) in wn_dict["tanks"]
        wn[:get_node](key)[:init_level] = tank["init_level"]
    end
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, 2, 2, tight_coef, Q_lb)
    ############## Restore wn ########################################
    remove_controls(wn)
    for (name, control) in controls_dict
        wn[:add_control](name, control)
    end
    ############## Random Level Limits Only ##########################

    tank_level_rand(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, tight_coef, Q_lb)

    ############## Random Tank Controls and Random Level Limits ######
    remove_controls(wn)
    tank_triggers_rand(wn, wn_dict, controls_dict, control_names, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, tight_coef, Q_lb)

    ############# Random Tank Controls Only ##########################
    for (key, tank) in wn_dict["tanks"]
        wn[:get_node](key)[:init_level] = tank["init_level"]
    end
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, 2, 2, tight_coef, Q_lb)
    ############## Restore wn ########################################
    remove_controls(wn)
    for (name, control) in controls_dict
        wn[:add_control](name, control)
    end
    ################### Manipulate Pumps ##############################
    ################### Pumps all on after TN only ####################
    remove_controls(wn_dict, wn) #only removes pump controls
    for Tn = 1:length(time_steps)
        OnAfterTn(wn_dict, wn, Tn, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, tight_coef, Q_lb)
    end
    ############## Restore wn ########################################
    remove_controls(wn)
    for (name, control) in controls_dict
        wn[:add_control](name, control)
    end
    ##################Pumps all Off after TN #########################
    remove_controls(wn_dict, wn) #only removes pump controls
    for Tn = 1:length(time_steps)
        OffAfterTn(wn_dict, wn, Tn, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, tight_coef, Q_lb)
    end
    ############## Restore wn ########################################
    remove_controls(wn)
    for (name, control) in controls_dict
        wn[:add_control](name, control)
    end
    ################### Pumps on and Off at Random Times #############
    remove_controls(wn_dict, wn) #only removes pump controls
    RandomTime(wn_dict, wn, time_steps, time_periods, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, tight_coef, Q_lb)
    ######### Random Initial Levels and Pump On/Off randomly #########
    tank_level_rand(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, tight_coef, Q_lb)
    ############## Restore wn ########################################
    remove_controls(wn)
    for (name, control) in controls_dict
        wn[:add_control](name, control)
    end
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, 2, 2, tight_coef, Q_lb) #test original system
    ############ Finalize Qmax/Qmin ##################################
    num_tanks = length(wn_dict["tanks"])
    num_sim = 2*num_tanks
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, num_sim, num_sim +1, tight_coef, Q_lb)

    return Qmin_dict, Qmax_dict, Hmin_dict, Hmax_dict

end

function remove_controls(wn::PyCall.PyObject)
    for name in wn[:control_name_list]
        wn[:remove_control](name)
    end
end

function remove_controls(wn_dict::Dict{Any,Any}, wn::PyCall.PyObject)
    controls_dict = wn_dict["controls"]
    for name in wn[:control_name_list]
        target_obj = controls_dict[name][:_then_actions][1][:_target_obj]
        if target_obj[:link_type] == "Pump"
            wn[:remove_control](name)
        end
    end
end
