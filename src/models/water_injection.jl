abstract type Injection <: Device end
abstract type WaterDemand <: Injection end
abstract type Tank <: Injection end

## potential todo:  add Emitter type as described in EPANET manual
# abstract type Emitter <: Devise end 
