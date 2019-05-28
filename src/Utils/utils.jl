import InteractiveUtils: subtypes 

""" Returns an array of all concrete subtypes of T."""

function get_all_concrete_subtypes(::Type{T}) where T
    return _get_all_concrete_subtypes(T)
end

function _get_all_concrete_subtypes(::Type{T}, sub_types = []) where T
    for sub_type in subtypes(T)
        push!(sub_types, sub_type)
        if isabstractype(sub_type)
            _get_all_concrete_subtypes(sub_type, sub_types)
        end
    end 
    return sub_types
end

""" Returns an array of concrete types that are direct subtypes of T."""

function get_concrete_subtypes(::Type{T}) where T
    return [x for x in subtypes(T) if isconcretetype(x)]
end 

""" Returns an array of abstract types taht are direct subtypes of T."""

function get_abstract_subtypes(::Type{T}) where T
    return [x for x in subtypes(T) if isabstracttype(x)]
end 

""" Returns an array of all super types of T."""
function supertypes(::Type{T}, types = []) where T
    super = supertype(T)
    push!(types, super)
    if super == Any
        return types 
    end 
    supertypes(super, types)
end 
""" Converts a DataType to a Symbok, stipping off the module name(s). """

function type_to_symbol(data_type::DataType)
    text = string(data_type)
    index = findlast(".", text)
    if !isnothing(index)
        text = text[index.start + 1:end]
    end 
    return Symbol(text)
end 

function _get_components_by_type(::Type{T}, data::Dict{DataType, Vector{<:Component}}, components::Dict{DataType, Any}=Dict{DataType,Any}(),) where {T<:Component}
    abstract_types = get_abstract_subtypes(T)
    if length(abstract_types) > 0
        for abstract_type in abstract_types 
            components[abstract_type] = Dict{DataType, Any}()
            _get_components_by_type(abstract_type, data, componenets[abstract_type])
        end
    end
    for concrete_type in get_concrete_subtypes(T)
        components[concrete_type] = data[concrete_type]
    end 
    return components
end 