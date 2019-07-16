folder = readdir(joinpath(DATA_DIR, "epanetfiles"))
files = [joinpath(DATA_DIR, "epanetfiles", folder[i]) for i =1:length(folder)]
include(joinpath(DATA_DIR, "test_system.jl"))

for f in files
    @show f
    wd = wntr_dict(f)
    ws = dict_to_struct(wd)
end

true