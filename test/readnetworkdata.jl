# if is_linux() || is_apple()
#     folder = readdir("test/data/epanetfiles")
#     files = [joinpath("data/epanetfiles", folder[i]) for i =1:length(folder)]
#     include("data/test_system.jl")
# end
#
# if is_windows()
#     folder = readdir("test\\data\\epanetfiles")
#     files = [joinpath("test\\data\\epanetfiles", folder[i]) for i =1:length(folder)]
#     invlude("data\\test_system.jl")
# end

true
