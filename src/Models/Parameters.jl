struct Parameters
    aPipe_over::Dict{String,Array{Float64,1}}
    bPipe_over::Dict{String,Array{Float64,1}}
    aPipe_under::Dict{String,Array{Float64,1}}
    bPipe_under::Dict{String,Array{Float64,1}}
    aPumpPower_flow::Dict{String,Float64}
    bPumpPower_flow::Dict{String,Float64}
    aPumpPower_head::Dict{String,Float64}
    bPumpPower_head::Dict{String,Float64}
    aValve_over::Dict{String,Array{Float64,1}}
    bValve_over::Dict{String,Array{Float64,1}}
    aValve_under::Dict{String,Array{Float64,1}}
    bValve_under::Dict{String,Array{Float64,1}}
    PositiveFlowLinks::Array{String}
    NegativeFlowLinks::Array{String}
    ReversibleFlowLinks::Array{String}
end

Parameters(;
            aPipe_over = Dict{String,Array{Float64,1}}(),
            bPipe_over = Dict{String,Array{Float64,1}}(),
            aPipe_under = Dict{String,Array{Float64,1}}(),
            bPipe_under = Dict{String,Array{Float64,1}}(),
            aPumpPower_flow = Dict{String,Float64}(),
            bPumpPower_flow = Dict{String,Float64}(),
            aPumpPower_head = Dict{String,Float64}(),
            bPumpPower_head = Dict{String,Float64}(),
            aValve_over = Dict{String,Array{Float64,1}}(),
            bValve_over = Dict{String,Array{Float64,1}}(),
            aValve_under = Dict{String,Array{Float64,1}}(),
            bValve_under = Dict{String,Array{Float64,1}}(),
            PositiveFlowLinks = Array{String}(),
            NegativeFlowLinks = Array{String}(),
            ReversibleFlowLinks = Array{String}()
            ) = Parameters(aPipe_over, bPipe_over, aPipe_under, bPipe_under, aPumpPower_flow,
                bPumpPower_flow, aPumpPower_head, bPumpPower_head,aValve_over, bValve_over,
                aValve_under, bValve_under, PositiveFlowLinks, NegativeFlowLinks, ReversibleFlowLinks)
