isdefined(Base, :__precompile__) && __precompile__()

"""
Module for constructing self-contained water system objects.
"""
module WaterSystems

#################################################################################
# Exports

# water system
export System

export WaterSystemType
export Component
export Device

# topological elements
export Junction
export Arc

# transport elements  #### need to add and fix these, JJS 11/5/19
export Link
export Pipe  # why is this prepended by WaterSystems in the type tree?? JJS 11/5/19
export Valve
export OpenPipe
export GatePipe
export CVPipe
export Reservoir
export Tank 

# demands
export WaterDemand
export StaticDemand

# parser
export dict_to_struct
export make_dict
export wntr_dict

#################################################################################
# Imports

using PyCall
using CurveFit
using SparseArrays
using LinearAlgebra

import Dates
import TimeSeries
import DataFrames
import JSON
import JSON2
import CSV
import YAML
import UUIDs
import Base.to_index

import InfrastructureSystems
import InfrastructureSystems: Components, Deterministic, Probabilistic, Forecast,
    ScenarioBased, InfrastructureSystemsType, InfrastructureSystemsInternal,
    FlattenIteratorWrapper, LazyDictFromIterator, DataFormatError, InvalidRange,
    InvalidValue

const IS = InfrastructureSystems

metric = pyimport("wntr.metrics.economic")
model = pyimport("wntr.network.model") #import wntr network model
sim = pyimport("wntr.sim.epanet")

#################################################################################
# Includes

"""
Supertype for all WaterSystems types.
All subtypes must include a InfrastructureSystemsInternal member.
Subtypes should call InfrastructureSystemsInternal() by default, but also must
provide a constructor that allows existing values to be deserialized.
"""
abstract type WaterSystemType <: IS.InfrastructureSystemsType end

abstract type Component <: WaterSystemType end
# supertype for "devices" (pipe, pump, valve, etc.)
abstract type Device <: Component end
# supertype for technical parameters, data, etc.
abstract type TechnicalParams <: WaterSystemType end

#Models
include("models/topological_elements.jl")
include("models/water_demand.jl")
include("models/links.jl")

# Include all auto-generated structs.
include("models/generated/includes.jl")
#include("models/supplemental_constructors.jl")

include("base.jl")

end # module
