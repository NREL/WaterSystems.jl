if is_linux() || is_apple()
    folder = readdir("test/data/epanetfiles")
    files = [joinpath("data/epanetfiles", folder[i]) for i =1:length(folder)]
end

if is_windows()
    folder = readdir("test\\data\\epanetfiles")
    files = [joinpath("test\\data\\epanetfiles", folder[i]) for i =1:length(folder)]
end

true
