#time_steps = 1:24

BASE_DIR = abspath(joinpath(dirname(Base.find_package("WaterSystems")), ".."))
TEST_DIR = joinpath(BASE_DIR, "test")
DATA_DIR = joinpath(TEST_DIR, "data")

epanet_test_file = "VanZyl.inp"
epanet_test_path = joinpath(DATA_DIR, epanet_test_file)
