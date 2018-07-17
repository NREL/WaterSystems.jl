folder = readdir("test/data/epanetfiles")
files = [joinpath("test/data/epanetfiles", folder[i]) for i =1:length(folder)]
for f in files
    try
        @time data = wntr_dict(f)
        println("Successfully parsed $f to Wntr Dict")
        @time data = make_dict(f)
        println("Successfully parsed $f to WaterSystems Dict")
        @time nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, simulation = WaterSystems.dict_to_struct(data)
        println("Successfully parsed $f to WaterSystems devices.")
        @time WaterSystems.Network(links, nodes)
        println("Successfully created Network struct from")
        @time WaterSystems.WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, simulation)
        println("Successfully parsed $f to WaterSystems struct")
    catch
        warn("Error while parsing $f")
        catch_stacktrace()
    end
end
true
