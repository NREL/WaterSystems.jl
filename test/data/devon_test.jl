using WaterSystems

junctions = [   Junction("J2",elevation=20,minimum_pressure=1),
                Junction("J3",elevation=18,minimum_pressure=1),
                Junction("J4",elevation=10,minimum_pressure=1)
                Junction("T1",elevation=320),
                Junction("R1",elevation=0)
            ];

tanks = [Roundtank("T1",J1,diameter=10,levellimits=(min=0,max=1000/(10*pi)),level=200/(10*pi))];

reservoirs = [Reservoir("R1",0)];

pipes = [   Regularpipe("P1",(from=junctions[5],to=junctions[1]),0.6,100,200,headloss=((0,0),(4,16),(8,64),(20,400))),
            Regularpipe("P2",(from=junctions[5],to=junctions[2]),0.6,100,200,headloss=((0,0),(4,16),(8,64),(20,400))),

        ]