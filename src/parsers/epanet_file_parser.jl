
## legacy, not sure if needed now, JJS 12/5/19
# function TimeSeriesCheckDemand(loads::Array{T}) where {T<:WaterDemand}
#     t = length(loads[1].demand)
#     for l in loads
#         if t == length(l.demand)
#             continue
#         else
#             error("Inconsistent load scaling factor time series length")
#         end
#     end
#     return t
# end

"""
Create a System from an epanet ".inp" file.
"""
function parse_inp_file(inp_file::String)
    data = make_dict(inp_file) # data is a dictionary
    junctions, arcs, res, demands, tanks, patterns, curves, pipes, pumps, valves =
        dict_to_struct(data)

    # need to work on the constructor(s) for the Water System, JJS 200103
    return System()
end
