function FlowDirection(wn_dict::Dict{Any,Any}, Qmin::Dict{String, Float64}, Qmax::Dict{String,Float64})
    PositiveFlowLinks = Array{String,1}(0)
    NegativeFlowLinks = Array{String,1}(0)
    ReversibleFlowLinks = Array{String,1}(0)

    for link in wn_dict["links"]
        name = link["name"]
        if Qmin[name] > 1e-9
            push!(PositiveFlowLinks, name)
        elseif Qmax[name] <-1e-9
            push!(NegativeFlowLinks, name)
        else
            push!(ReversibleFlowLinks, name)
        end
    end
    return PositiveFlowLinks, NegativeFlowLinks, ReversibleFlowLinks
end
