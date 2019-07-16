struct Simulation <: WaterSystemDevice
    duration::Int64 #hours
    timestep::Float64 #hours
    num_timesteps::Int64 #hours
    start_day::DateTime
    end_day::DateTime
end

Simulation(;   duration = 0,
                timestep = 0.0,
                num_timesteps = 0,
                start_day = "0:0:0",
                end_day = "0:0:0"
                ) = Simulation(duration, timestep, num_timesteps, start_day, end_day)
