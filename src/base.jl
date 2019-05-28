## Time Series Length ##

include("Parsers/dict_to_struct.jl")
include("Parsers/wntr_dict.jl")
include("Parsers/wntr_dict_parser.jl")
include("Utils/build_incidence.jl")
function TimeSeriesCheckDemand(loads::Array{T}) where {T<:WaterDemand}
    t = length(loads[1].demand)
    for l in loads
        if t == length(l.demand)
            continue
        else
            error("Inconsistent load scaling factor time series length")
        end
    end
    return t
end
struct Network
    incidence::Incidence
    null::Array{Float64}
end

function Network(nodes::Vector{N}, links::Vector{T}) where {T<:Link, N<:Junction} #didn't work as Vector{T<:Array{<:Link}}
    A = Incidence(nodes, links)
    null_A = build_incidence_null(A.data)
    return Network(A, null_A)

end
#TODO: Do we need all the simulation information? ASM 
""" _System
    An internal struct that collections system components. """
struct _System <: WaterSystemType
    nodes::Vector{Junction}
    links::Vector{<:Link}
    storage::Union{Nothing, Vector{<:Storage}}
    demand:: Vector{WaterDemand}
    simulation:: Simulation
    network:: Network
end


function _System(nodes, links, storage, demand, simulation, network)
    sys = new(nodes, links, storage, demand, simulation, network)
    return sys
end

function _System(inp_file::String)
    data = make_dict(inp_file)
    junctions, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data)
    links = vcat(pipes,valves,pumps)
    nodes =  vcat(junctions, [tank.node for tank in tanks])
    nodes = vcat(nodes, [res.node for res in reservoirs])
    storage = vcat(tanks, reservoirs)
    net = Network(nodes,links)
    return _System(nodes, links, storage, demands, simulations, net)
end

# function WaterSystem(inp_file::String, n::Int64, Q_lb::Float64, logspace_ratio::Float64, dH_critical::Float64, dense_coef::Float64, tight_coef::Float64)
#     data = make_dict(inp_file)
#     junctions, tanks, reservoirs, pipes, valves, pumps, demands, simulations = dict_to_struct(data, n, Q_lb, logspace_ratio, dH_critical, dense_coef, tight_coef)
#     links = vcat(pipes, valves, pumps)
#     nodes =  vcat(junctions, [tank.node for tank in tanks])
#     nodes = vcat(nodes, [res.node for res in reservoirs])
#     net = Network(nodes,links)
#     return WaterSystem(junctions, tanks, reservoirs, pipes, valves, pumps, demands), simulations, net
# end

const Components = Dict{DataType,Vector{<:Component}}
""" System 
A watersystem defiend by fields for simulation and components """
struct System <: WaterSystemType
    components::Components
    simulation:: Simulation
    network:: Network
    internal:: WaterSystemInternal
end  

function System(components, simulation, network)
    return System(components, simulation,network, WaterSystemInternal())
end 

function System(sys::_System)
    components = Dict{DataType, Vector{<:Component}}()
    concrete_sys = System(components, sys.simulation, sys.network)

    for field in (:nodes, :links, :storage, :demand)
        objs = getfield(sys, field)
        for obj in objs 
            add_component!(concrete_sys, obj)
        end
    end 

    for (key, value) in concrete_sys.components
        @debug "components: $(string(key)): count = $(string(length(value)))"
    end 
    return concrete_sys
end 

function get_components(::Type{T}, sys::System)::Vector{T} where {T<:Component}
    if !isconcretetype(T)
        error("$T must be a concrete type")
    end 
    return sys.data[T]
end 
""" Adds a component to the system."""
function add_component!(sys::System, component::T) where T<: Component
    if !isconcretetype(T)
        error("add component only accepts concrete types.")
    end 
    if !haskey(sys.components, T)
        sys.components[T] = Vector{T}()
    end 
    push!(sys.components[T], component)
    return nothing 
end 
"""System Constructor. Funnel point for all other constructors."""
function System(inp_file::String)
    sys= _System(inp_file)
    return System(sys)
end 

function iterate_components(sys::System)
    Channel() do channel
        for component in get_components(Component,sys)
            put!(channel, component)
        end
    end 
end 

function get_components( ::Type{T}, sys::System,)::FlattenedVectorsIterator{T} where {T<: Component}
    if isconcretetype(T)
        components = get(sys.components, T, nothing)
        if isnothing(components)
            iter = FlattenedVectorsIterator(Vector{Vector{T}})([])
        else 
            iter = FlattenedVectorsIterator(Vector{Vector{T}}([sys.components[x] for x in types]))
        end 
        @assert eltype(iter) == T
        return iter 
    end 
end 






