# WaterSystems

[![Build Status](https://travis-ci.org/NREL/WaterSystems.jl.svg?branch=master)](https://travis-ci.org/NREL/WaterSystems.jl)

[![codecov](https://codecov.io/gh/NREL/WaterSystems.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/NREL/WaterSystems.jl)


The `WaterSystems.jl` package provides a rigorous data model using Julia structures to enable water systems analysis and modeling. In addition to stand-alone system analysis tools and data model building, the `WaterSystems.jl` package is used as the foundational data container for the [WaterSimulations.jl](https://github.com/NREL/WaterSimulations.jl) package. `WaterSystems.jl` supports a limited number of data file formats for parsing.

## Version Advisory

- The latest tagged version in WaterSystems (v0.1.0) will work with Julia v1.2+.

### Device data enabled in WaterSystems:
 - Topological elements (Junctions, Arcs, PressureZones)
 - Pipes
 - Pumps
 - Valves
 - Storage (Tanks, Reservoirs)
 - Load (Demand)
 - Forecasts (Deterministic, scenario, stochastic)

### Parsing capabilities in WaterSystems:
 - EPANet via WNTR
 - EPANet via WaterModels.jl

## Installation

You can install it by typing

```julia
julia> ] add WaterSystems
```

## Usage

Once installed, the `WaterSystems` package can by used by typing

```julia
using WaterSystems
```


## Development

Contributions to the development and enahancement of WaterSystems is welcome. Please see [CONTRIBUTING.md](https://github.com/NREL/WaterSystems.jl/blob/master/CONTRIBUTING.md) for code contribution guidelines.

## License

WaterSystems is released under a BSD [license](https://github.com/NREL/WaterSystems.jl/blob/master/LICENSE). WaterSystems has been developed as part of the Scalable Integrated Infrastructure Planning (SIIP)
initiative at the U.S. Department of Energy's National Renewable Energy Laboratory ([NREL](https://www.nrel.gov/))
