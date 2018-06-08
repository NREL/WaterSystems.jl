#using WaterSystems
using TimeSeries
using Dates

DayAhead  = collect(DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime("1/1/2024  23:00:00", "d/m/y  H:M:S"))


junctions = [   Junction(number=2,name="J2",elevation=20,minimum_pressure=1),
                Junction(number=3,name="J3",elevation=18,minimum_pressure=1),
                Junction(number=4,name="J4",elevation=10,minimum_pressure=1),
                Junction(number=1,name="T1",elevation=320),
                Junction(number=5,name="R1",elevation=0)
            ];

tanks = [RoundTank(name="T1",node=junctions[4],diameter=10,levellimits=(min=0,max=1000/(10*pi)),level=200/(10*pi))];

reservoirs = [Reservoir("R1",0)];

pipes = [   RegularPipe("P1", (from=junctions[4],to=junctions[3]), 0.6, 100.0, 200.0, [(0.0,0.0),(4.0,16.0),(8.0,64.0),(20.0,400.0)], nothing),
RegularPipe("P2",(from=junctions[2],to=junctions[2]),0.6,150,200,[(0,0),(4,16),(8,64),(20,400)],nothing)
        ];

valves = [  PressureReducingValve("V1",(from=junctions[1],to=junctions[2]),true,nothing,nothing)
        ];

elec_price = rand(24)
pumps = [   ConstSpeedPump("PMP1",(from=junctions[5],to=junctions[4]),true,
                        [(0.0,350.0),(400.0,328.0),(800.0,295.0),(1400.0,260.0),(1600.0,245.0),(1800.0,225.0),(2200.0,153.0)],
                        [(0.0,350.0),(400.0,328.0),(800.0,295.0),(1400.0,260.0),(1600.0,245.0),(1800.0,225.0),(2200.0,153.0)],
                        0.85,
                        TimeSeries.TimeArray(DayAhead, elec_price)
                        )
        ];

demands = [     WaterDemand("D1",junctions[3],true,10,TimeSeries.TimeArray(DayAhead, rand(24)))];

devon_sys = WaterSystem(junctions,vcat(pipes,valves,pumps),vcat(tanks,reservoirs),demands);