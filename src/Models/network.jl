include("transport_elements.jl")

export Network

# To Do
# 1. Consider a dynamic rate problem, add time series in the rate calculations.

struct Network
    links::Array{Link}
    incidence::Array{Int}
end

function Network(links::Array{B}, nodes::Array{Junction}) where {B<:Link}
    nodecount = length(nodes)
    A = WaterSystems.build_incidence(nodecount, links, nodes)

    return Network(links, A) 
    
end

function build_incidence(nodecount, links::Array{B}, nodes::Array{Node}) where {B<:Link}

    linkcount = length(links)

    for n in nodes
        if n.number < -1
            error("nodes must be numbered consecutively in the bus/node matrix")
        end
    end

    A = spzeros(Float64,nodecount,linkcount);

   #build incidence matrix
   #incidence_matrix = A
    for (ix,b) in enumerate(links)

        A[b.connectionpoints.from.number, ix] =  1;

        A[b.connectionpoints.to.number, ix] = -1;

    end
    return  A

end
