DayAhead  = collect(DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime("1/1/2024  23:00:00", "d/m/y  H:M:S"))

junctions = [   Junction(number=2,name="J2",elevation=20, head = 20.0, demand = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), demandforcast = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), minimum_pressure=1, coordinates = @NT(lat = 0.0,lon = 0.0)),
                Junction(number=3,name="J3",elevation=18, head = 20.0, demand = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), demandforcast = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), minimum_pressure=1, coordinates = @NT(lat = 0.0,lon = 0.0)),
                Junction(number=4,name="J4",elevation=10, head = 20.0, demand = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), demandforcast = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), minimum_pressure=1, coordinates = @NT(lat = 0.0,lon = 0.0)),
                Junction(number=1,name="T1",elevation=320,head = 20.0, demand = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), demandforcast = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), minimum_pressure=1, coordinates = @NT(lat = 0.0,lon = 0.0)),
                Junction(number=5,name="R1",elevation=0, head = 50.0, demand = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), demandforcast = TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), minimum_pressure=1, coordinates = @NT(lat = 0.0,lon = 0.0))
            ];

tanks = [ RoundTank("T1", junctions[4], @NT(min = 0.0, max = 2500.0), 10.0, 500.0, pi*25, 200/(10*pi), @NT(min=0.0, max=1000/(10*pi)))];

reservoirs = [Reservoir("R1",junctions[1],0)];
nodes = junctions
vcat(nodes, Junction(6, "T1", 0, 20.0,TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))),TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))), 1, @NT(lat = 0.0,lon = 0.0)),Junction(7,"R1", 0, 0.0, TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))),TimeSeries.TimeArray(DayAhead, rand(length(DayAhead))),1,@NT(lat = 0.0,lon = 0.0)))
pipes = [   RegularPipe(1,"P1", @NT(from=junctions[4],to=junctions[3]), 0.6, 100.0, 200.0, 2.0, 10.0, 1),
            RegularPipe(2,"P2",@NT(from=junctions[2],to=junctions[2]),0.6,150.0,200.0,5.0,30.0,1)
        ];

valves = [  PressureReducingValve(1, "V1", @NT(from=junctions[1],to=junctions[2]), "open", 1.0, 1.0)
        ];

elec_price = rand(24)
pumps = [ConstSpeedPump(1, "PMP1", @NT(from=junctions[5],to=junctions[4]),true,
                        [(0.0,350.0),(400.0,328.0),(800.0,295.0),(1400.0,260.0),(1600.0,245.0),(1800.0,225.0),(2200.0,153.0)],
                        0.85,
                        TimeSeries.TimeArray(DayAhead, elec_price), 1.2, 22.2)]

demands = [ WaterDemand("D1",junctions[3],true,10,TimeSeries.TimeArray(DayAhead, rand(24)))];

simulations = Simulation(24, 1.0, 24, DateTime(2013,7,10), DateTime(2013,7,11))
links = vcat(pipes,valves, pumps)
network = Network(links,nodes)
system = WaterSystem(nodes,junctions,tanks, reservoirs, links, pipes, valves, pumps, demands, network, simulations);
