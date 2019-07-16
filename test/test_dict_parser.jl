using WaterSystems
folder = readdir(joinpath(DATA_DIR, "epanetfiles"))
files = [joinpath(DATA_DIR, "epanetfiles", folder[i]) for i =1:length(folder)]
for f in files
    try
        @time data = wntr_dict(f)
        println("Successfully parsed $f to Wntr Dict")
        @time data = make_dict(f)
        println("Successfully parsed $f to WaterSystems Dict")
        @time nodes, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data)
        println("Successfully parsed $f to WaterSystems devices.")
        @time system, simulations, network = WaterSystem(f)
        println("Successfully parsed $f to WaterSystem struct.")
    catch
        @warn("Error while parsing $f")
    end
end
true
