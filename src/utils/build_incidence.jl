function build_incidence(nodes::Array{Junction}, links::Array{T}) where T<:Link

    linkcount = length(links)
    nodecount = length(nodes)
    num_junc = Dict{String,Int}() #maps the junction number to row in incidence matrix
    link_axis = Array{String,1}()
    for (ix, junction) in enumerate(nodes)
        num_junc[junction.name] = ix
    end 

    A = zeros(Int64,nodecount,linkcount)

   #build incidence matrix
   #incidence_matrix = A
    for (ix,b) in enumerate(links)
        if typeof(b) <: ControlPipe
            A[num_junc[b.pipe.connectionpoints.from.name], ix] =  1;

            A[num_junc[b.pipe.connectionpoints.to.name], ix] = -1;
            push!(link_axis, b.pipe.name)
        else 
            A[num_junc[b.connectionpoints.from.name], ix] =  1;

            A[num_junc[b.connectionpoints.to.name], ix] = -1;
            push!(link_axis, b.name)
        end 

    end
    return  A, link_axis
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
    node_axis = [junc.name for junc in nodes]
    A, link_axis = build_incidence(nodes, links)
    axes = (link_axis, node_axis)
    look_up = (_make_ax_ref(link_axis), _make_ax_ref(node_axis))
    return Incidence(A, axes, look_up)
end 

return Incidence, build_incidence, build_incidence_null