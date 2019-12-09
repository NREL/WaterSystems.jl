
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
    nodes, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data)
    links = vcat(pipes,valves,pumps)
    link_classes = LinkClasses(links, pipes, pumps, valves)
    junctions_index = length(nodes) - length(tanks) - length(reservoirs) # junctions that aren't tanks/reservoirs
    junctions = nodes[1:junctions_index]
    node_classes = NodeClasses(nodes, junctions, tanks, reservoirs)
    net = Network(nodes,links)
    return WaterSystem(node_classes, link_classes, demands), simulations, net
end

