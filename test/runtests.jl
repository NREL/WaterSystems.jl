using WaterSystems
using Base.Test

# write your own tests here

@test true

println("Read Data in *.jl files")
@time @test include("readnetworkdata.jl")