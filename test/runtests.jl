
using Test
using TimeSeries
using DataFrames
using WaterSystems
import WaterSystems

BASE_DIR = abspath(joinpath(dirname(Base.find_package("WaterSystems")), ".."))
TEST_DIR = joinpath(BASE_DIR, "test")
DATA_DIR = joinpath(TEST_DIR, "data")

# write your own tests here

println("Read data from WNTR networks 1, 2, and 3.")
#@time @test include(joinpath(TEST_DIR, "readnetworkdata.jl"))
println("Test all constructors.")
@time @test include(joinpath(TEST_DIR, "constructors.jl"))
println("Test Network Struct.")
@time @test include(joinpath(TEST_DIR, "network.jl"))
println("Test WaterSystem struct.")
@time @test include(joinpath(TEST_DIR, "watersystem.jl"))
println("Test wntr parser.")
@time @test include(joinpath(TEST_DIR, "test_dict_parser.jl"))
@test true

