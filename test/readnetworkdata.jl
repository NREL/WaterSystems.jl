if Sys.islinux() || Sys.isapple()
    folder = readdir("test/data/epanetfiles")
    files = [joinpath("data/epanetfiles", folder[i]) for i =1:length(folder)]
    include("data/test_system.jl")
end

if Sys.iswindows()
    folder = readdir("test\\data\\epanetfiles")
    files = [joinpath("test\\data\\epanetfiles", folder[i]) for i =1:length(folder)]
    include("data\\test_system.jl")
end

true
