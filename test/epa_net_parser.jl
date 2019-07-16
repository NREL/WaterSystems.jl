folder = readdir(joinpath(DATA_DIR, "epanetfiles"))
files = [joinpath(DATA_DIR, "epanetfiles", folder[i]) for i =1:length(folder)]
for f in files
    try
        @time nodes, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data)
        println("Successfully parsed $f to WaterSystems devices.")
        @time WaterSystems.WaterSystem(f)
        println("Successfully parsed $f to WaterSystems struct")
    catch
        warn("Error while parsing $f")
        catch_stacktrace()
    end
end
true
