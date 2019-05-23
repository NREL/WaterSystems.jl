function build_incidence(nodes::Array{Junction}, links::Array{T}) where T<:Link

    linkcount = length(links)
    nodecount = length(nodes)
    link_axis = [link.name for link in links]
    num_junc = Dict{Int,Int}() #maps the junction number to row in incidence matrix

    for (ix, junction) in enumerate(nodes)
        num_junc[junction.number] = ix
    end 

    A = zeros(Int64,nodecount,linkcount)

   #build incidence matrix
   #incidence_matrix = A
    for (ix,b) in enumerate(links)
        A[num_junc[b.connectionpoints.from.number], ix] =  1;

        A[num_junc[b.connectionpoints.to.number], ix] = -1;

    end
    return  A
end
function build_incidence_null(A::AbstractArray{Int64})
    null_A = nullspace(A)
    return null_A
end
# function WaterSystem(links::Array{<:Link})
# function WaterSystem(nodes, junctions, tanks, reservoirs, links, pipes, valves, pumps, demands, network, simulation)
#
#         new(nodes,
#             junctions,
#             tanks,
#             reservoirs,
#             links,
#             pipes,
#             valves,
#             pumps,
#             demands,
#             network,
#             simulation)
# end

# maps name to position in matrix 
function _make_ax_ref(ax::Vector)
    ref = Dict{eltype(ax), Int}()
    for (ix, el) in enumerate(ax)
        if haskey(ref, el)
            @error("Repeated index element $el. Index sets must have unique elements.")
        end
        ref[el] = ix 
    end
    return ref
end
struct Incidence
    data:: Array{Int64,2}
    axes::Tuple{Array{String,1},Array{String,1}}
    lookup::Tuple{Dict{String,Int64},Dict{String,Int64}}
end

function Incidence(nodes::Array{Junction},links::Array{<:Link})
    link_axis = [link.name for link in links]
    node_axis = [junc.name for junc in nodes]
    A = build_incidence(nodes, links)
    axes = (link_axis, node_axis)
    look_up = (_make_ax_ref(link_axis), _make_ax_ref(node_axis))
    return Incidence(A, axes, look_up)
end

return Incidence, build_incidence, build_incidence_null