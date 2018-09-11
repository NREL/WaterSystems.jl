function FlowDirections(wn_dict::Dict{Any,Any}, sim )
    SameDirPipes = Dict{String, Any}()
    OppDirPipes = Dict{String, Any}()

    if sim == 1
        for (i, (key, pipe)) in enumerate(wn_dict["pipes"])
            
