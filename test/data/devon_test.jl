using WaterSystems

junctions = [   Junction(name="J2",elevation=20,minimum_pressure=1),
                Junction(name="J3",elevation=18,minimum_pressure=1),
                Junction(name="J4",elevation=10,minimum_pressure=1),
                Junction(name="T1",elevation=320),
                Junction(name="R1",elevation=0)
            ];

tanks = [Roundtank(name="T1",node=junctions[4],diameter=10,levellimits=(min=0,max=1000/(10*pi)),level=200/(10*pi))];

reservoirs = [Reservoir("R1",0)];

pipes = [   Regularpipe("P1", (from=junctions[4],to=junctions[3]), 0.6, 100.0, 200.0, [(0.0,0.0),(4.0,16.0),(8.0,64.0),(20.0,400.0)], nothing),
            Regularpipe("P2",(from=junctions[2],to=junctions[2]),0.6,150,200,[(0,0),(4,16),(8,64),(20,400)],nothing)
        ];