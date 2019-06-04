include("../src/WaterSystems.jl")
using Test
using TimeSeries
using DataFrames

# write your own tests here

println("Read data from WNTR networks 1, 2, and 3.")
@time @test include("readnetworkdata.jl")
println("Test all constructors.")
@time @test include("constructors.jl")
println("Test Network Struct.")
@time @test include("network.jl")
println("Test WaterSystem struct.")
@time @test include("watersystem.jl")
println("Test wntr parser.")
@time @test include("test_dict_parser.jl")
@test true

