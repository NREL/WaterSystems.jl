### more documentation needed; see base.jl in PowerSystems.jl, JJS 11/19/19
"""
System

A water system (municipal network).
"""
struct System <: WaterSystemType
    data::IS.SystemData
    runchecks::Bool
    internal::InfrastructureSystemsInternal

    function System(data, internal; kwargs...)
        runchecks = get(kwargs, :runchecks, true)
        sys = new(data, runchecks, internal)
        return sys
    end
end

"""Construct an empty System. Useful for building a System while parsing raw data."""
function System(; kwargs...)
    return System(_create_system_data_from_kwargs(; kwargs...))
end

"""Construct a `System` from `InfrastructureSystems.SystemData`"""
function System(data; kwargs...)
    internal = get(kwargs, :internal, IS.InfrastructureSystemsInternal())
    return System(data, internal; kwargs...)
end

"""System constructor when components are constructed externally."""
function System(
    junctions::Vector{Junction},
    arcs::Vector{Arc},
    reservoirs::Vector{Reservoir},
    demands::Vector{<:WaterDemand}, # practically, there will always be a demand to have flow
    tanks::Union{Nothing, Vector{<:Tank}},
    # curves? -- included with pump object
    # patterns? -- to be included as a forecasts with pump and demand objects? TBD!
    pipes::Vector{<:Pipe}, # theortically, a network _could_ exist without pipes, but not
                           # practically
    pumps::Union{Nothing, Vector{Pump}},
    valves::Union{Nothing, Vector{Valve}}
    ;
    kwargs...,
)

    data = _create_system_data_from_kwargs(; kwargs...)
    sys = System(data; kwargs...)

    arrays = [junctions, arcs, reservoirs, demands, pipes]
    if !isnothing(tanks) && !isempty(tanks)
        push!(arrays, tanks)
    end
    if !isnothing(pumps) && !isempty(pumps)
        push!(arrays, pumps)
    end
    if !isnothing(valves) && !isempty(valves)
        push!(arrays, valves)
    end

    error_detected = false
    for component in Iterators.flatten(arrays)
        try
            add_component!(sys, component)
        catch e
            if isa(e, IS.InvalidRange)
                error_detected = true
            else
                rethrow()
            end
        end
    end

    runchecks = get(kwargs, :runchecks, true)

    if error_detected
        throw(IS.InvalidRange("Invalid value(s) detected"))
    end

    if runchecks
        check!(sys)
    end

    return sys
end


"""System constructor without nothing-able arguments."""
function System(
    junctions::Vector{Junction},
    reservoirs::Vector{Reservoir},
    pipes::Vector{<:Pipe},    
    ;
    kwargs...,
)
    return System(
        junctions,
        reservoirs,
        pipes,
        nothing,
        nothing,
        nothing,
        ;
        kwargs...,
    )
end

"""System constructor with keyword arguments."""
function System(
    ;
    junctions,
    reservoirs,
    pipes,
    pumps,
    demands,
    tanks,
    kwargs...,
)
    return System(
        junctions,
        reservoirs,
        pipes,
        pumps,
        demands,
        tanks,
        ;
        kwargs...,
    )
end


### below was copied from PowerSystems.jl and has not yet been checked or modified, JJS,
### 12/5/19


"""
    to_json(sys::System, filename::AbstractString)

Serializes a system to a JSON string.
"""
function to_json(sys::System, filename::AbstractString)
    IS.prepare_for_serialization!(sys.data, filename)
    return IS.to_json(sys, filename)
end

"""
    to_json(io::IO, sys::System)

Serializes a system an IO stream in JSON.
"""
function to_json(io::IO, sys::System)
    return IS.to_json(io, sys)
end

"""Constructs a System from a JSON file."""
function System(filename::String)
    sys = IS.from_json(System, filename)
    check!(sys)
    return sys
end

"""
    add_component!(sys::System, component::T; kwargs...) where T <: Component

Add a component to the system.

Throws ArgumentError if the component's name is already stored for its concrete type.

Throws InvalidRange if any of the component's field values are outside of defined valid
range.

# Examples
```julia
sys = System(100.0)

# Add a single component.
add_component!(sys, bus)

# Add many at once.
buses = [bus1, bus2, bus3]
generators = [gen1, gen2, gen3]
foreach(x -> add_component!(sys, x), Iterators.flatten((buses, generators)))
```
"""
function add_component!(sys::System, component::T; kwargs...) where T <: Component
    if T <: Branch
        arc = get_arc(component)
        check_bus(sys, get_from(arc), arc)
        check_bus(sys, get_to(arc), arc)
    elseif Bus in fieldtypes(T)
        check_bus(sys, get_bus(component), component)
    end

    if sys.runchecks && !validate_struct(sys, component)
        throw(InvalidValue("Invalid value for $(component)"))
    end

    IS.add_component!(sys.data, component; kwargs...)
end

"""
    add_forecasts!(
                   sys::System,
                   metadata_file::AbstractString,
                   label_mapping::Dict{Tuple{String, String}, String};
                   resolution=nothing,
                  )

Adds forecasts from a metadata file or metadata descriptors.

# Arguments
- `sys::System`: system
- `metadata_file::AbstractString`: metadata file for timeseries
  that includes an array of IS.TimeseriesFileMetadata instances or a vector.
- `label_mapping::Dict{Tuple{String, String}, String}`: maps customized component field names to
  WaterSystem field names
- `resolution::DateTime.Period=nothing`: skip forecast that don't match this resolution.
"""
function add_forecasts!(
                        sys::System,
                        metadata_file::AbstractString,
                        label_mapping::Dict{Tuple{String, String}, String};
                        resolution=nothing,
                       )
    return IS.add_forecasts!(Component, sys.data, metadata_file, label_mapping;
                             resolution=resolution)
end

"""
    add_forecasts!(
                   sys::System,
                   timeseries_metadata::Vector{IS.TimeseriesFileMetadata},
                   resolution=nothing,
                  )

Adds forecasts from a metadata file or metadata descriptors.

# Arguments
- `sys::System`: system
- `timeseries_metadata::Vector{IS.TimeseriesFileMetadata}`: metadata for timeseries
- `resolution::DateTime.Period=nothing`: skip forecast that don't match this resolution.
"""
function add_forecasts!(
                        sys::System,
                        timeseries_metadata::Vector{IS.TimeseriesFileMetadata},
                        resolution=nothing
                       )
    return IS.add_forecasts!(Component, sys.data, timeseries_metadata;
                             resolution=resolution)
end

function IS.add_forecast!(
                          ::Type{<:Component},
                          data::IS.SystemData,
                          forecast_cache::IS.ForecastCache,
                          metadata::IS.TimeseriesFileMetadata;
                          resolution=nothing,
                         )
    IS.set_component!(metadata, data, WaterSystems)
    component = metadata.component
    if isnothing(component)
        return
    end

    forecast, ts_data = IS.make_forecast!(forecast_cache, metadata; resolution=resolution)
    if isnothing(forecast)
        return
    end

    if component isa LoadZones
        uuids = Set([IS.get_uuid(x) for x in get_buses(component)])
        for component_ in (load for load in IS.get_components(ElectricLoad, data)
                          if get_bus(load) |> IS.get_uuid in uuids)
            if forecast isa IS.DeterministicInternal
                forecast_ = IS.DeterministicInternal(IS.get_label(forecast), ts_data)
            else
                # TODO: others
                error("forecast type is not supported yet: $(typeof(forecast))")
            end
            IS.add_forecast!(data, component_, forecast, ts_data)
        end
    else
        IS.add_forecast!(data, component, forecast, ts_data)
    end
end

"""
    iterate_components(sys::System)

Iterates over all components.

# Examples
```julia
for component in iterate_components(sys)
    @show component
end
```

See also: [`get_components`](@ref)
"""
function iterate_components(sys::System)
    return IS.iterate_components(sys.data)
end

"""
    clear_components!(sys::System)

Remove all components from the system.
"""
function clear_components!(sys::System)
    return IS.clear_components!(sys.data)
end

"""
    remove_components!(::Type{T}, sys::System) where T <: Component

Remove all components of type T from the system.

Throws ArgumentError if the type is not stored.
"""
function remove_components!(::Type{T}, sys::System) where T <: Component
    return IS.remove_components!(T, sys.data)
end

"""
    remove_component!(sys::System, component::T) where T <: Component

Remove a component from the system by its value.

Throws ArgumentError if the component is not stored.
"""
function remove_component!(sys::System, component)
    return IS.remove_component!(sys.data, component)
end

"""
    remove_component!(
                      ::Type{T},
                      sys::System,
                      name::AbstractString,
                      ) where T <: Component

Remove a component from the system by its name.

Throws ArgumentError if the component is not stored.
"""
function remove_component!(
                           ::Type{T},
                           sys::System,
                           name::AbstractString,
                          ) where T <: Component
    return IS.remove_component!(T, sys.data, name)
end

"""
    get_component(
                  ::Type{T},
                  sys::System,
                  name::AbstractString
                 )::Union{T, Nothing} where {T <: Component}

Get the component of concrete type T with name. Returns nothing if no component matches.

See [`get_components_by_name`](@ref) if the concrete type is unknown.

Throws ArgumentError if T is not a concrete type.
"""
function get_component(::Type{T}, sys::System, name::AbstractString) where T <: Component
    return IS.get_component(T, sys.data, name)
end

"""
    get_components(
                   ::Type{T},
                   sys::System,
                  )::FlattenIteratorWrapper{T} where {T <: Component}

Returns an iterator of components. T can be concrete or abstract.
Call collect on the result if an array is desired.

# Examples
```julia
iter = WaterSystems.get_components(ThermalStandard, sys)
iter = WaterSystems.get_components(Generator, sys)
generators = WaterSystems.get_components(Generator, sys) |> collect
generators = collect(WaterSystems.get_components(Generator, sys))
```

See also: [`iterate_components`](@ref)
"""
function get_components(
                        ::Type{T},
                        sys::System,
                       )::FlattenIteratorWrapper{T} where {T <: Component}
    return IS.get_components(T, sys.data)
end

"""
    get_components_by_name(
                           ::Type{T},
                           sys::System,
                           name::AbstractString
                          )::Vector{T} where {T <: Component}

Get the components of abstract type T with name. Note that WaterSystems enforces unique
names on each concrete type but not across concrete types.

See [`get_component`](@ref) if the concrete type is known.

Throws ArgumentError if T is not an abstract type.
"""
function get_components_by_name(
                                ::Type{T},
                                sys::System,
                                name::AbstractString
                               )::Vector{T} where {T <: Component}
    return IS.get_components_by_name(T, sys.data, name)
end

"""
    add_forecast!(sys::System, component::Component, forecast::Forecast)

Adds forecast to the system.

Throws ArgumentError if the component is not stored in the system.

"""
function add_forecast!(sys::System, component::Component, forecast::Forecast)
    return IS.add_forecast!(sys.data, component, forecast)
end

"""
    add_forecast!(
                  sys::System,
                  filename::AbstractString,
                  component::Component,
                  label::AbstractString,
                  scaling_factor::Union{String, Float64}=1.0,
                 )

Add a forecast to a system from a CSV file.

See [`InfrastructureSystems.TimeseriesFileMetadata`](@ref) for description of
scaling_factor.
"""
function add_forecast!(
                       sys::System,
                       filename::AbstractString,
                       component::Component,
                       label::AbstractString,
                       scaling_factor::Union{String, Float64}=1.0,
                      )
    return IS.add_forecast!(sys.data, filename, component, label, scaling_factor)
end

"""
    add_forecast!(
                  sys::System,
                  ta::TimeSeries.TimeArray,
                  component,
                  label,
                  scaling_factor::Union{String, Float64}=1.0,
                 )

Add a forecast to a system from a TimeSeries.TimeArray.

See [`InfrastructureSystems.TimeseriesFileMetadata`](@ref) for description of
scaling_factor.
"""
function add_forecast!(
                       sys::System,
                       ta::TimeSeries.TimeArray,
                       component,
                       label,
                       scaling_factor::Union{String, Float64}=1.0,
                      )
    return IS.add_forecast!(sys.data, ta, component, label, scaling_factor)
end

"""
    add_forecast!(
                  sys::System,
                  df::DataFrames.DataFrame,
                  component,
                  label,
                  scaling_factor::Union{String, Float64}=1.0,
                 )

Add a forecast to a system from a DataFrames.DataFrame.

See [`InfrastructureSystems.TimeseriesFileMetadata`](@ref) for description of
scaling_factor.
"""
function add_forecast!(
                       sys::System,
                       df::DataFrames.DataFrame,
                       component,
                       label,
                       scaling_factor::Union{String, Float64}=1.0,
                      )
    return IS.add_forecast!(sys.data, df, component, label, scaling_factor)
end

"""
    make_forecasts(sys::System, metadata_file::AbstractString; resolution=nothing)

Return a vector of forecasts from a metadata file.

# Arguments
- `data::SystemData`: system
- `metadata_file::AbstractString`: path to metadata file
- `resolution::{Nothing, Dates.Period}`: skip any forecasts that don't match this resolution

See [`InfrastructureSystems.TimeseriesFileMetadata`](@ref) for description of what the file
should contain.
"""
function make_forecasts(sys::System, metadata_file::AbstractString; resolution=nothing)
    return IS.make_forecasts(sys.data, metadata_file, WaterSystems; resolution=resolution)
end

"""
    make_forecasts(data::SystemData, timeseries_metadata::Vector{TimeseriesFileMetadata};
                   resolution=nothing)

Return a vector of forecasts from a vector of TimeseriesFileMetadata values.

# Arguments
- `data::SystemData`: system
- `timeseries_metadata::Vector{TimeseriesFileMetadata}`: metadata values
- `resolution::{Nothing, Dates.Period}`: skip any forecasts that don't match this resolution
"""
function make_forecasts(sys::System, metadata::Vector{IS.TimeseriesFileMetadata};
                        resolution=nothing)
    return IS.make_forecasts(sys.data, metadata, WaterSystems; resolution=resolution)
end

"""
    generate_initial_times(sys::System, interval::Dates.Period, horizon::Int)

Generates all possible initial times for the stored forecasts. This should be used when
contiguous forecasts have been stored in chunks, such as a one-year forecast broken up into
365 one-day forecasts.

Throws ArgumentError if there are no forecasts stored, interval is not a multiple of the
system's forecast resolution, or if the stored forecasts have overlapping timestamps.
"""
function generate_initial_times(sys::System, interval::Dates.Period, horizon::Int)
    return generate_initial_times(sys.data, interval, horizon)
end

"""
    get_forecast(
                 ::Type{T},
                 component::Component,
                 initial_time::Dates.DateTime,
                 label::AbstractString,
                ) where T <: Forecast

Return a forecast for the entire time series range stored for these parameters.
"""
function get_forecast(
                      ::Type{T},
                      component::Component,
                      initial_time::Dates.DateTime,
                      label::AbstractString,
                      ) where T <: Forecast
    return IS.get_forecast(T, component, initial_time, label)
end

"""
    get_forecast(
                 ::Type{T},
                 component::Component,
                 initial_time::Dates.DateTime,
                 label::AbstractString,
                 horizon::Int,
                ) where T <: Forecast

Return a forecast for a subset of the time series range stored for these parameters.
"""
function get_forecast(
                      ::Type{T},
                      component::InfrastructureSystemsType,
                      initial_time::Dates.DateTime,
                      label::AbstractString,
                      horizon::Int,
                     ) where T <: Forecast
    return IS.get_forecast(T, component, initial_time, label, horizon)
end

function get_forecast_initial_times(
                                    ::Type{T},
                                    component::Component,
                                   ) where T <: Forecast
    return IS.get_forecast_initial_times(T, component)
end

function get_forecast_initial_times(
                                    ::Type{T},
                                    component::Component,
                                    label::AbstractString
                                   ) where T <: Forecast
    return IS.get_forecast_initial_times(T, component, label)
end

function get_forecast_labels(
                             ::Type{T},
                             component::Component,
                             initial_time::Dates.DateTime,
                            ) where T <: Forecast
    return IS.get_forecast_labels(T, component, initial_time)
end

"""
    get_forecast_values(component::Component, forecast::Forecast)

Return a TimeSeries.TimeArray where the forecast data has been multiplied by the forecasted
component field.
"""
function get_forecast_values(component::Component, forecast::Forecast)
    return IS.get_forecast_values(component, forecast)
end

"""
    get_forecast_initial_times(sys::System)::Vector{Dates.DateTime}

Return sorted forecast initial times.

"""
function get_forecast_initial_times(sys::System)::Vector{Dates.DateTime}
    return IS.get_forecast_initial_times(sys.data)
end

"""
    get_forecast_keys(component::InfrastructureSystemsType)

Return an iterable of NamedTuple keys for forecasts stored for this component.
"""
function get_forecast_keys(component::Component)
    return IS.get_forecast_keys(component)
end

"""
    get_forecasts_horizon(sys::System)

Return the horizon for all forecasts.
"""
function get_forecasts_horizon(sys::System)
    return IS.get_forecasts_horizon(sys.data)
end

"""
    get_forecasts_initial_time(sys::System)

Return the earliest initial_time for a forecast.
"""
function get_forecasts_initial_time(sys::System)
    return IS.get_forecasts_initial_time(sys.data)
end

"""
    get_forecasts_interval(sys::System)

Return the interval for all forecasts.
"""
function get_forecasts_interval(sys::System)
    return IS.get_forecasts_interval(sys.data)
end

"""
    get_forecasts_resolution(sys::System)

Return the resolution for all forecasts.
"""
function get_forecasts_resolution(sys::System)
    return IS.get_forecasts_resolution(sys.data)
end

"""
    iterate_forecasts(sys::System)

Iterates over all forecasts in order of initial time.

# Examples
```julia
for forecast in iterate_forecasts(sys)
    @show forecast
end
```
"""
function iterate_forecasts(sys::System)
    return IS.iterate_forecasts(sys.data)
end

"""
    clear_forecasts!(sys::System)

Remove all forecasts from the system.
"""
function clear_forecasts!(sys::System)
    return IS.clear_forecasts!(sys.data)
end

"""
    check_forecast_consistency(sys::System)

Throws DataFormatError if forecasts have inconsistent parameters.
"""
function check_forecast_consistency(sys::System)
    IS.check_forecast_consistency(sys.data)
end

"""
    validate_forecast_consistency(sys::System)

Return true if all forecasts have consistent parameters.
"""
function validate_forecast_consistency(sys::System)
    return IS.validate_forecast_consistency(sys.data)
end

"""
    remove_forecast!(
                     ::Type{T},
                     sys::System,
                     component::Component,
                     initial_time::Dates.DateTime,
                     label::String,
                    )

Remove the time series data for a component.
"""
function remove_forecast!(
                          ::Type{T},
                          sys::System,
                          component::Component,
                          initial_time::Dates.DateTime,
                          label::String,
                         ) where T <: Forecast
    return IS.remove_forecast!(T, sys.data, component, initial_time, label)
end

"""
    validate_struct(sys::System, value::WaterSystemType)

Validates an instance of a WaterSystemType against System data.
Returns true if the instance is valid.

Users implementing this function for custom types should consider implementing
InfrastructureSystems.validate_struct instead if the validation logic only requires data
contained within the instance.
"""
function validate_struct(sys::System, value::WaterSystemType)::Bool
    return true
end

function check!(sys::System)
    buses = get_components(Bus, sys)
    slack_bus_check(buses)
    buscheck(buses)
end

function JSON2.read(io::IO, ::Type{System})
    raw = JSON2.read(io, NamedTuple)
    data = IS.deserialize(IS.SystemData, Component, raw.data)
    sys = System(data, float(raw.elevation); runchecks=raw.runchecks)
    return sys
end

function IS.deserialize_components(
                                   ::Type{Component},
                                   data::IS.SystemData,
                                   raw::NamedTuple,
                                  )
    # TODO: This adds components through IS.SystemData instead System, which is what should
    # happen. There is a catch-22 between creating System and SystemData.
    component_cache = Dict{Base.UUID, Component}()

    # Buses and Arcs are encoded as UUIDs.
    composite_components = [Bus]
    for composite_component in composite_components
        for component in IS.get_components_raw(IS.SystemData, composite_component, raw)
            comp = IS.convert_type(composite_component, component)
            IS.add_component!(data, comp)
            component_cache[IS.get_uuid(comp)] = comp
        end
    end

    # Skip Services this round because they have Devices.
    for c_type_sym in IS.get_component_types_raw(IS.SystemData, raw)
        c_type = getfield(WaterSystems, Symbol(IS.strip_module_name(string(c_type_sym))))
        (c_type in composite_components || c_type <: Service) && continue
        for component in IS.get_components_raw(IS.SystemData, c_type, raw)
            comp = IS.convert_type(c_type, component, component_cache)
            IS.add_component!(data, comp)
            component_cache[IS.get_uuid(comp)] = comp
        end
    end

    # Now get the Services.
    for c_type_sym in IS.get_component_types_raw(IS.SystemData, raw)
        c_type = getfield(WaterSystems, Symbol(IS.strip_module_name(string(c_type_sym))))
        if c_type <: Service
            for component in IS.get_components_raw(IS.SystemData, c_type, raw)
                comp = IS.convert_type(c_type, component, component_cache)
                IS.add_component!(data, comp)
            end
        end
    end
end

function JSON2.write(io::IO, component::T) where T <: Component
    return JSON2.write(io, encode_for_json(component))
end

function JSON2.write(component::T) where T <: Component
    return JSON2.write(encode_for_json(component))
end

"""
Encode composite buses as UUIDs.
"""
function encode_for_json(component::T) where T <: Component
    fields = fieldnames(T)
    vals = []

    for name in fields
        val = getfield(component, name)
        if val isa Bus
            push!(vals, IS.get_uuid(val))
        else
            push!(vals, val)
        end
    end

    return NamedTuple{fields}(vals)
end

function IS.convert_type(
                         ::Type{T},
                         data::NamedTuple,
                         component_cache::Dict,
                        ) where T <: Component
    @debug T data
    values = []
    for (fieldname, fieldtype)  in zip(fieldnames(T), fieldtypes(T))
        val = getfield(data, fieldname)
        if fieldtype <: Bus
            uuid = Base.UUID(val.value)
            bus = component_cache[uuid]
            push!(values, bus)
        elseif fieldtype <: Component
            # Recurse.
            push!(values, IS.convert_type(fieldtype, val, component_cache))
        else
            obj = IS.convert_type(fieldtype, val)
            push!(values, obj)
        end
    end

    return T(values...)
end

function IS.compare_values(x::System, y::System)::Bool
    match = true

    if !IS.compare_values(x.data, y.data)
        @debug "SystemData values do not match"
        match = false
    end

    if x.elevation != y.elevation
        @debug "elevation does not match" x.elevation y.elevation
        match = false
    end

    return match
end

function _create_system_data_from_kwargs(; kwargs...)
    validation_descriptor_file = nothing
    runchecks = get(kwargs, :runchecks, true)
    if runchecks
        validation_descriptor_file = get(kwargs, :configpath,
                                         WATER_SYSTEM_STRUCT_DESCRIPTOR_FILE)
    end

    return IS.SystemData(; validation_descriptor_file=validation_descriptor_file)
end

function parse_types(mod)
    for name in names(mod)
        mod_type = getfield(mod, name)
        try
            !isstructtype(mod_type) && continue
        catch(e)
            continue
        end
        !isconcretetype(mod_type) && continue
        println("object $mod_type")
    end
    for name in names(mod)
        mod_type = getfield(mod, name)
        !isstructtype(mod_type) && continue
        !isconcretetype(mod_type) && continue
        for (fname, ftype) in zip(fieldnames(mod_type), fieldtypes(mod_type))
            if ftype in names(mod)
                println("$mod_type o-- $ftype")
            end
        end
    end
end
