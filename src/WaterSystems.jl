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

# technical parameters
export EPANETPumpParams
export NormPumpParams
export PumpParams

# transport elements 
export Link
export Pipe  # why is this prepended by WaterSystems in the type tree?? JJS 11/5/19
export Pump
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
export parse_inp_file
export dict_to_struct
export make_dict
export wntr_dict

#################################################################################
# Imports

using PyCall # keeping this as "using" for now, but probably should change to import, JJS
             # 12/6/19
# coverted these to imports -- not sure what calls refer to them, JJS 12/6/19
import CurveFit
import SparseArrays
import LinearAlgebra

import Dates
import Dates: DateTime
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

# python imports, needed to use wntr for parsing epanet files
#!!!!!!!!!!!!!!!!! these are all returning "PyObject NULL" !!!!!!!!!!!!! JJS 12/6/19
metric = pyimport("wntr.metrics.economic") # what is this for? JJS 12/5/19
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

# Models
include("models/topological_elements.jl")
include("models/water_demand.jl")
include("models/links.jl")

# Include all auto-generated structs.
include("models/generated/includes.jl")

# Definitions of (Water) System
include("base.jl")

# parsing files
include("parsers/epanet_file_parser.jl")
include("parsers/dict_to_struct.jl")
include("parsers/wntr_dict.jl")
include("parsers/wntr_dict_parser.jl")

# utils... not sure what of the legacy code will be needed, JJS 12/5/19
#include("Utils/build_incidence.jl")

end # module
