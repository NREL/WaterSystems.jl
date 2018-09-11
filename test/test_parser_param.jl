folder = readdir("test/data/epanetfiles")
files = [joinpath("test/data/epanetfiles", folder[i]) for i =1:length(folder)]

for f in files
    try
        @time wntr_dict = WaterSystems.wntr_dict(f)
        println("Successfully parsed $f to WNTR Dictionary.")
        @time data = WaterSystems.make_dict(f)
        println("Successfully parsed $f to Water System Dictionary.")
        @time junctions, tanks, reservoirs, pipes, valves, pumps, demands, simulations = WaterSystems.dict_to_struct(data, 3, 0.001, 1, .3, .2, .1)
        println("Successfully parsed $f to Water System Devices.")
        links = vcat(pipes,valves,pumps)
        nodes = vcat(junctions, tanks, reservoirs)
        net = WaterSystems.Network(links, nodes)
        println("Successfully created Network struct from")
        @time WaterSystems.WaterSystem(junctions, tanks, reservoirs, pipes, valves, pumps, demands)
        println("Successfully parsed $f to WaterSystems struct")
    catch
        warn("Error while parsing $f")
        catch_stacktrace()
    end
end
true
