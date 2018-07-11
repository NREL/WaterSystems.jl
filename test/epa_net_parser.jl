folder = readdir("test/data/epanetfiles")
files = [joinpath("test/data/epanetfiles", folder[i]) for i =1:length(folder)]
for f in files
    try
        @time nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, simulation = WaterSystems.wn_to_struct(f)
        println("Successfully parsed $f to PowerSystems devices.")
        @time WaterSystems.Network(links, nodes)
        println("Successfully created Network struct from")
        @time WaterSystems.WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, simulation)
        println("Successfully parsed $f to PowerSystems struct")
    catch
        warn("Error while parsing $f")
        catch_stacktrace()
    end
end
true
