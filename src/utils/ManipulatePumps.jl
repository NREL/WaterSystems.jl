include("UpdateExtrema.jl")
function ExtremeTriggerLevels(wn_dict::Dict{Any,Any}, wn::PyCall.PyObject, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, Hmax_dict::Dict{String, Float64}, Hmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)
    controls_dict = wn_dict["controls"]
    for (name, control) in controls_dict
        source_obj = controls_dict[name][:_condition][:_source_obj]
        target_obj = controls_dict[name][:_then_actions][1][:_target_obj]
        if source_obj[:node_type] == "Tank" && target_obj[:link_type] == "Pump"
            tank_name = source_obj[:name]
            pump_name = targer_obj[:name]

            tank = wn_dict["tanks"][tank_name]
            interval = tank["max_level"] - tank["min_level"]
            cond1 = controls.ValueCondition(source_obj, "level", ">", tank["max_level"] - interval*0.05)
            cond2 = controls.ValueCondition(source_obj, "level", "<", tank["min_level"] + interval*0.05)

            pump = wn_dict["pumps"][pump_name]
            act1 = controls.ControlAction(target_obj, "status", 0)
            act2 = controls.ControlAction(target_obj, "status", 1)

            control1 = controls.Control(cond1, act1)
            control2 = controls.Control(cond2, act2)

            wn[:add_control]("$name-1", control1)
            wn[:add_control]("$name-2", control2)
        end
    end
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, 2, 2, tight_coef, Q_lb)
end

function RandomTriggerLevels(wn_dict::Dict{Any,Any}, wn::PyCall.PyObject, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, Hmax_dict::Dict{String, Float64}, Hmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)
    controls_dict = wn_dict["controls"]

    for (name, control) in controls_dict
        source_obj = controls_dict[name][:_condition][:_source_obj]
        target_obj = controls_dict[name][:_then_actions][1][:_target_obj]
        if source_obj[:node_type] == "Tank" && target_obj[:link_type] == "Pump"
            tank_name = source_obj[:name]
            pump_name = targer_obj[:name]

            tank = wn_dict["tanks"][tank_name]
            interval = tank["max_level"] - tank["min_level"]
            rand_coefs = rand(2)
            sort!(rand_coefs)
            cond1 = controls.ValueCondition(source_obj, "level", ">", tank["max_level"] - interval*rand_coefs[2])
            cond2 = controls.ValueCondition(source_obj, "level", "<", tank["min_level"] + interval*rand_coefs[1])

            pump = wn_dict["pumps"][pump_name]
            act1 = controls.ControlAction(target_obj, "status", 0)
            act2 = controls.ControlAction(target_obj, "status", 1)

            control1 = controls.Control(cond1, act1)
            control2 = controls.Control(cond2, act2)

            wn[:add_control]("$name-1", control1)
            wn[:add_control]("$name-2", control2)
        end
    end
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, 2, 2, tight_coef, Q_lb)
end

function OnAfterTn(wn_dict::Dict{Any,Any}, wn::PyCall.PyObject, Tn::Int64, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, Hmax_dict::Dict{String, Float64}, Hmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)
    Tn = convert(Float64, Tn)
    controls_dict = wn_dict["controls"]
    for (name,pump) in wn_dict["pumps"]
        pump_obj = wn[:get_link](name)
        act = controls.ControlAction(pump_obj, "status", 1)
        cond = controls.SimTimeCondition(wn, "=", Tn*wn_dict["options"]["time"]["report_timestep"])
        control = controls.Control(cond, act)
        wn[:add_control]("Turn on $name", control)
    end
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, 2, 2, tight_coef, Q_lb)
end

function OffAfterTn(wn_dict::Dict{Any,Any}, wn::PyCall.PyObject, Tn::Int64, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, Hmax_dict::Dict{String, Float64}, Hmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)
    Tn = convert(Float64, Tn)
    controls_dict = wn_dict["controls"]
    for (name,pump) in wn_dict["pumps"]
        pump_obj = wn[:get_link](name)
        act1 = controls.ControlAction(pump_obj, "status", 1)
        cond1 = controls.SimTimeCondition(wn, "=", 0)
        control1 = controls.Control(cond1, act1)
        wn[:add_control]("Turn on $name", control1)

        act2 = controls.ControlAction(pump_obj, "status", 0)
        cond2 = controls.SimTimeCondition(wn, "=", Tn*wn_dict["options"]["time"]["report_timestep"])
        control2 = controls.Control(cond2, act2)
        wn[:add_control]("Turn off $name", control2)
    end
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, 2, 2, tight_coef, Q_lb)
end
function RandomTime(wn_dict::Dict{Any,Any}, wn::PyCall.PyObject, time_steps::Int64, time_periods::Float64, Qmax_dict::Dict{String, Float64}, Qmin_dict::Dict{String,Float64}, Hmax_dict::Dict{String, Float64}, Hmin_dict::Dict{String,Float64}, tight_coef::Float64, Q_lb::Float64)
    controls_dict = wn_dict["controls"]
    for (name,pump) in wn_dict["pumps"]
        pump_obj = wn[:get_link](name)
        rand_status = rand(0:1, time_steps)
        for i=1:time_steps
            pump_status = rand_status[i]
            pump_time = time_periods*i
            act1 = controls.ControlAction(pump_obj, "status", pump_status)
            cond1 = controls.SimTimeCondition(wn, "=", pump_time)
            control1 = controls.Control(cond1, act1)
            wn[:add_control]("Turn on $name $i", control1)
        end
    end
    UpdateExtrema(wn, wn_dict, Qmax_dict, Qmin_dict, Hmax_dict, Hmin_dict, 2, 2, tight_coef, Q_lb)
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
