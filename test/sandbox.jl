using WaterSystems
cd(string(homedir(),"/.julia/v0.6/WaterSystems/src/WaterModels/test/data"))

test = WaterSystems.parse_epanet("hanoi.inp",0)