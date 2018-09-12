base_dir = string(dirname(dirname(@__FILE__)))
println(joinpath(base_dir,"test/data/epanetfiles"))

folder = readdir(joinpath(base_dir,"test/data/epanetfiles"))
files = [joinpath("test/data/epanetfiles", folder[i]) for i =1:length(folder)]

println(joinpath(base_dir,"test/data/test_system.jl"))
include(joinpath(base_dir,"test/data/test_system.jl"))

true
