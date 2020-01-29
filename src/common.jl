# currently used for pipe flow limits -- may remove?
const small = 1e-6
const large = 1e6


const gravity = 9.81 # m/s^2
const density = 1000.0 # kg/m^3



const WATER_SYSTEM_STRUCT_DESCRIPTOR_FILE = joinpath(
    dirname(pathof(WaterSystems)),
    "descriptors",
    "water_system_structs.json",
)



"""
Convert an array of tuples to a 2D array. Presumes that the tuples are all the same
length and type (there is currently no check).
"""
function array_from_tuples(T)
    m = length(T)
    n = length(T[1])
    typename = typeof(T[1][1])
    A = Array{typename}(undef, (m,n))
    for i in 1:m
        for j in 1:n
            A[i,j] = T[i][j]
        end
    end
    return A
end
