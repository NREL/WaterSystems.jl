include(joinpath(DATA_DIR, "test_system.jl"))

system = WaterSystem(node_classes, link_classes, demands)

true
