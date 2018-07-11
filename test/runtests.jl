using WaterSystems
using Base.Test
# write your own tests here
tic()
println("Read data from WNTR networks 1, 2, and 3.")
@time @test include("readnetworkdata.jl")
println("Test all constructors.")
@time @test include("constructors.jl")
println("Test epa net parser.")
@time @test include("epa_net_parser.jl")
@test true
toc()
