include("transport_elements.jl")

# To Do
# 1. Consider a dynamic rate problem, add time series in the rate calculations.

struct Network{T<:Array{<:Link}}
    links::T
    incidence::Array{Int}
    null::Array{Float64}
end

function Network(links::Vector{B}, nodes::Vector{Junction}) where {B<:Link}
    nodecount = length(nodes)
    A = build_incidence(nodecount, links, nodes)
    null_A = build_incidence_null(A)
    return Network(links, A, null_A)

end

function build_incidence(nodecount::Int64, links::Array{B}, nodes::Array{Junction}) where {B<:Link}

    linkcount = length(links)

    A = spzeros(Float64,nodecount,linkcount);

   #build incidence matrix
   #incidence_matrix = A
    for (ix,b) in enumerate(links)

        A[b.connectionpoints.from.number, ix] =  1;

        A[b.connectionpoints.to.number, ix] = -1;

    end
    return  A
end
function build_incidence_null(A)
    null_A = nullspace(full(A))
    return null_A
end
